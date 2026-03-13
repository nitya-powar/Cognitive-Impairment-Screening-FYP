library(SHAPforxgboost)

# ------------------------------------------------------------------------------------------------------
# Loading objects saved from model script
# ------------------------------------------------------------------------------------------------------

# The trained XGBoost model used for predictions
xgb_model  <- readRDS('/outputs/models/xgb_model.rds')

# Clean test data (imputed features, no imp label ofc)
test_x_imp <- readRDS('/data/processed/test_x_imp.rds')

# Model predictions vs actual labels with error classification (actual, predicted and case)
results    <- readRDS('/data/interim/results_test.rds')

# ------------------------------------------------------------------------------------------------------
# Calculate SHAP values
# ------------------------------------------------------------------------------------------------------

# convert test data to matrix format required by SHAP calculation
X_test <- as.matrix(test_x_imp)

# Calculate SHAP values for test set predictions
shap_test <- shap.values(
  xgb_model = xgb_model,
  X_train   = X_test
)

# Convert SHAP values to long format for plotting (top 20 features only)
shap_long_test <- shap.prep(
  shap_contrib = shap_test$shap_score,
  X_train      = X_test, # Using test set features for SHAP calculation
  top_n        = 20
)

# ------------------------------------------------------------------------------------------------------
# Verify if SHAP values correspond to patient's predicted values
# ------------------------------------------------------------------------------------------------------

cat("SHAP data rows:", nrow(shap_long_test), "\n") # patients x 20
cat("Results rows:  ", nrow(results), "\n") # count of total test patients
cat("Do IDs match? ", all(shap_long_test$ID == 1:nrow(results)), "\n")

# Check the first few IDs
print(head(shap_long_test$ID))
print(head(1:nrow(results)))

# ------------------------------------------------------------------------------------------------------
# Plotting
# ------------------------------------------------------------------------------------------------------

# Label each SHAP value row with its error type (TP/FP/FN/TN) using patient ID matching
shap_long_test$group <- results$case[shap_long_test$ID]

# Split SHAP values into four groups for error-specific analysis
shap_FP <- shap_long_test[shap_long_test$group == "FP", ]
shap_FN <- shap_long_test[shap_long_test$group == "FN", ]
shap_TP <- shap_long_test[shap_long_test$group == "TP", ]
shap_TN <- shap_long_test[shap_long_test$group == "TN", ]

# plots for dissertation
shap.plot.summary(shap_FP)  # false positives
shap.plot.summary(shap_FN)  # false negatives
shap.plot.summary(shap_TP)  # true positives
shap.plot.summary(shap_TN)  # true positives

# ------------------------------------------------------------------------------------------------------
# Saving plots to "outputs/figures/error_analysis_SHAP"
# ------------------------------------------------------------------------------------------------------

png("outputs/figures/error_analysis_SHAP/FP_SHAP.png", width = 800, height = 600)
shap.plot.summary(shap_FP)
dev.off()

png("outputs/figures/error_analysis_SHAP/FN_SHAP.png", width = 800, height = 600)
shap.plot.summary(shap_FN)
dev.off()

png("outputs/figures/error_analysis_SHAP/TP_SHAP.png", width = 800, height = 600)
shap.plot.summary(shap_TP)
dev.off()

png("outputs/figures/error_analysis_SHAP/TN_SHAP.png", width = 800, height = 600)
shap.plot.summary(shap_TN)
dev.off()