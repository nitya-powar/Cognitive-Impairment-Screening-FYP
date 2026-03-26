# main runner for the XGB pipeline - this will run all files inside the XGB folder in sequence

source("scripts/02_model_development/XGB/xgb_data_and_features.R")
source("scripts/02_model_development/XGB/xgb_imputation.R")
source("scripts/02_model_development/XGB/xgb_training.R")
source("scripts/02_model_development/XGB/xgb_feature_importance.R")
source("scripts/02_model_development/XGB/xgb_evaluation.R")
source("scripts/02_model_development/XGB/xgb_exports.R")
