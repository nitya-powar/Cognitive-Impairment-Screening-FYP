# Active experiment inputs: change only this block for a different model/threshold


# load("data/processed/cleaned_data_resampled.RData")
load("data/processed/cleaned_data_for_modeling.RData")
test_df <- readRDS("data/processed/test.rds")

pred_prob <- readRDS("data/processed/pred_prob_RF.rds")
predicted_class <- readRDS("data/processed/pred_class_best_t_RF.rds")

# predicted_class <- readRDS("data/processed/pred_class_5_RF.rds")
# pred_prob <- readRDS("data/processed/pred_prob.rds")
# predicted_class <- readRDS("data/processed/pred_class_5.rds")
# predicted_class <- readRDS("data/processed/pred_class_best_t.rds")

# Create dataframe with predictions + protected attributes
fair_df <- data.frame(
  actual = test_y,
  predicted = predicted_class,
  prob = pred_prob,
  education = test_df$education_level,
  gender = test_df$gender,
  race = test_df$race,
  marital = test_df$marital_status,
  age_years = test_df$age_years
)

# ------------------------------------------------------------------------------
# Helper function for getting true positive rate and false positive rate required for EOD
# ------------------------------------------------------------------------------

get_tpr <- function(data, demographic_var, group_value) {
  group_cases <- data[data[[demographic_var]] == group_value & data$actual == 1, ]
  if (nrow(group_cases) == 0) return(NA)
  sum(group_cases$predicted == 1) / nrow(group_cases) # Percentage of people correctly predicted as MCI
}

get_fpr <- function(data, demographic_var, group_value) {
  group_non_cases <- data[data[[demographic_var]] == group_value & data$actual == 0, ]
  if (nrow(group_non_cases) == 0) return(NA)
  sum(group_non_cases$predicted == 1) / nrow(group_non_cases)
}

# ------------------------------------------------------------------------------
# 1) AGE
# ------------------------------------------------------------------------------
# Age groups
fair_df$age_group <- ifelse(fair_df$age_years < 65, "60-64",
                            ifelse(fair_df$age_years < 70, "65-69",
                                   ifelse(fair_df$age_years < 75, "70-74",
                                          ifelse(fair_df$age_years < 80, "75-79", "80+"))))

# Get selection rates for all age groups
age_groups <- unique(fair_df$age_group)
selection_rates <- sapply(age_groups, function(group) {
  mean(fair_df$predicted[fair_df$age_group == group] == 1, na.rm = TRUE)
})

# DPD = max difference between any two groups
DPD_age <- max(selection_rates) - min(selection_rates)
cat("Age group selection rates:", round(selection_rates, 3), "\n")
cat("DPD (max-min difference):", round(DPD_age, 3), "\n")

# EOD (Equal Opportunity Difference)  
# TPR difference across all groups
tpr_rates <- sapply(age_groups, function(group) {
  get_tpr(fair_df, "age_group", group)
})
EOD_age <- max(tpr_rates, na.rm = TRUE) - min(tpr_rates, na.rm = TRUE)

# FPR difference across all groups
fpr_rates <- sapply(age_groups, function(group) {
  get_fpr(fair_df, "age_group", group)
})
FPR_age <- max(fpr_rates, na.rm = TRUE) - min(fpr_rates, na.rm = TRUE)

cat("Age group TPRs:", round(tpr_rates, 3), "\n")
cat("EOD (TPR max-min):", round(EOD_age, 3), "\n")
cat("Age group FPRs:", round(fpr_rates, 3), "\n")
cat("FPR Difference:", round(FPR_age, 3), "\n")

# ------------------------------------------------------------------------------
# 2) EDUCATION
# ------------------------------------------------------------------------------
# Education fairness - compare all education levels
edu_levels <- sort(unique(fair_df$education))

# DPD across all education levels
edu_selection <- sapply(edu_levels, function(level) {
  mean(fair_df$predicted[fair_df$education == level] == 1, na.rm = TRUE)
})
DPD_edu <- max(edu_selection) - min(edu_selection)

# EOD across all education levels
edu_tprs <- sapply(edu_levels, function(level) {
  get_tpr(fair_df, "education", level)
})
EOD_edu <- max(edu_tprs, na.rm = TRUE) - min(edu_tprs, na.rm = TRUE)

# FPR across all education levels
edu_fprs <- sapply(edu_levels, function(level) {
  get_fpr(fair_df, "education", level)
})
FPR_edu <- max(edu_fprs, na.rm = TRUE) - min(edu_fprs, na.rm = TRUE)

cat("EDUCATION FAIRNESS:\n")
cat("  Levels:", edu_levels, "\n")
cat("  Selection rates:", round(edu_selection, 3), "\n")
cat("  DPD:", round(DPD_edu, 3), "\n")
cat("  TPRs:", round(edu_tprs, 3), "\n")
cat("  EOD:", round(EOD_edu, 3), "\n")
cat("  FPRs:", round(edu_fprs, 3), "\n")
cat("  FPR Diff:", round(FPR_edu, 3), "\n\n")

# ------------------------------------------------------------------------------
# 3) GENDER
# ------------------------------------------------------------------------------
cat("Gender counts:", table(fair_df$gender), "\n")

# Calculate all metrics for both genders
for(g in 1:2) {
  selection_rate <- mean(fair_df$predicted[fair_df$gender == g] == 1, na.rm = TRUE)
  tpr_rate <- get_tpr(fair_df, "gender", g)
  fpr_rate <- get_fpr(fair_df, "gender", g)
  
  cat("  Gender", g, ": ")
  cat("Selection=", round(selection_rate, 3), 
      "TPR=", round(tpr_rate, 3),
      "FPR=", round(fpr_rate, 3), "\n")
}

# Calculate differences
DPD_gender <- abs(mean(fair_df$predicted[fair_df$gender == 1] == 1, na.rm = TRUE) - 
                   mean(fair_df$predicted[fair_df$gender == 2] == 1, na.rm = TRUE))
EOD_gender <- abs(get_tpr(fair_df, "gender", 1) - get_tpr(fair_df, "gender", 2))
FPR_gender <- abs(get_fpr(fair_df, "gender", 1) - get_fpr(fair_df, "gender", 2))

cat("\nGENDER FAIRNESS METRICS:\n")
cat("  DPD (Selection Difference):", round(DPD_gender, 3), "\n")
cat("  EOD (TPR Difference):", round(EOD_gender, 3), "\n")
cat("  FPR Difference:", round(FPR_gender, 3), "\n\n")

# ------------------------------------------------------------------------------
# 4) RACE
# ------------------------------------------------------------------------------
cat("RACE FAIRNESS:\n")
race_levels <- sort(unique(fair_df$race))

# Calculate all race metrics
race_selection <- sapply(race_levels, function(r) {
  mean(fair_df$predicted[fair_df$race == r] == 1, na.rm = TRUE)
})
race_tprs <- sapply(race_levels, function(r) {
  get_tpr(fair_df, "race", r)
})
race_fprs <- sapply(race_levels, function(r) {
  get_fpr(fair_df, "race", r)
})

# Print each race
for(i in seq_along(race_levels)) {
  r <- race_levels[i]
  cat("  Race", r, ": Selection=", round(race_selection[i], 3),
      "TPR=", round(race_tprs[i], 3),
      "FPR=", round(race_fprs[i], 3), "\n")
}

# Calculate differences
DPD_race <- max(race_selection, na.rm = TRUE) - min(race_selection, na.rm = TRUE)
EOD_race <- max(race_tprs, na.rm = TRUE) - min(race_tprs, na.rm = TRUE)
FPR_race <- max(race_fprs, na.rm = TRUE) - min(race_fprs, na.rm = TRUE)

cat("\nRACE FAIRNESS METRICS:\n")
cat("  DPD (Selection Difference):", round(DPD_race, 3), "\n")
cat("  EOD (TPR Difference):", round(EOD_race, 3), "\n")
cat("  FPR Difference:", round(FPR_race, 3), "\n\n")
# ------------------------------------------------------------------------------
# 5) MARITAL
# ------------------------------------------------------------------------------
cat("\nMARITAL STATUS FAIRNESS:\n")
marital_levels <- sort(unique(fair_df$marital))

# Calculate all marital status metrics
marital_selection <- sapply(marital_levels, function(m) {
  mean(fair_df$predicted[fair_df$marital == m] == 1, na.rm = TRUE)
})
marital_tprs <- sapply(marital_levels, function(m) {
  get_tpr(fair_df, "marital", m)
})
marital_fprs <- sapply(marital_levels, function(m) {
  get_fpr(fair_df, "marital", m)
})

# Print each marital status
for(i in seq_along(marital_levels)) {
  m <- marital_levels[i]
  cat("  Marital", m, ": Selection=", round(marital_selection[i], 3),
      "TPR=", round(marital_tprs[i], 3),
      "FPR=", round(marital_fprs[i], 3), "\n")
}

# Calculate differences
DPD_marital <- max(marital_selection, na.rm = TRUE) - min(marital_selection, na.rm = TRUE)
EOD_marital <- max(marital_tprs, na.rm = TRUE) - min(marital_tprs, na.rm = TRUE)
FPR_marital <- max(marital_fprs, na.rm = TRUE) - min(marital_fprs, na.rm = TRUE)

cat("\nMARITAL STATUS FAIRNESS METRICS:\n")
cat("  DPD (Selection Difference):", round(DPD_marital, 3), "\n")
cat("  EOD (TPR Difference):", round(EOD_marital, 3), "\n")
cat("  FPR Difference:", round(FPR_marital, 3), "\n\n")

