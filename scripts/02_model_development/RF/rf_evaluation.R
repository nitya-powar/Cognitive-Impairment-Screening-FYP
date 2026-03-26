library(pROC)

# ----------------------------------------------------------------------------------------
# Generate probabilities and training diagnostics
# ----------------------------------------------------------------------------------------
pred_prob <- predict(final_rf, test_x_imp, type = "prob")[, "CI"]

cat("Random Forest trained with", final_rf$ntree, "trees\n")
cat("OOB error rate:", round(final_rf$err.rate[final_rf$ntree, "OOB"], 4), "\n")

# ----------------------------------------------------------------------------------------
# Training metrics
# ----------------------------------------------------------------------------------------
train_pred_prob <- predict(final_rf, train_x_imp, type = "prob")[, "CI"]
train_logloss <- calc_logloss(train_y_factor, train_pred_prob)
cat("Training Log Loss:", round(train_logloss, 4), "\n")

# ----------------------------------------------------------------------------------------
# 5) Threshold selection
# ----------------------------------------------------------------------------------------
cv_pred <- rf_tune$pred
roc_obj <- roc(response = cv_pred$obs, predictor = cv_pred$CI)
best_t  <- as.numeric(coords(roc_obj, "best", ret = "threshold"))
train_pred_class_best_t <- ifelse(train_pred_prob > best_t, 1, 0)
train_accuracy_best_t <- mean(train_pred_class_best_t == train_y)
cat("Training Accuracy (best_t threshold):", round(train_accuracy_best_t, 4), "\n")

pred_class_best_t <- ifelse(pred_prob > best_t, 1, 0)
accuracy_best_t <- mean(pred_class_best_t == test_y)
cat("Accuracy (best_t threshold):", round(accuracy_best_t, 4), "\n")

pred_class_5 <- ifelse(pred_prob > 0.50, 1, 0)
accuracy_5 <- mean(pred_class_5 == test_y)
cat("Accuracy (0.50 threshold):", round(accuracy_5, 4), "\n")

# ----------------------------------------------------------------------------------------
# 6) Error groups
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

write.csv(TP_data, "data/processed/error_groups/RF/TP_data.csv", row.names = FALSE)
write.csv(FP_data, "data/processed/error_groups/RF/FP_data.csv", row.names = FALSE)
write.csv(FN_data, "data/processed/error_groups/RF/FN_data.csv", row.names = FALSE)
write.csv(TN_data, "data/processed/error_groups/RF/TN_data.csv", row.names = FALSE)

# ----------------------------------------------------------------------------------------
# 7) Metrics
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

plot(roc_obj_test, 
     main = paste("ROC Curve (AUC =", round(auc_value, 3), ")"),
     print.auc = TRUE,
     auc.polygon = TRUE,
     max.auc.polygon = TRUE,
     grid = TRUE,
     legacy.axes = TRUE)

abline(a = 0, b = 1, lty = 2, col = "red")
