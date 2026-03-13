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

# Reduced feature set for baseline comparison
top_lab_features <- c("LBXMMASI", "LBDHDD", "LBXSTR", "LBXSLDSI", "LBXSGB",
                      "LBXSCR", "LBXMCVSI", "LBXRDW", "LBXMOPCT", "LBDB12",
                      "LBDHDDSI", "LBXNEPCT", "LBXGH", "LBXVIDMS", "LBXLYPCT",
                      "LBDLYMNO", "LBXPLTSI", "LBXSBU", "LBXMC", "LBXHCT")

demographic_features <- c("age_years", "gender", "education_level", "race",
                          "marital_status", "bmi", "mean_sbp", "mean_dbp", "waist",
                          "height", "weight", "grip_strength", "phq9_sum", "phq9_depressed")

selected_features <- c(demographic_features, top_lab_features)

train_x <- train_x[, selected_features]
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
#train_y_factor <- as.factor(train_y_resampled)
train_y_factor <- as.factor(train_y)
levels(train_y_factor) <- c("No_MCI", "MCI")

train_data <- data.frame(train_x_imp, cog_impair = train_y_factor)

# Calculate sqrt of predictors
n_pred <- ncol(train_x_imp)
sqrt_pred <- round(sqrt(n_pred))

# Use caret to find optimal hyperparameters WITH CV
set.seed(123)
fitControl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

rf_tune <- train(
  cog_impair ~ .,
  data = train_data,  
  method = "rf",
  trControl = fitControl,
  tuneGrid = data.frame(mtry = c(sqrt_pred, sqrt_pred*2, sqrt_pred*3)),
  ntree = 500,
  metric = "Sens"  # Optimize for Sensitivity
)

# Extract best parameters
best_mtry <- rf_tune$bestTune$mtry
cat("Optimal mtry found by CV:", best_mtry, "\n")

# Train final model with randomForest() using optimal params
final_rf <- randomForest(
  x = train_x_imp,
  y = train_y_factor,
  ntree = 500,
  mtry = best_mtry,  # this is optimal mtry
  importance = TRUE,
  classwt = c("No_MCI" = 1.0, "MCI" = 1.5),
  keep.forest = TRUE
)

# Print model summary
print(final_rf)

# Feature importance - BOTH metrics
imp <- importance(final_rf)
print("Top 10 features by MeanDecreaseAccuracy (predictive power):")
top_acc <- imp[order(-imp[, "MeanDecreaseAccuracy"]), ]
print(head(top_acc, 10))

print("\nTop 10 features by MeanDecreaseGini (impurity reduction):")
top_gini <- imp[order(-imp[, "MeanDecreaseGini"]), ]
print(head(top_gini, 10))

# Plot feature importance
varImpPlot(final_rf, main = "Random Forest Feature Importance")

# ----------------------------------------------------------------------------------------
# 4) Predictions
# ----------------------------------------------------------------------------------------

# Get probabilities (probability of MCI class)
pred_prob <- predict(final_rf, test_x_imp, type = "prob")[, "MCI"]

cat("Random Forest trained with", final_rf$ntree, "trees\n")
cat("OOB error rate:", round(final_rf$err.rate[final_rf$ntree, "OOB"], 4), "\n")

# --------------------------------------------------------------------------------------------
# 7B) Predict + pick best threshold
# --------------------------------------------------------------------------------------------
# Get training probabilities for threshold selection
train_prob_rf <- predict(final_rf, train_x_imp, type = "prob")[, "MCI"]

# ROC for threshold selection (on training data)
#roc_obj <- roc(response = train_y_resampled, predictor = train_prob_rf)
roc_obj <- roc(response = train_y, predictor = train_prob_rf)
best_t  <- as.numeric(coords(roc_obj, "best", ret = "threshold"))
print(best_t)

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

write.csv(TP_data, "data/processed/error_groups/TP_data.csv", row.names = FALSE)
write.csv(FP_data, "data/processed/error_groups/FP_data.csv", row.names = FALSE)
write.csv(FN_data, "data/processed/error_groups/FN_data.csv", row.names = FALSE)
write.csv(TN_data, "data/processed/error_groups/TN_data.csv", row.names = FALSE)


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
saveRDS(test_x_imp, "data/processed/test_x_imp_RF.rds")
saveRDS(train_x_imp, "data/processed/train_x_imp_RF.rds")
saveRDS(pred_prob, "data/processed/pred_prob_RF.rds")
saveRDS(pred_class_5, "data/processed/pred_class_5_RF.rds") 
saveRDS(pred_class_best_t, "data/processed/pred_class_best_t_RF.rds") 
saveRDS(results,    "data/interim/results_test_RF.rds")
