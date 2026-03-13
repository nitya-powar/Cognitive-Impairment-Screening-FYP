# Experiment Tracker

Use this file to record all model experiments consistently.

## How to use

- Keep one row per experiment run.
- Use one section for experiments before resampling and one for after resampling.
- Keep calibration, risk percentage, SHAP, and LIME results outside this table unless the model is the final selected model.

## Section 1: Before Resampling

| Exp ID | Data Version | Missingness Threshold | Feature Set | Model | Class Threshold | Train Size | Test Size | MCI % Train | MCI % Test | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | Log Loss | TP | FP | TN | FN | Worst Group | TPR Gap | FPR Gap | DPD | EOD | Notes |
|---|---|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---|
| B1 | `cleaned_data_for_modeling.RData` | 0.6 | cleaned full feature set | Random Forest | best_t = 0.496 | 1243 | 310 | 50.1 | 50.0 | 0.684 | 0.697 | 0.652 | 0.716 | 0.673 | 0.752 |  | 101 | 44 | 111 | 54 | Marital status (Education for DPD) | 0.555 | 0.900 | 0.631 | 0.555 | `mtry=11`, `ntree=500`, class weights `1.0/1.5`, OOB error `0.3556` |
| B2 | `cleaned_data_for_modeling.RData` | 0.6 | cleaned full feature set | XGBoost | best_t = 0.5778 | 1243 | 310 | 50.1 | 50.0 | 0.703 | 0.727 | 0.652 | 0.755 | 0.687 | 0.761 |  | 101 | 38 | 117 | 54 | Education | 0.591 | 0.920 | 0.751 | 0.591 | `best_nrounds=71`, CV mean logloss `0.5948`, train logloss `0.3273`, train acc `0.9485` |
| B3 |  |  |without marital status  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

## Section 2: After Resampling

| Exp ID | Data Version | Missingness Threshold | Feature Set | Resampling Rule | Groups Resampled | Rows Added | Model | Class Threshold | Train Size | Test Size | MCI % Train | MCI % Test | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | Log Loss | TP | FP | TN | FN | Worst Group | TPR Gap | FPR Gap | DPD | EOD | Notes |
|---|---|---:|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---|
| A1 | `cleaned_data_resampled.RData` | 0.6 | cleaned full feature set | Targeted MCI oversampling | `age 65-69`, `edu 4`, `edu 5` | 337 | XGBoost | best_t = 0.5354 | 1580 | 310 | 60.8 | 50.0 | 0.645 | 0.623 | 0.735 | 0.555 | 0.675 | 0.737 |  | 114 | 69 | 86 | 41 | Age (Education for DPD) | 0.456 | 0.765 | 0.571 | 0.456 | `best_nrounds=248`, CV mean logloss `0.4243`, train logloss `0.1056`, train acc `1.0000` |
| A2 | `cleaned_data_resampled.RData` | 0.6 | demographics + top lab features (34) | Targeted MCI oversampling | `age 65-69`, `edu 4`, `edu 5` | 337 | XGBoost | best_t = 0.6399 | 1580 | 310 | 60.8 | 50.0 | 0.677 | 0.717 | 0.587 | 0.768 | 0.645 | 0.752 |  | 91 | 36 | 119 | 64 | Education | 0.596 | 0.880 | 0.711 | 0.596 | `best_nrounds=328`, CV mean logloss `0.4106`, train logloss `0.0992`, train acc `0.9994` |
| A3 | `cleaned_data_resampled.RData` | 0.6 | demographics + top lab features (34) | Targeted MCI oversampling | `age 65-69`, `edu 4`, `edu 5` | 337 | XGBoost | best_t = 0.5118 | 1580 | 310 | 60.8 | 50.0 | 0.681 | 0.677 | 0.690 | 0.671 | 0.684 | 0.753 |  | 107 | 51 | 104 | 48 | Race (Education for DPD) | 0.450 | 0.820 | 0.612 | 0.450 | `best_nrounds=363`, no CSL, CV mean logloss `0.4511`, train logloss `0.0810`, train acc `1.0000` |
| A4 | `cleaned_data_resampled.RData` | 0.6 | demographics + top lab features (34) | Targeted MCI oversampling | `age 65-69`, `edu 4`, `edu 5` | 337 | XGBoost | best_t = 0.5719 | 1580 | 310 | 60.8 | 50.0 | 0.674 | 0.688 | 0.639 | 0.710 | 0.662 | 0.751 |  | 99 | 45 | 110 | 56 | Education | 0.517 | 0.800 | 0.652 | 0.517 | `best_nrounds=`, reduced depth/stronger regularization, train logloss `0.2383`, train acc `0.9639` |
| A5 | `cleaned_data_resampled.RData` | 0.6 | demographics + top lab features (34) | Targeted MCI oversampling | `age 65-69`, `edu 4`, `edu 5` | 337 | Random Forest | best_t = 0.528 | 1580 | 310 | 60.8 | 50.0 | 0.697 | 0.702 | 0.684 | 0.710 | 0.693 | 0.783 |  | 106 | 45 | 110 | 49 | Marital status (Race for DPD) | 0.578 | 0.860 | 0.482 | 0.578 | `mtry=18`, `ntree=500`, class weights `1.0/1.5`, OOB error `0.2000` |
| A6 | `cleaned_data_for_modeling.RData` | 0.6 | demographics + top lab features (34) | No resampling | none | 0 | Random Forest | best_t = 0.471 | 1243 | 310 | 50.1 | 50.0 | 0.723 | 0.714 | 0.742 | 0.703 | 0.728 | 0.784 |  | 115 | 46 | 109 | 40 | Age (Education for DPD) | 0.551 | 0.920 | 0.729 | 0.551 | `mtry=12`, `ntree=500`, class weights `1.0/1.5`, OOB error `0.3290` |
| A7 | `cleaned_data_for_modeling.RData` | 0.6 | demographics + top lab features (34) | No resampling | none | 0 | Random Forest | best_t = 0.493 | 1243 | 310 | 50.1 | 50.0 | 0.723 | 0.728 | 0.710 | 0.735 | 0.719 | 0.786 |  | 110 | 41 | 114 | 45 | Education (Marital status for FPR) | 0.610 | 0.923 | 0.780 | 0.610 | `mtry=12`, `ntree=500`, no class weights, OOB error `0.3266` |

## Group-Level Fairness Detail

Use a separate small table for each important experiment if you need per-group values.

| Exp ID | Demographic | Group | N | Positive Rate | TPR | FPR | FNR | TNR | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
|  |  |  |  |  |  |  |  |  |  |

## Final Model Only

Do not use this for every experiment. Fill this only for the selected final model.

| Final Model ID | Calibration Checked? | Brier Score | Calibration Plot Saved | Risk % Output Saved | SHAP Done? | LIME Done? | Notes |
|---|---|---:|---|---|---|---|---|
|  |  |  |  |  |  |  |  |
