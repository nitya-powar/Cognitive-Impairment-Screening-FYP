# Scripts Guide

This folder contains the main analysis pipeline for the project.\
The scripts are grouped by stage so it is easier to follow the work from data preparation to modelling, evaluation, and explainability.

## `01_data_preparation/`

This folder builds the dataset used for modelling.

-   `01_demo_and_label_creation.R`\
    Creates the base dataset from demographics and cognitive test variables.

-   `02_merge_labs.R`\
    Merges the laboratory data into the base dataset.

-   `03_merge_examination_vars.R`\
    Adds examination and questionnaire variables such as blood pressure, body measures, grip strength, and PHQ-9.

-   `04_demographics_histograms.R`\
    Creates the first set of demographic summary plots from the full dataset.

-   `05_missingness_analysis_and_data_cleaning.R`\
    Checks missing-data patterns, removes sparse columns, and saves the cleaned dataset.

-   `06_train_and_test_split.R`\
    Splits the cleaned data into training and test sets.

-   `07_demographic_visualisation_training_set.R`\
    Creates demographic plots for the cleaned training set.

-   `DEMO_COG_LABEL_DATA.md`\
    Notes about the demographic and cognitive label data used in the first step.

-   `FEATURE_KEEP_REMOVE_TRACKER.md`\
    Record of which lab features were kept or removed from each raw lab file.

## `02_model_development/`

This folder contains the model-building work.

-   `Random_Forest.R`\
    Main runner for the Random Forest pipeline.

-   `XGBoost.R`\
    Main runner for the XGBoost pipeline.

-   `resampling_features.R`\
    Creates the targeted resampled training set used for the fairness-focused experiments.

### `02_model_development/RF/`

This is the split Random Forest workflow.

-   `rf_data_and_features.R`\
    Loads the modelling data and selects the feature set.

-   `rf_imputation.R`\
    Runs missRanger imputation on the training and test data.

-   `rf_training.R`\
    Tunes and trains the final Random Forest model.

-   `rf_evaluation.R`\
    Calculates predictions, thresholds, metrics, ROC, and error groups.

-   `rf_exports.R`\
    Saves the trained model and exported RF outputs.

### `02_model_development/XGB/`

This is the split XGBoost workflow.

-   `xgb_data_and_features.R`\
    Loads the modelling data and selects the feature set.

-   `xgb_imputation.R`\
    Runs missRanger imputation on the training and test data.

-   `xgb_training.R`\
    Prepares matrices, tunes hyperparameters, and trains the final XGBoost model.

-   `xgb_feature_importance.R`\
    Creates and prints the XGBoost feature-importance outputs.

-   `xgb_evaluation.R`\
    Calculates thresholds, metrics, ROC, and error groups.

-   `xgb_exports.R`\
    Saves the trained model and exported XGBoost outputs.

## `03_evaluation_and_reporting/`

This folder contains the evaluation scripts used after model training.

-   `fairness_evaluation.R`\
    Compares fairness metrics across demographic groups.

-   `model_calibration.R`\
    Checks model calibration using Brier score, ECE, and a calibration curve.

## `04_explainability_and_error_analysis/`

This folder contains the scripts used to understand model behaviour and mistakes.

-   `SHAP.R`\
    Creates the global SHAP summary for the Random Forest model.

-   `LIME.R`\
    Generates local LIME explanations for selected prediction cases.

-   `demographics_error_analysis_histogram.R`\
    Creates demographic histograms for the RF true positive, false positive, false negative, and true negative groups.

## Other file

-   `EXPERIMENT_TRACKER.md`\
    Main record of the experiments, results, and model comparisons.
