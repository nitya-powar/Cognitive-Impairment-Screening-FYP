library(caret)
library(pROC)
library(missRanger)
library(DALEX)
library(dplyr)
library(randomForest)

# ----------------------------------------------------------------------------------------
# 1) Loading Data
# ----------------------------------------------------------------------------------------

load("data/processed/cleaned_data_for_modeling.RData")
#load("data/processed/cleaned_data_resampled.RData")

#Reduced feature set for baseline comparison
top_lab_features <- c(
  "LBDBCDSI", "LBDTCSI", "LBDHDDSI", "LBDSCRSI", "LBDSGBSI",
  "URDACT", "LBXMMASI", "LBXVIDMS", "LBDGLUSI", "LBDTRSI" # top 10
  #, "LBXHCT", "LBXPLTSI", "LBXRDW", "LBXHGB", "LBDRFOSI",
  # "LBXVE3MS", "LBDB12SI", "LBDLDLSI", "LBXSATSI", "LBDSIRSI" # top 20
  # ",LBXLYPCT", "LBDBPBSI", "LBXMCVSI", "LBXGH", "LBXMOPCT",
  # "LBDINSI", "LBDBSESI", "LBXRBCSI", "LBXMCHSI", "LBXNEPCT" # top 30
  # , "LBDBMNSI", "LBXSAPSI", "LBDTHGSI", "LBDSUASI", "LBXWBCSI",
  # "LBXSGTSI", "LBDSTPSI", "LBDNENO", "LBXMC", "LBXMPSI" # top 40
)

demographic_features <- c("age_years", "gender", "education_level", "race",
                          "marital_status", "bmi", "mean_sbp", "mean_dbp", "waist",
                          "height", "weight", "grip_strength", "phq9_sum", "phq9_depressed")

selected_features <- c(demographic_features, top_lab_features)

train_x <- train_x[, selected_features]
#train_x_resampled <- train_x_resampled[, selected_features]
test_x <- test_x[, selected_features]

# ----------------------------------------------------------------------------------------
# 2) Median imputation with missRanger
# ----------------------------------------------------------------------------------------

imputation_models <- missRanger(
  train_x,
#  train_x_resampled,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  keep_forests = TRUE  
)

train_x_imp <- imputation_models$data  
fits <- imputation_models$forests   

test_x_imp <- missRanger(
  test_x,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  forests = fits  
)

# ----------------------------------------------------------------------------------------
# 3) Train Random Forest
# ----------------------------------------------------------------------------------------
# Convert target to factor for RF
train_y_factor <- as.factor(train_y)  # Convert binary label to factor for classification
#train_y_factor <- as.factor(train_y_resampled)  # Convert binary label to factor for classification
levels(train_y_factor) <- c("No_MCI", "MCI")  # Set readable class labels

train_data <- data.frame(train_x_imp, cog_impair = train_y_factor)  # Combine predictors and target for caret



# Use caret to find optimal hyperparameters WITH CV
set.seed(123)  # Keep CV results reproducible
fitControl <- trainControl(
  method = "cv",  # 5-fold cross-validation
  number = 5,  # Number of folds
  classProbs = TRUE,  # Required for sensitivity-based tuning
  summaryFunction = twoClassSummary,  # Compute classification performance metrics
  savePredictions = "final"  # Save out-of-fold predictions for CV-based threshold selection
)

# Calculate sqrt of predictors
n_pred <- ncol(train_x_imp)  # Total number of input features
sqrt_pred <- round(sqrt(n_pred))  # Common starting heuristic for mtry

rf_tune <- train(
  cog_impair ~ .,
  data = train_data,  
  method = "rf",
  trControl = fitControl, 
  # Search 7 candidate mtry values from a lower to wider range around sqrt(p).
  tuneGrid = data.frame(mtry = unique(pmax(1, round(seq(sqrt_pred / 2, min(n_pred, sqrt_pred * 3), length.out = 7))))),
  classwt = c("No_MCI" = 1.0, "MCI" = 1.5),  # Keep weighting consistent with final model
#  classwt = c("No_MCI" = 1.0, "MCI" = 1.0),  # Keep weighting consistent with final model # train_x_resampled
  ntree = 500,  # Trees used during CV tuning
  metric = "Sens"  # Optimize for Sensitivity
)

# Extract best parameters
best_mtry <- rf_tune$bestTune$mtry  # Best mtry from cross-validation
cat("Optimal mtry found by CV:", best_mtry, "\n")

# ----------------------------------------------------------------------------------------
# 3A) CV log loss summary
# ----------------------------------------------------------------------------------------
calc_logloss <- function(actual, prob_mci) {
  actual_num <- ifelse(actual == "MCI", 1, 0)
  prob_mci <- pmin(pmax(prob_mci, 1e-15), 1 - 1e-15)
  -mean(actual_num * log(prob_mci) + (1 - actual_num) * log(1 - prob_mci))
}

cv_pred_best <- rf_tune$pred %>%
  filter(mtry == best_mtry)

mean_logloss <- calc_logloss(cv_pred_best$obs, cv_pred_best$MCI)

cv_fold_logloss <- cv_pred_best %>%
  group_by(Resample) %>%
  summarise(logloss = calc_logloss(obs, MCI), .groups = "drop")

sd_logloss <- sd(cv_fold_logloss$logloss)
var_logloss <- sd_logloss^2

cat("CV mean logloss:", round(mean_logloss, 4), "\n")
cat("CV SD logloss:", round(sd_logloss, 4), "\n")
cat("CV variance:", round(var_logloss, 5), "\n")

# Train final model with randomForest() using optimal params
final_rf <- randomForest(
  x = train_x_imp,
  y = train_y_factor,
  ntree = 500,  # Number of trees in the ensemble
  mtry = best_mtry,  # Use cross-validated mtry
  importance = TRUE,  # Store feature importance measures
  classwt = c("No_MCI" = 1.0, "MCI" = 1.5),  # Upweight MCI to reduce false negatives
#  classwt = c("No_MCI" = 1.0, "MCI" = 1.0),  # Keep weighting consistent with final model # train_x_resampled
  keep.forest = TRUE  # Retain trained trees for prediction
)

# Print model summary
print(final_rf)

# Feature importance - BOTH metrics
imp <- importance(final_rf)  # Extract RF importance scores
#print("Top 10 features by MeanDecreaseAccuracy (predictive power):")
top_acc <- imp[order(-imp[, "MeanDecreaseAccuracy"]), ]  # Rank by predictive impact
#print(head(top_acc, 10))
print("Top 40 features by MeanDecreaseAccuracy (predictive power):")
print(head(top_acc, 50))

print("\nTop 10 features by MeanDecreaseGini (impurity reduction):")
top_gini <- imp[order(-imp[, "MeanDecreaseGini"]), ]  # Rank by split impurity reduction
print(head(top_gini, 50))
print("\nTop 40 features by MeanDecreaseGini (impurity reduction):")
print(head(top_gini, 50))

# Plot feature importance
varImpPlot(final_rf, main = "Random Forest Feature Importance")

# ----------------------------------------------------------------------------------------
# 4) Predictions
# ----------------------------------------------------------------------------------------

# Get probabilities (probability of MCI class)
pred_prob <- predict(final_rf, test_x_imp, type = "prob")[, "MCI"]

cat("Random Forest trained with", final_rf$ntree, "trees\n")
cat("OOB error rate:", round(final_rf$err.rate[final_rf$ntree, "OOB"], 4), "\n")

# ----------------------------------------------------------------------------------------
# 4A) Training metrics
# ----------------------------------------------------------------------------------------
train_pred_prob <- predict(final_rf, train_x_imp, type = "prob")[, "MCI"]
train_logloss <- calc_logloss(train_y_factor, train_pred_prob)
cat("Training Log Loss:", round(train_logloss, 4), "\n")

# --------------------------------------------------------------------------------------------
# 7B) Predict + pick best threshold
# --------------------------------------------------------------------------------------------
# Get out-of-fold CV probabilities for threshold selection
cv_pred <- rf_tune$pred
roc_obj <- roc(response = cv_pred$obs, predictor = cv_pred$MCI)
best_t  <- as.numeric(coords(roc_obj, "best", ret = "threshold"))
print(best_t)

train_pred_class_best_t <- ifelse(train_pred_prob > best_t, 1, 0)
train_accuracy_best_t <- mean(train_pred_class_best_t == train_y)
cat("Training Accuracy (best_t threshold):", round(train_accuracy_best_t, 4), "\n")

# Predictions with best threshold
pred_class_best_t <- ifelse(pred_prob > best_t, 1, 0)
accuracy_best_t <- mean(pred_class_best_t == test_y)
cat("Accuracy (best_t threshold):", round(accuracy_best_t, 4), "\n")

# Predictions with 0.50 threshold
pred_class_5 <- ifelse(pred_prob > 0.50, 1, 0)
accuracy_5 <- mean(pred_class_5 == test_y)
cat("Accuracy (0.50 threshold):", round(accuracy_5, 4), "\n")

# ------------------------------------------------------------------------------------------------
# 8) Getting TP, FP, TN, FN for each row
# ------------------------------------------------------------------------------------------------

results <- data.frame(
  actual   = test_y,
  predicted = pred_class_best_t
)

results$case <- NA #creating empty column in results dataframe
results$case[results$actual == 1 & results$predicted == 1] <- "TP"
results$case[results$actual == 0 & results$predicted == 1] <- "FP"
results$case[results$actual == 1 & results$predicted == 0] <- "FN"
results$case[results$actual == 0 & results$predicted == 0] <- "TN"

table(results$case) # displaying number of TP, FP, TN, FN
FP_data <- test_x_imp[results$case == "FP", ]
TP_data <- test_x_imp[results$case == "TP", ]
TN_data <- test_x_imp[results$case == "TN", ]
FN_data <- test_x_imp[results$case == "FN", ]

write.csv(TP_data, "data/processed/error_groups/RF/TP_data.csv", row.names = FALSE)
write.csv(FP_data, "data/processed/error_groups/RF/FP_data.csv", row.names = FALSE)
write.csv(FN_data, "data/processed/error_groups/RF/FN_data.csv", row.names = FALSE)
write.csv(TN_data, "data/processed/error_groups/RF/TN_data.csv", row.names = FALSE)


# ------------------------------------------------------------------------------------------------
# 9) Calculate precision, recall, F1
# ------------------------------------------------------------------------------------------------

# Function to calculate metrics from a results dataframe
calculate_metrics <- function(results_df) {
  TP <- sum(results_df$case == "TP")
  FP <- sum(results_df$case == "FP")
  FN <- sum(results_df$case == "FN")
  TN <- sum(results_df$case == "TN")
  
  precision <- TP / (TP + FP)
  recall    <- TP / (TP + FN)
  F1        <- 2 * (precision * recall) / (precision + recall)
  specificity <- TN / (TN + FP)
  return(c(Precision = precision, Recall = recall, F1 = F1, Specificity = specificity))
}

metrics <- calculate_metrics(results)
cat("Precision:", round(metrics["Precision"], 3), "\n")
cat("Recall:",    round(metrics["Recall"], 3), "\n")
cat("Specificity:",round(metrics["Specificity"], 3), "\n")
cat("F1 Score:",  round(metrics["F1"], 3), "\n")

roc_obj_test <- roc(response = test_y, predictor = pred_prob)
auc_value <- auc(roc_obj_test)
cat("ROC AUC:", round(auc_value, 3), "\n")

# Plot the ROC curve
plot(roc_obj_test, 
     main = paste("ROC Curve (AUC =", round(auc_value, 3), ")"),
     print.auc = TRUE,      # Display AUC on plot
     auc.polygon = TRUE,    # Fill area under curve
     max.auc.polygon = TRUE,
     grid = TRUE,           # Add grid lines
     legacy.axes = TRUE)    # Shows FPR on x-axis (0 to 1)

# Add a reference line for random guessing (AUC = 0.5)
abline(a = 0, b = 1, lty = 2, col = "red")

# -------------------------------------------------------------------------------------------------------------------------
saveRDS(final_rf, "outputs/models/random_forest_model.rds")
saveRDS(test_x_imp, "data/processed/RF_exports/test_x_imp_RF.rds")
saveRDS(train_x_imp, "data/processed/RF_exports/train_x_imp_RF.rds")
saveRDS(pred_prob, "data/processed/RF_exports/pred_prob_RF.rds")
saveRDS(pred_class_5, "data/processed/RF_exports/pred_class_5_RF.rds") 
saveRDS(pred_class_best_t, "data/processed/RF_exports/pred_class_best_t_RF.rds") 
saveRDS(test_y, "data/processed/RF_exports/test_y_RF.rds")
saveRDS(results,    "data/processed/RF_exports/results_test_RF.rds")
