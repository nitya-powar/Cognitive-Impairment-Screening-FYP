library(caret)
library(dplyr)
library(randomForest)

# ----------------------------------------------------------------------------------------
# Train Random Forest
# ----------------------------------------------------------------------------------------
train_y_factor <- as.factor(train_y)
#train_y_factor <- as.factor(train_y_resampled)
levels(train_y_factor) <- c("No_CI", "CI")

train_data <- data.frame(train_x_imp, cog_impair = train_y_factor)

# Tune hyperparameters with cross-validation
set.seed(123)
fitControl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

n_pred <- ncol(train_x_imp)
sqrt_pred <- round(sqrt(n_pred))

rf_tune <- train(
  cog_impair ~ .,
  data = train_data,
  method = "rf",
  trControl = fitControl,
  tuneGrid = data.frame(mtry = unique(pmax(1, round(seq(sqrt_pred / 2, min(n_pred, sqrt_pred * 3), length.out = 7))))),
  classwt = c("No_CI" = 1.0, "CI" = 1.5),
#  classwt = c("No_CI" = 1.0, "CI" = 1.0),
  ntree = 500,
  metric = "Sens"
)

best_mtry <- rf_tune$bestTune$mtry
cat("Optimal mtry found by CV:", best_mtry, "\n")

# ----------------------------------------------------------------------------------------
# CV log loss summary
# ----------------------------------------------------------------------------------------
calc_logloss <- function(actual, prob_mci) {
  actual_num <- ifelse(actual == "CI", 1, 0)
  prob_mci <- pmin(pmax(prob_mci, 1e-15), 1 - 1e-15)
  -mean(actual_num * log(prob_mci) + (1 - actual_num) * log(1 - prob_mci))
}

cv_pred_best <- rf_tune$pred %>%
  filter(mtry == best_mtry)

mean_logloss <- calc_logloss(cv_pred_best$obs, cv_pred_best$CI)

cv_fold_logloss <- cv_pred_best %>%
  group_by(Resample) %>%
  summarise(logloss = calc_logloss(obs, CI), .groups = "drop")

sd_logloss <- sd(cv_fold_logloss$logloss)
var_logloss <- sd_logloss^2

cat("CV mean logloss:", round(mean_logloss, 4), "\n")
cat("CV SD logloss:", round(sd_logloss, 4), "\n")
cat("CV variance:", round(var_logloss, 5), "\n")

# ----------------------------------------------------------------------------------------
# Train the final Random Forest using the selected settings
# ----------------------------------------------------------------------------------------
final_rf <- randomForest(
  x = train_x_imp,
  y = train_y_factor,
  ntree = 500,
  mtry = best_mtry,
  importance = TRUE,
  classwt = c("No_CI" = 1.0, "CI" = 1.5),
#  classwt = c("No_CI" = 1.0, "CI" = 1.0),
  keep.forest = TRUE
)

print(final_rf)

imp <- importance(final_rf)
top_gini <- imp[order(-imp[, "MeanDecreaseGini"]), ]
print(head(top_gini, 50))

varImpPlot(final_rf, main = "Random Forest Feature Importance")
