# Experiment Tracker

This file summarises the main model experiments and the decisions made from them.

## How to use

-   Keep one row for each experiment run.
-   Use Section 1 for runs before resampling and Section 2 for runs after resampling.
-   Add calibration, SHAP, and LIME only for the final selected model.

## Section 1: Before Resampling

These runs were done before any targeted resampling.

All runs below use the same preprocessing rule: columns with `>=60%` missing data were removed before modeling. Class weights were also used so false negatives were penalised more heavily.

| Exp ID | Data Version | Feature Set | Model | Class Threshold | Train Size | Test Size | MCI % Train | MCI % Test | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | Log Loss | TP | FP | TN | FN | Notes |
|----|----|----|----|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|----|
| B1 | `cleaned_data_for_modeling.RData` | cleaned full feature set (`68` vars) | Random Forest | best_t = 0.507 | 1243 | 310 | 50.1 | 50.0 | 0.713 | 0.750 | 0.639 | 0.787 | 0.690 | 0.765 |  | 99 | 33 | 122 | 56 | optimal `mtry=4`; `ntree=500`; type=`classification`; variables tried at each split=`4`; OOB error=`0.3500` (35.0%); OOB class error `No_MCI=0.3435`, `MCI=0.3563`; class weights `1.0/1.5`; best_t from CV=`0.507`; accuracy at `0.50=0.7097` |
| B2 | `cleaned_data_for_modeling.RData` | cleaned full feature set (`68` vars) | XGBoost | best_t = 0.6432 | 1243 | 310 | 50.1 | 50.0 | 0.681 | 0.755 | 0.535 | 0.826 | 0.626 | 0.766 | 0.4757 | 83 | 27 | 128 | 72 | best_nrounds=`45`; objective=`binary:logistic`; eval_metric=`logloss`; lambda=`1`; seed=`123`; max_depth=`3`; eta=`0.1`; subsample=`0.8`; colsample_bytree=`0.8`; min_child_weight=`3`; gamma=`0.1`; CV mean logloss=`0.5734`; CV SD=`0.0094`; CV variance=`0.00009`; best_t from CV=`0.6432`; accuracy at `0.50=0.6613`; train logloss=`0.4757`; train acc=`0.7989`; train confusion matrix TN=`423`, FN=`53`, FP=`197`, TP=`570` |
| B3 | `cleaned_data_for_modeling.RData` | reduced feature set (`24` vars: `10` labs + `5` demographics + `9` physical/examination vars) | Random Forest | best_t = 0.461 | 1243 | 310 | 50.1 | 50.0 | 0.684 | 0.659 | 0.761 | 0.606 | 0.707 | 0.758 |  | 118 | 61 | 94 | 37 | optimal `mtry=2`; `ntree=500`; type=`classification`; variables tried at each split=`2`; OOB error=`0.3459` (34.59%); OOB class error `No_MCI=0.3484`, `MCI=0.3435`; class weights `1.0/1.5`; best_t from CV=`0.461`; accuracy at `0.50=0.6871` |
| B4 | `cleaned_data_for_modeling.RData` | reduced feature set (`44` vars: `30` labs + `5` demographics + `9` physical/examination vars) | XGBoost | best_t = 0.5428 | 1243 | 310 | 50.1 | 50.0 | 0.706 | 0.703 | 0.716 | 0.697 | 0.709 | 0.776 | 0.4752 | 111 | 47 | 108 | 44 | best_nrounds=`51`; objective=`binary:logistic`; eval_metric=`logloss`; lambda=`1`; seed=`123`; max_depth=`3`; eta=`0.1`; subsample=`0.8`; colsample_bytree=`0.8`; min_child_weight=`3`; gamma=`0`; CV mean logloss=`0.5711`; CV SD=`0.0220`; CV variance=`0.00049`; best_t from CV=`0.5428`; accuracy at `0.50=0.6839`; train logloss=`0.4752`; train acc=`0.7844`; train confusion matrix TN=`414`, FN=`62`, FP=`206`, TP=`561` |

### Reduced RF Comparison

This table compares reduced-feature Random Forest runs. Each run uses `14` fixed demographic/examination variables plus the stated number of top lab features.

| Lab Features Kept | Total Features | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | TP | FP | TN | FN |
|------|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| Top 40 labs | 54 | 0.684 | 0.694 | 0.658 | 0.710 | 0.675 | 0.768 | 102 | 45 | 110 | 53 |
| Top 30 labs | 44 | 0.668 | 0.653 | 0.716 | 0.619 | 0.683 | 0.763 | 111 | 59 | 96 | 44 |
| Top 20 labs | 34 | 0.681 | 0.689 | 0.658 | 0.703 | 0.673 | 0.769 | 102 | 46 | 109 | 53 |
| Top 10 labs | 24 | 0.684 | 0.659 | 0.761 | 0.606 | 0.707 | 0.758 | 118 | 61 | 94 | 37 |

### Reduced XGB Comparison

This table compares reduced-feature XGBoost runs. Each run uses `14` fixed demographic/examination variables plus the stated number of top lab features.

| Lab Features Kept | Total Features | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | TP | FP | TN | FN |
|------|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| Top 40 labs | 54 | 0.671 | 0.779 | 0.477 | 0.865 | 0.592 | 0.761 | 74 | 21 | 134 | 81 |
| Top 30 labs | 44 | 0.706 | 0.703 | 0.716 | 0.697 | 0.709 | 0.776 | 111 | 47 | 108 | 44 |
| Top 20 labs | 34 | 0.687 | 0.730 | 0.594 | 0.781 | 0.655 | 0.770 | 92 | 34 | 121 | 63 |
| Top 10 labs | 24 | 0.700 | 0.725 | 0.645 | 0.755 | 0.683 | 0.777 | 100 | 38 | 117 | 55 |

### Section 1A: Fairness Comparison Before Resampling

This table compares subgroup fairness for the two main baseline models before any resampling decision was made. Values are shown as `B1 / B2`.

| Demographic Group | Total | MCI | No MCI | Selection (B1 / B2) | TPR (B1 / B2) | FPR (B1 / B2) | DPD (B1 / B2) | EOD (B1 / B2) | Fairness Issue | Resample? |
|-------|------:|------:|------:|-------|-------|-------|-------|-------|-------|-------|
| Age: 60-64 | 101 | 33 | 68 | 0.248 / 0.139 | 0.515 / 0.273 | 0.118 / 0.0735 | 0.566 / 0.652 | 0.487 / 0.610 | Under-selected | No |
| Age: 65-69 | 72 | 40 | 32 | 0.361 / 0.236 | 0.425 / 0.350 | 0.281 / 0.0938 | 0.566 / 0.652 | 0.487 / 0.610 | Consistent under-detection | Yes |
| Age: 70-74 | 56 | 27 | 29 | 0.446 / 0.500 | 0.667 / 0.667 | 0.241 / 0.345 | 0.566 / 0.652 | 0.487 / 0.610 | Higher false positives | No |
| Age: 75-79 | 38 | 21 | 17 | 0.553 / 0.447 | 0.762 / 0.571 | 0.294 / 0.294 | 0.566 / 0.652 | 0.487 / 0.610 | High false positives | No |
| Age: 80+ | 43 | 34 | 9 | 0.814 / 0.791 | 0.912 / 0.882 | 0.444 / 0.444 | 0.566 / 0.652 | 0.487 / 0.610 | Over-selection / high FPR | No |
| Education: Level 1 | 25 | 23 | 2 | 0.920 / 0.920 | 0.913 / 0.913 | 1.000 / 1.000 | 0.711 / 0.799 | 0.572 / 0.694 | Extreme over-selection | No |
| Education: Level 2 | 41 | 29 | 12 | 0.732 / 0.659 | 0.862 / 0.690 | 0.417 / 0.583 | 0.711 / 0.799 | 0.572 / 0.694 | High false positives | No |
| Education: Level 3 | 78 | 40 | 38 | 0.526 / 0.449 | 0.675 / 0.600 | 0.368 / 0.289 | 0.711 / 0.799 | 0.572 / 0.694 | Higher false positives | No |
| Education: Level 4 | 91 | 41 | 50 | 0.209 / 0.121 | 0.341 / 0.220 | 0.100 / 0.0400 | 0.711 / 0.799 | 0.572 / 0.694 | Severe under-detection | Yes |
| Education: Level 5 | 75 | 22 | 53 | 0.253 / 0.187 | 0.545 / 0.409 | 0.132 / 0.0943 | 0.711 / 0.799 | 0.572 / 0.694 | Under-detection | Yes |
| Gender: Male | 163 | 91 | 72 | 0.460 / 0.399 | 0.648 / 0.538 | 0.222 / 0.222 | 0.072 / 0.093 | 0.023 / 0.007 | No major issue | No |
| Gender: Female | 147 | 64 | 83 | 0.388 / 0.306 | 0.625 / 0.531 | 0.205 / 0.133 | 0.072 / 0.093 | 0.023 / 0.007 | No major issue | No |
| Race: Group 1 | 41 | 17 | 24 | 0.537 / 0.366 | 0.824 / 0.529 | 0.333 / 0.250 | 0.182 / 0.204 | 0.439 / 0.205 | Relatively favored group | No |
| Race: Group 2 | 24 | 17 | 7 | 0.542 / 0.417 | 0.647 / 0.529 | 0.286 / 0.143 | 0.182 / 0.204 | 0.439 / 0.205 | High selection relative to others | No |
| Race: Group 3 | 162 | 69 | 93 | 0.370 / 0.296 | 0.667 / 0.536 | 0.151 / 0.118 | 0.182 / 0.204 | 0.439 / 0.205 | Mild under-selection | No |
| Race: Group 4 | 58 | 39 | 19 | 0.483 / 0.500 | 0.590 / 0.590 | 0.263 / 0.316 | 0.182 / 0.204 | 0.439 / 0.205 | Higher false positives | No |
| Race: Group 5 | 25 | 13 | 12 | 0.360 / 0.320 | 0.385 / 0.385 | 0.333 / 0.250 | 0.182 / 0.204 | 0.439 / 0.205 | Lowest TPR / unstable | No |
| Marital: Married | 175 | 83 | 92 | 0.423 / 0.349 | 0.651 / 0.530 | 0.217 / 0.185 | 0.291 / 0.371 | 0.467 / 0.544 | No major issue | No |
| Marital: Widowed | 56 | 30 | 26 | 0.571 / 0.518 | 0.800 / 0.767 | 0.308 / 0.231 | 0.291 / 0.371 | 0.467 / 0.544 | Relatively favored group | No |
| Marital: Divorced | 50 | 24 | 26 | 0.280 / 0.200 | 0.500 / 0.417 | 0.0769 / 0.000 | 0.291 / 0.371 | 0.467 / 0.544 | Lower selection | No |
| Marital: Separated | 7 | 4 | 3 | 0.571 / 0.571 | 0.750 / 0.500 | 0.333 / 0.667 | 0.291 / 0.371 | 0.467 / 0.544 | Small group / unstable | No |
| Marital: Never married | 16 | 9 | 7 | 0.312 / 0.250 | 0.333 / 0.222 | 0.286 / 0.286 | 0.291 / 0.371 | 0.467 / 0.544 | Under-detection but small group | No |
| Marital: Living with partner | 6 | 5 | 1 | 0.500 / 0.333 | 0.600 / 0.400 | 0.000 / 0.000 | 0.291 / 0.371 | 0.467 / 0.544 | Very small group / unstable | No |

### Top Features

This table records the main feature-importance outputs for each baseline model.

| Exp ID | Importance Metric | Top Features |
|------------------------|------------------------|------------------------|
| B1 | Mean Decrease Gini | education_level, age_years, LBDBCDSI, LBDTCSI, LBDHDDSI, LBDSCRSI, LBDSGBSI, URDACT, grip_strength, LBXMMASI, LBXVIDMS, height, LBDGLUSI, weight, LBDTRSI, mean_dbp, LBXHCT, LBXPLTSI, LBXRDW, LBXHGB, LBDRFOSI, LBXVE3MS, LBDB12SI, LBDLDLSI, waist, mean_sbp, LBXSATSI, bmi, LBDSIRSI, LBXLYPCT, LBDBPBSI, LBXMCVSI, LBXGH, LBXMOPCT, LBDINSI, LBDBSESI, LBXRBCSI, LBXMCHSI, LBXNEPCT, LBDBMNSI, LBXSAPSI, LBDTHGSI, LBDSUASI, LBXWBCSI, LBXSGTSI, LBDSTPSI, LBDNENO, LBXMC, LBXMPSI, LBDLYMNO |
| B2 | XGBoost importance | education_level, age_years, race, LBDSGBSI, LBXMMASI, LBDHDDSI, LBDBCDSI, phq9_sum, LBDTCSI, LBDTRSI, LBDSCRSI, LBXHGB, LBXPLTSI, URDACT, grip_strength, LBXSATSI, height, gender, bmi, LBDB12SI, LBXVIDMS, LBDGLUSI, LBXVE3MS, LBDSIRSI, LBXRDW, mean_sbp, LBXGH, LBXLYPCT, LBDSBUSI, LBDLDLSI, LBXMOPCT, LBDSALSI, LBDSPHSI, LBXMCVSI, LBXMPSI, LBXRBCSI, LBDBSESI, LBDSUASI, waist, LBXHCT, LBDLYMNO, weight, LBDINSI, LBXNEPCT, LBXSAPSI, LBDRFOSI, LBXSOSSI, LBDBMNSI, LBDSTPSI, LBXSGTSI, LBDBPBSI |
| B3 | Mean Decrease Gini | age_years, education_level, LBDTCSI, URDACT, LBXMMASI, LBDSCRSI, LBDSGBSI, grip_strength, height, LBXVIDMS, mean_sbp, mean_dbp, LBDHDDSI, LBDBCDSI, LBDGLUSI, LBDTRSI, bmi, waist, weight, phq9_sum, race, marital_status, gender, phq9_depressed |
| B4 | XGBoost importance | education_level, age_years, race, LBXMMASI, LBDSGBSI, LBDHDDSI, LBDTCSI, phq9_sum, LBXHGB, LBDB12SI, LBXPLTSI, LBDSCRSI, gender, LBXLYPCT, LBXSATSI, LBXVE3MS, bmi, LBDSALSI, LBDGLUSI, LBXVIDMS, LBXHCT, height, grip_strength, LBDLDLSI, LBXMCVSI, URDACT, LBXRBCSI, LBDSIRSI, weight, LBDBSESI, LBXRDW, LBDSUASI, LBDSBUSI, mean_sbp, waist, LBDTRSI, LBXGH, mean_dbp, LBDSPHSI, LBXMPSI, LBXMOPCT, LBDBCDSI |

## Section 2: After Resampling

This section records the experiments after targeted MCI oversampling was applied to `age 65-69`, `education 4`, and `education 5`. Rows added are `324` for all runs.

For these rerun experiments, class weights were removed (`1.0 / 1.0`) because MCI cases were already upweighted through targeted oversampling.

| Exp ID | Data Version | Feature Set | Resampling Rule | Model | Class Threshold | Train Size | Test Size | MCI % Train | MCI % Test | Accuracy | Precision | Recall | Specificity | F1 | ROC-AUC | Log Loss | TP | FP | TN | FN | Notes |
|----|----|----|----|----|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|----|
| A1 | `cleaned_data_resampled.RData` | reduced feature set (`24` vars: `10` labs + `5` demographics + `9` physical/examination vars) | Targeted MCI oversampling | Random Forest | best_t = 0.647 | 1580 | 310 | 60.8 | 50.0 | 0.652 | 0.737 | 0.471 | 0.832 | 0.575 | 0.767 |  | 73 | 26 | 129 | 82 | optimal `mtry=11`; `ntree=500`; type=`classification`; variables tried at each split=`11`; OOB error=`0.2177` (21.77%); OOB class error `No_MCI=0.4581`, `MCI=0.0625`; class weights removed (`1.0/1.0`); best_t from CV=`0.647`; accuracy at `0.50=0.7097` |
| A2 | `cleaned_data_resampled.RData` | cleaned full feature set (`68` vars) | Targeted MCI oversampling | Random Forest | best_t = 0.667 | 1580 | 310 | 60.8 | 50.0 | 0.661 | 0.879 | 0.374 | 0.948 | 0.525 | 0.777 |  | 58 | 8 | 147 | 97 | optimal `mtry=24`; `ntree=500`; type=`classification`; variables tried at each split=`24`; OOB error=`0.2089` (20.89%); OOB class error `No_MCI=0.4742`, `MCI=0.0375`; class weights removed (`1.0/1.0`); best_t from CV=`0.667`; accuracy at `0.50=0.6968` |
| A3 | `cleaned_data_resampled.RData` | cleaned full feature set (`68` vars) | Targeted MCI oversampling | XGBoost | best_t = 0.7537 | 1580 | 310 | 60.8 | 50.0 | 0.671 | 0.805 | 0.452 | 0.890 | 0.579 | 0.752 | 0.1158 | 70 | 17 | 138 | 85 | best_nrounds=`239`; objective=`binary:logistic`; eval_metric=`logloss`; lambda=`1`; seed=`123`; max_depth=`5`; eta=`0.05`; subsample=`0.8`; colsample_bytree=`0.8`; min_child_weight=`1`; gamma=`0.1`; CV mean logloss=`0.4849`; CV SD=`0.0375`; CV variance=`0.00141`; best_t from CV=`0.7537`; accuracy at `0.50=0.6613`; train logloss=`0.1158`; train acc=`1.0000`; train confusion matrix TN=`620`, FN=`0`, FP=`0`, TP=`960`; class weights removed (`1.0/1.0`) |
| A4 | `cleaned_data_resampled.RData` | reduced feature set (`44` vars: `30` labs + `5` demographics + `9` physical/examination vars) | Targeted MCI oversampling | XGBoost | best_t = 0.7122 | 1580 | 310 | 60.8 | 50.0 | 0.687 | 0.784 | 0.516 | 0.858 | 0.623 | 0.757 | 0.1151 | 80 | 22 | 133 | 75 | best_nrounds=`134`; objective=`binary:logistic`; eval_metric=`logloss`; lambda=`1`; seed=`123`; max_depth=`5`; eta=`0.1`; subsample=`0.8`; colsample_bytree=`0.8`; min_child_weight=`1`; gamma=`0.1`; CV mean logloss=`0.4841`; CV SD=`0.0330`; CV variance=`0.00109`; best_t from CV=`0.7122`; accuracy at `0.50=0.6806`; train logloss=`0.1151`; train acc=`1.0000`; train confusion matrix TN=`620`, FN=`0`, FP=`0`, TP=`960`; class weights removed (`1.0/1.0`) |

## Group-Level Fairness Detail

This table gives the detailed fairness results for the selected model.

Selected final model: `B3`.

| Exp ID | Demographic | Group | N | Selection | TPR | FPR | DPD | EOD | FPR Diff | Notes |
|-------|-------|-------|------:|------:|------:|------:|------:|------:|------:|-------|
| B3 | Age | 60-64 | 101 | 0.386 | 0.636 | 0.265 | 0.521 | 0.346 | 0.441 | Lower selection than older groups |
| B3 | Age | 65-69 | 72 | 0.500 | 0.625 | 0.344 | 0.521 | 0.346 | 0.441 | Mid-range selection and error rates |
| B3 | Age | 70-74 | 56 | 0.625 | 0.778 | 0.483 | 0.521 | 0.346 | 0.441 | Higher FPR than younger groups |
| B3 | Age | 75-79 | 38 | 0.789 | 0.857 | 0.706 | 0.521 | 0.346 | 0.441 | High selection and high FPR |
| B3 | Age | 80+ | 43 | 0.907 | 0.971 | 0.667 | 0.521 | 0.346 | 0.441 | Highest selection, near-max TPR |
| B3 | Education | Level 1 | 25 | 1.000 | 1.000 | 1.000 | 0.725 | 0.561 | 0.860 | Extreme over-selection |
| B3 | Education | Level 2 | 41 | 0.902 | 0.931 | 0.833 | 0.725 | 0.561 | 0.860 | Very high FPR |
| B3 | Education | Level 3 | 78 | 0.782 | 0.900 | 0.658 | 0.725 | 0.561 | 0.860 | High selection and FPR |
| B3 | Education | Level 4 | 91 | 0.275 | 0.439 | 0.140 | 0.725 | 0.561 | 0.860 | Strong under-detection |
| B3 | Education | Level 5 | 75 | 0.413 | 0.636 | 0.321 | 0.725 | 0.561 | 0.860 | Lower selection than Levels 1-3 |
| B3 | Gender | Male | 163 | 0.644 | 0.791 | 0.458 | 0.141 | 0.072 | 0.121 | Slightly higher selection and FPR |
| B3 | Gender | Female | 147 | 0.503 | 0.719 | 0.337 | 0.141 | 0.072 | 0.121 | Smaller gender gap than other demographics |
| B3 | Race | Code 1 | 41 | 0.634 | 0.824 | 0.500 | 0.249 | 0.099 | 0.376 | Higher TPR with elevated FPR |
| B3 | Race | Code 2 | 24 | 0.667 | 0.765 | 0.429 | 0.249 | 0.099 | 0.376 | Higher selection than most race groups |
| B3 | Race | Code 3 | 162 | 0.475 | 0.725 | 0.290 | 0.249 | 0.099 | 0.376 | Lowest selection among larger groups |
| B3 | Race | Code 4 | 58 | 0.724 | 0.795 | 0.579 | 0.249 | 0.099 | 0.376 | Highest FPR among race groups |
| B3 | Race | Code 6 | 25 | 0.720 | 0.769 | 0.667 | 0.249 | 0.099 | 0.376 | Small group with very high FPR |
| B3 | Marital | Married | 175 | 0.589 | 0.759 | 0.435 | 0.214 | 0.233 | 0.731 | Largest group, mid-range performance |
| B3 | Marital | Widowed | 56 | 0.607 | 0.833 | 0.346 | 0.214 | 0.233 | 0.731 | Higher TPR with moderate FPR |
| B3 | Marital | Divorced | 50 | 0.500 | 0.750 | 0.269 | 0.214 | 0.233 | 0.731 | Lower selection than married/widowed |
| B3 | Marital | Separated | 7 | 0.714 | 0.750 | 0.667 | 0.214 | 0.233 | 0.731 | Very small group, unstable |
| B3 | Marital | Never married | 16 | 0.500 | 0.667 | 0.286 | 0.214 | 0.233 | 0.731 | Small group, lower TPR than top groups |
| B3 | Marital | Living with partner | 6 | 0.667 | 0.600 | 1.000 | 0.214 | 0.233 | 0.731 | Very small group, extreme FPR |

## Final Model Only

This section is only for the final selected model.

| Final Model ID | Calibration Checked? | Brier Score | Calibration Plot Saved | SHAP Done? | LIME Done? | Notes |
|-----------|-----------|----------:|-----------|-----------|-----------|-----------|
| B3 | Yes | 0.207 | Yes | Yes | Yes | ECE=`0.0645`; wrongly overconfident predictions=`0.3%`; SHAP and LIME entries still need to be refreshed for `B3`. |
