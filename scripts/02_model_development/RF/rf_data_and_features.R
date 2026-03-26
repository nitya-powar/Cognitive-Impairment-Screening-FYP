load("data/processed/cleaned_data_for_modeling.RData")
# load("data/processed/cleaned_data_resampled.RData")

# Reduced feature set for baseline comparison
top_lab_features <- c(
  "LBDBCDSI", "LBDTCSI", "LBDHDDSI", "LBDSCRSI", "LBDSGBSI",
  "URDACT", "LBXMMASI", "LBXVIDMS", "LBDGLUSI", "LBDTRSI" # top 10
  #, "LBXHCT", "LBXPLTSI", "LBXRDW", "LBXHGB", "LBDRFOSI",
  # "LBXVE3MS", "LBDB12SI", "LBDLDLSI", "LBXSATSI", "LBDSIRSI" # top 20
  # ",LBXLYPCT", "LBDBPBSI", "LBXMCVSI", "LBXGH", "LBXMOPCT",
  # "LBDINSI", "LBDBSESI", "LBXRBCSI", "LBXMCHSI", "LBXNEPCT" # top 30
  # , "LBDBMNSI", "LBXSAPSI", "LBDTHGSI", "LBDSUASI", "LBXWBCSI",
  # "LBXSGTSI", "LBDSTPSI", "LBDNENO", "LBXMC", "LBXMPSI" # top 40
)

demographic_features <- c("age_years", "gender", "education_level", "race",
                          "marital_status", "bmi", "mean_sbp", "mean_dbp", "waist",
                          "height", "weight", "grip_strength", "phq9_sum", "phq9_depressed")

selected_features <- c(demographic_features, top_lab_features)

# train_x_resampled <- train_x_resampled[, selected_features]
train_x <- train_x[, selected_features]
test_x <- test_x[, selected_features]
