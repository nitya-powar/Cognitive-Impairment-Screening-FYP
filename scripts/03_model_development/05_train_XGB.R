library(xgboost)
library(caret)
library(pROC)
library(ggplot2)
library(missRanger)
library(dplyr)
library(MLmetrics)

# ----------------------------------------------------------------------------------------
# 1) Loading Data
# ----------------------------------------------------------------------------------------
#load("data/processed/cleaned_data_for_modeling.RData")
load("data/processed/cleaned_data_resampled.RData")

# ----------------------------------------------------------------------------------------
# 2) Median imputation with missRanger
# ----------------------------------------------------------------------------------------

# Imputing the training data and keeping trained forest models
imputation_models <- missRanger(
#  train_x,
  train_x_resampled,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  keep_forests = TRUE  
)

train_x_imp <- imputation_models$data  # imputed training data
fits <- imputation_models$forests      # trained model for each variable

# Imputing the TEST data using the same models from training
test_x_imp <- missRanger(
  test_x,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  forests = fits  
)

# ----------------------------------------------------------------------------------------
# 3) Convert to matrices for XGBoost
# ----------------------------------------------------------------------------------------

train_mat <- as.matrix(train_x_imp)
test_mat  <- as.matrix(test_x_imp)

# ---------------------------------------------------------------------------------------
# 4) Cost-sensitive learning (for higher recall) + re-weighting (for missing data and MCI unevenness in data)
# ---------------------------------------------------------------------------------------
C_FN <- 1.5   # cost of missing an MCI case
C_FP <- 1.0   # cost of false alarm

sample_w <- ifelse(train_y_resampled == 1, C_FN, C_FP)
#sample_w <- ifelse(train_y == 1, C_FN, C_FP)
sample_w <- sample_w / mean(sample_w)

# ----------------------------------------------------------------------------------------
# 5) Building DMatrix
# ----------------------------------------------------------------------------------------
dtrain <- xgb.DMatrix(
  data   = train_mat,
  label  = train_y_resampled,
#  weight = sample_w
)

dtest <- xgb.DMatrix(
  data  = test_mat,
  label = test_y
)

# ----------------------------------------------------------------------------------------
# 6) Params + CV for best nrounds
# ----------------------------------------------------------------------------------------
params <- list(
  objective        = "binary:logistic",
  eval_metric      = "logloss",
  max_depth        = 5,
  eta              = 0.05,
  subsample        = 0.9,
  colsample_bytree = 0.8,
  seed             = 123,
  min_child_weight = 1,
  gamma            = 0.1,
  lambda           = 1.0
)

set.seed(123)
cv <- xgb.cv(
  params  = params,
  data    = dtrain,
  nrounds = 500,
  nfold   = 5,
  early_stopping_rounds = 20,
  verbose = 0
)

best_nrounds <- cv$best_iteration
print(best_nrounds)
mean_logloss <- cv$evaluation_log$test_logloss_mean[best_nrounds]
sd_logloss   <- cv$evaluation_log$test_logloss_std[best_nrounds]
var_logloss  <- sd_logloss^2

cat("CV mean logloss:", round(mean_logloss, 4), "\n")
cat("CV SD logloss:", round(sd_logloss, 4), "\n")
cat("CV variance:", round(var_logloss, 5), "\n")

# ----------------------------------------------------------------------------------------
# 7) Train final model
# ----------------------------------------------------------------------------------------
xgb_model <- xgb.train(
  params  = params,
  data    = dtrain,
  nrounds = best_nrounds,
  verbose = 0,
)

# Also check after model training
cat("\n=== MODEL FEATURES ===\n")
print(length(xgb_model$feature_names))
print(xgb_model$feature_names[1:10])
# ----------------------------------------------------------------------------------------
# 7A) Feature importance/ranking
# ----------------------------------------------------------------------------------------
imp <- xgb.importance(
  model         = xgb_model,
  feature_names = colnames(train_mat)
)

# order by gain so first rows = most important by gain
imp <- imp %>%
  arrange(desc(Gain))

# focus plots on top 20 features by gain
imp20 <- imp %>%
  slice(1:20)

## ---- Gain plot (ggplot) ----
ggplot(imp20, aes(x = reorder(Feature, Gain), y = Gain)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "XGBoost Feature Importance (Gain)",
    x = "Feature",
    y = "Gain"
  ) +
  theme_minimal()

## ---- Cover plot (ggplot) ----
ggplot(imp20, aes(x = reorder(Feature, Cover), y = Cover)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "XGBoost Feature Importance (Cover)",
    x = "Feature",
    y = "Cover"
  ) +
  theme_minimal()

## ---- Frequency plot (ggplot) ----
ggplot(imp20, aes(x = reorder(Feature, Frequency), y = Frequency)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "XGBoost Feature Importance (Frequency)",
    x = "Feature",
    y = "Frequency"
  ) +
  theme_minimal()


# --------------------------------------------------------------------------------------------
# 7B) Predict + pick best threshold
# --------------------------------------------------------------------------------------------
pred_prob  <- predict(xgb_model, dtest) # raw prob score
train_prob <- predict(xgb_model, dtrain)
hist(pred_prob[test_y == 1]) 

roc_obj <- roc(response = train_y_resampled, predictor = train_prob)
#roc_obj <- roc(response = train_y, predictor = train_prob)
best_t  <- as.numeric(coords(roc_obj, "best", ret = "threshold"))
print(best_t) # best_t = probability cutoff (found on training ROC) that gives the best balance of sensitivity and specificity

# Predictions with the 'best' threshold --> kept this to show how cases differ acc to best_t
pred_class_best_t <- ifelse(pred_prob > best_t, 1, 0)
accuracy_best_t <- mean(pred_class_best_t == test_y)
cat("Accuracy (best_t threshold):", round(accuracy_best_t, 4), "\n")

# Predictions with 0.50 threshold
pred_class_5 <- ifelse(pred_prob > 0.50, 1, 0)
accuracy_5 <- mean(pred_class_5 == test_y)
cat("Accuracy (0.50 threshold):", round(accuracy_5, 4), "\n")

# ----------------------------------------------------------------------------------------
# 7C) Training metrics
# ----------------------------------------------------------------------------------------
train_pred <- predict(xgb_model, dtrain)
train_logloss <- LogLoss(train_pred, train_y_resampled)  # Capital L, reversed order
#train_logloss <- LogLoss(train_pred, train_y)  # Capital L, reversed order
cat("Training Log Loss:", round(train_logloss, 4), "\n")

train_pred_class <- ifelse(train_pred > 0.5, 1, 0)
train_accuracy <- mean(train_pred_class == train_y_resampled)
#train_accuracy <- mean(train_pred_class == train_y)
cat("Training Accuracy (0.5 threshold):", round(train_accuracy, 4), "\n")

# Add confusion matrix for training
train_cm <- table(Predicted = train_pred_class, Actual = train_y_resampled)
#train_cm <- table(Predicted = train_pred_class, Actual = train_y)
print("Training Confusion Matrix:")
print(train_cm)

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

# ------------------------------------------------------------------------------------------------
# 9B: Saving model and results and test data
# ------------------------------------------------------------------------------------------------
saveRDS(xgb_model,  "outputs/models/xgb_model.rds")
saveRDS(train_x_imp, "data/processed/train_x_imp.rds")
saveRDS(test_x_imp, "data/processed/test_x_imp.rds")
saveRDS(results,    "data/interim/results_test.rds")

saveRDS(pred_prob, "data/processed/pred_prob.rds")
saveRDS(pred_class_5, "data/processed/pred_class_5.rds") 
saveRDS(pred_class_best_t, "data/processed/pred_class_best_t.rds") 
saveRDS(test_y, "data/processed/test_y.rds")
