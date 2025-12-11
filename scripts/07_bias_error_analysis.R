library(SHAPforxgboost)

# load objects saved from model script
xgb_model  <- readRDS('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/outputs/models/xgb_model.rds')
test_x_imp <- readRDS('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/processed/test_x_imp.rds')
results    <- readRDS('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/interim/results_test.rds')

# SHAP for test set
X_test <- as.matrix(test_x_imp)

shap_test <- shap.values(
  xgb_model = xgb_model,
  X_train   = X_test
)

shap_long_test <- shap.prep(
  shap_contrib = shap_test$shap_score,
  X_train      = X_test,
  top_n        = 20
)

# add error-group label (TP / FP / FN / TN)
shap_long_test$group <- results$case[shap_long_test$ID]

shap_FP <- shap_long_test[shap_long_test$group == "FP", ]
shap_FN <- shap_long_test[shap_long_test$group == "FN", ]
shap_TP <- shap_long_test[shap_long_test$group == "TP", ]
shap_TN <- shap_long_test[shap_long_test$group == "TN", ]

# plots for dissertation
shap.plot.summary(shap_FP)  # false positives
shap.plot.summary(shap_FN)  # false negatives
shap.plot.summary(shap_TP)  # true positives
shap.plot.summary(shap_TN)  # true positives