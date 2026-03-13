# ----------------------------------------------------------------------------------------
# 1) Setup
# ----------------------------------------------------------------------------------------
library(lime)
library(dplyr)
library(randomForest)
# library(xgboost)
# ----------------------------------------------------------------------------------------
# 2) Load data and model
# ----------------------------------------------------------------------------------------
# model <- readRDS('outputs/models/xgb_model.rds') 
model <- readRDS('outputs/models/random_forest_model.rds')
# pred_prob <- readRDS('data/processed/pred_prob.rds')
pred_prob <- readRDS('data/processed/pred_prob_RF.rds')

test_y <- readRDS('data/processed/test_y.rds')
# test_df <- readRDS('data/processed/test_x_imp.rds')
test_df <- readRDS('data/processed/test_x_imp_RF.rds')
test_df <- as.data.frame(test_df)

# Load LIME explainer (save it first from your LIME file!)
# explainer <- readRDS('outputs/lime_explainer_XGB.rds')
explainer <- readRDS('outputs/lime_explainer_RF.rds')

# ----------------------------------------------------------------------------------------
# 3) LIME model interface for RF
# ----------------------------------------------------------------------------------------
model_type.randomForest <- function(x, ...) "classification"
predict_model.randomForest <- function(x, newdata, ...) {
  as.data.frame(predict(x, newdata, type = "prob"))
}

# ----------------------------------------------------------------------------------------
# 4) Define risk bands (5 levels)
# ----------------------------------------------------------------------------------------
risk_cutoffs <- c(0, 0.2, 0.4, 0.6, 0.8, 1.0)
risk_labels <- c("Very Low", "Low", "Medium", "High", "Very High")

# ----------------------------------------------------------------------------------------
# 5) Calculate top 3 features for each patient (fast batch)
# ----------------------------------------------------------------------------------------
get_top_features_fast <- function(patient_idx) {
  patient_data <- test_df[patient_idx, , drop = FALSE]
  
  explanation <- lime::explain(
    patient_data,
    explainer = explainer,
    n_features = 10,  # Get more to filter
    n_labels = 1
  )
  
  # Get predicted class
  pred_prob <- predict(model, patient_data, type = "prob")[, "MCI"]
  pred_class <- ifelse(pred_prob > 0.5, "MCI", "No_MCI")
  
  # Filter: Only features SUPPORTING the prediction
  if(pred_class == "MCI") {
    supporting <- explanation[explanation$feature_weight > 0, ]
  } else {
    supporting <- explanation[explanation$feature_weight < 0, ]
  }
  
  # Take top 3 supporting features
  top_supporting <- head(supporting$feature, 3)
  return(paste(top_supporting, collapse = ", "))
}

# Calculate for all patients (this might take 1-2 minutes)
cat("Calculating top features for", length(pred_prob), "patients...\n")
top_features <- sapply(1:length(pred_prob), get_top_features_fast)

# ----------------------------------------------------------------------------------------
# 6) Create final risk output
# ----------------------------------------------------------------------------------------
risk_output <- data.frame(
  Patient_ID = 1:length(pred_prob),
  Probability = round(pred_prob, 3),
  Risk_Band = cut(pred_prob, 
                  breaks = risk_cutoffs, 
                  labels = risk_labels,
                  include.lowest = TRUE),
  Top_Features = top_features,
  Actual_MCI = test_y,
  stringsAsFactors = FALSE
)

# ----------------------------------------------------------------------------------------
# 7) Save results
# ----------------------------------------------------------------------------------------
saveRDS(risk_output, 
        'outputs/risk_predictions.rds')

# Also save as CSV for easy viewing
write.csv(risk_output, 
          'outputs/risk_predictions.csv',
          row.names = FALSE)

# ----------------------------------------------------------------------------------------
# 8) Summary
# ----------------------------------------------------------------------------------------
cat("\n=== RISK PREDICTION SUMMARY ===\n")
cat("Total patients:", nrow(risk_output), "\n")
cat("Risk distribution:\n")
print(table(risk_output$Risk_Band))
cat("\nFirst 5 patients:\n")
print(head(risk_output, 5))

cat("\nOutput saved to:\n")
cat("1. outputs/risk_predictions.rds (for web app)\n")
cat("2. outputs/risk_predictions.csv (for viewing)\n")
