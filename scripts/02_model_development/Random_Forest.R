# main runner for the RF pipeline - this will run all files inside the RF folder in sequence

source("scripts/02_model_development/RF/rf_data_and_features.R")
source("scripts/02_model_development/RF/rf_imputation.R")
source("scripts/02_model_development/RF/rf_training.R")
source("scripts/02_model_development/RF/rf_evaluation.R")
source("scripts/02_model_development/RF/rf_exports.R")

