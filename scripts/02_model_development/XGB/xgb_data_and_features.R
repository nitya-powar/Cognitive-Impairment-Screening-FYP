load("data/processed/cleaned_data_for_modeling.RData")
#load("data/processed/cleaned_data_resampled.RData")

top_lab_features <- c(
  "LBDSGBSI", "LBXMMASI", "LBDHDDSI", "LBDBCDSI", "LBDTCSI",
  "LBDTRSI", "LBDSCRSI", "LBXHGB", "LBXPLTSI", "URDACT"    # top 10
  ,"LBXSATSI", "LBDB12SI", "LBXVIDMS", "LBDGLUSI", "LBXVE3MS",
  "LBDSIRSI", "LBXRDW", "LBXGH", "LBXLYPCT", "LBDSBUSI"    # top 20
  ,"LBDLDLSI", "LBXMOPCT", "LBDSALSI", "LBDSPHSI", "LBXMCVSI",
  "LBXMPSI", "LBXRBCSI", "LBDBSESI", "LBDSUASI", "LBXHCT" # top 30
#   # ,"LBDLYMNO", "LBDINSI", "LBXNEPCT", "LBXSAPSI", "LBDRFOSI", 
#   # "LBXSOSSI", "LBDBMNSI", "LBDSTPSI", "LBXSGTSI", "LBDBPBSI" # top 40
)

demographic_features <- c("age_years", "gender", "education_level", "race",
                          "marital_status", "bmi", "mean_sbp", "mean_dbp", "waist",
                          "height", "weight", "grip_strength", "phq9_sum", "phq9_depressed")

selected_features <- c(demographic_features, top_lab_features)

train_x <- train_x[, selected_features]
#train_x_resampled <- train_x_resampled[, selected_features]
test_x <- test_x[, selected_features]
