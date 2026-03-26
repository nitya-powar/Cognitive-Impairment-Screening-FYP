library(dplyr)
library(yardstick)

# ----------------------------------------------------------------------------------------
# Load inputs
# ----------------------------------------------------------------------------------------
load("data/processed/cleaned_data_for_modeling.RData")
test_df <- readRDS("data/processed/test.rds")

pred_prob <- readRDS("data/processed/RF_exports/pred_prob_RF.rds")
predicted_class <- readRDS("data/processed/RF_exports/pred_class_best_t_RF.rds")

# ----------------------------------------------------------------------------------------
# Build the fairness dataset
# ----------------------------------------------------------------------------------------
fair_df <- tibble(
  actual = factor(test_y, levels = c(0, 1)),
  predicted = factor(predicted_class, levels = c(0, 1)),
  education = test_df$education_level,
  gender = test_df$gender,
  race = test_df$race,
  marital = test_df$marital_status,
  age_group = factor(
    case_when(
      test_df$age_years < 65 ~ "60-64",
      test_df$age_years < 70 ~ "65-69",
      test_df$age_years < 75 ~ "70-74",
      test_df$age_years < 80 ~ "75-79",
      TRUE ~ "80+"
    ),
    levels = c("60-64", "65-69", "70-74", "75-79", "80+")
  )
)

# ----------------------------------------------------------------------------------------
# Summarise fairness by demographic group
# ----------------------------------------------------------------------------------------
summarise_fairness <- function(data, group_var, label) {
  out <- data %>%
    group_by(.data[[group_var]]) %>%
    summarise(
      selection = mean(predicted == "1"),
      tpr = sensitivity_vec(actual, predicted, event_level = "second"),
      fpr = 1 - specificity_vec(actual, predicted, event_level = "second"),
      .groups = "drop"
    )

  cat("\n", toupper(label), "FAIRNESS:\n", sep = "")
  print(out)
  cat("DPD:", round(max(out$selection, na.rm = TRUE) - min(out$selection, na.rm = TRUE), 3), "\n")
  cat("EOD:", round(max(out$tpr, na.rm = TRUE) - min(out$tpr, na.rm = TRUE), 3), "\n")
  cat("FPR Difference:", round(max(out$fpr, na.rm = TRUE) - min(out$fpr, na.rm = TRUE), 3), "\n")

  invisible(out)
}

age_metrics <- summarise_fairness(fair_df, "age_group", "age")
edu_metrics <- summarise_fairness(fair_df, "education", "education")
gender_metrics <- summarise_fairness(fair_df, "gender", "gender")
race_metrics <- summarise_fairness(fair_df, "race", "race")
marital_metrics <- summarise_fairness(fair_df, "marital", "marital")
