library(pROC)
library(MLmetrics)

# ----------------------------------------------------------------------------------------
# Threshold selection and training diagnostics
# ----------------------------------------------------------------------------------------
pred_prob  <- predict(xgb_model, dtest)

roc_obj <- roc(response = train_y, predictor = cv_pred)
#roc_obj <- roc(response = train_y_resampled, predictor = cv_pred)
best_t  <- as.numeric(coords(roc_obj, "best", ret = "threshold"))

pred_class_best_t <- ifelse(pred_prob > best_t, 1, 0)
accuracy_best_t <- mean(pred_class_best_t == test_y)
cat("Accuracy (best_t threshold):", round(accuracy_best_t, 4), "\n")

pred_class_5 <- ifelse(pred_prob > 0.50, 1, 0)
accuracy_5 <- mean(pred_class_5 == test_y)
cat("Accuracy (0.50 threshold):", round(accuracy_5, 4), "\n")

train_pred <- predict(xgb_model, dtrain)
#train_logloss <- LogLoss(train_pred, train_y_resampled)
train_logloss <- LogLoss(train_pred, train_y)
cat("Training Log Loss:", round(train_logloss, 4), "\n")

train_pred_class <- ifelse(train_pred > 0.5, 1, 0)
#train_accuracy <- mean(train_pred_class == train_y_resampled)
train_accuracy <- mean(train_pred_class == train_y)
cat("Training Accuracy (0.5 threshold):", round(train_accuracy, 4), "\n")

train_cm <- table(Predicted = train_pred_class, Actual = train_y)
print(train_cm)

# ----------------------------------------------------------------------------------------
# Error groups
# ----------------------------------------------------------------------------------------
results <- data.frame(
  actual   = test_y,
  predicted = pred_class_best_t
)

results$case <- NA
results$case[results$actual == 1 & results$predicted == 1] <- "TP"
results$case[results$actual == 0 & results$predicted == 1] <- "FP"
results$case[results$actual == 1 & results$predicted == 0] <- "FN"
results$case[results$actual == 0 & results$predicted == 0] <- "TN"

FP_data <- test_x_imp[results$case == "FP", ]
TP_data <- test_x_imp[results$case == "TP", ]
TN_data <- test_x_imp[results$case == "TN", ]
FN_data <- test_x_imp[results$case == "FN", ]

write.csv(TP_data, "data/processed/error_groups/XGB/TP_data.csv", row.names = FALSE)
write.csv(FP_data, "data/processed/error_groups/XGB/FP_data.csv", row.names = FALSE)
write.csv(FN_data, "data/processed/error_groups/XGB/FN_data.csv", row.names = FALSE)
write.csv(TN_data, "data/processed/error_groups/XGB/TN_data.csv", row.names = FALSE)

# ----------------------------------------------------------------------------------------
# Test metrics
# ----------------------------------------------------------------------------------------
calculate_metrics <- function(results_df) {
  TP <- sum(results_df$case == "TP")
  FP <- sum(results_df$case == "FP")
  FN <- sum(results_df$case == "FN")
  TN <- sum(results_df$case == "TN")
  
  precision <- TP / (TP + FP)
  recall    <- TP / (TP + FN)
  F1        <- 2 * (precision * recall) / (precision + recall)
  specificity <- TN / (TN + FP)
  c(Precision = precision, Recall = recall, F1 = F1, Specificity = specificity)
}

metrics <- calculate_metrics(results)
cat("Precision:", round(metrics["Precision"], 3), "\n")
cat("Recall:", round(metrics["Recall"], 3), "\n")
cat("Specificity:", round(metrics["Specificity"], 3), "\n")
cat("F1 Score:", round(metrics["F1"], 3), "\n")

roc_obj_test <- roc(response = test_y, predictor = pred_prob)
auc_value <- auc(roc_obj_test)
cat("ROC AUC:", round(auc_value, 3), "\n")

plot(
  roc_obj_test,
  main = paste("ROC Curve (AUC =", round(auc_value, 3), ")"),
  print.auc = TRUE,
  auc.polygon = TRUE,
  max.auc.polygon = TRUE,
  grid = TRUE,
  legacy.axes = TRUE
)

abline(a = 0, b = 1, lty = 2, col = "red")
