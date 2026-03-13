# Scripts Organization

This folder is now grouped by project stage so the pipeline is easier to navigate.

## Structure

### `00_docs/`

-   `readme.html`: rendered version of the original notes

### Top-level notes

-   `SCRIPT_NOTES.md`: your original script notes and data-field mapping

### `01_data_preparation/`

-   `01_data_cleaning.R`: builds the cleaned laboratory dataset
-   `02_data_cleaning_conditions.R`: adds condition-related variables
-   `data_edge_impulse.R`: prepares the imputed export used for external inference/testing

### `02_exploration/`

-   `03_initial_demographics_data_analysis.R`: early demographic EDA
-   `04_missingness_analysis.R`: missingness patterns, bias checks, and final train/test dataset creation

### `03_model_development/`

-   `04_B_resampling_testing.R`: balancing/resampling preparation
-   `05_train_Random_Forest.R`: Random Forest training and prediction artifacts
-   `05_train_XGB.R`: XGBoost training and prediction artifacts

### `04_explainability_and_error_analysis/`

-   `06_SHAP_error_analysis.R`: SHAP analysis focused on model errors
-   `07_SHAP_global_analysis.R`: global SHAP feature importance
-   `08_demographics_error_analysis_histogram.R`: histogram-based demographic error analysis
-   `08_demographics_error_analysis_text.R`: text/table demographic error analysis
-   `10_LIME.R`: local explanations for selected predictions

### `05_evaluation_and_reporting/`

-   `09_fairness.R`: fairness analysis across demographic groups
-   `11_risk_percentage_calculation.R`: patient-level risk percentage outputs
-   `12_model_calibration.R`: calibration checks and calibration curve

## Suggested workflow

1.  Run scripts in `01_data_preparation/`
2.  Review `02_exploration/`
3.  Train models in `03_model_development/`
4.  Interpret model behavior with `04_explainability_and_error_analysis/`
5.  Finish with `05_evaluation_and_reporting/`
