library(dplyr)
library(purrr)
library(yardstick)

# Active experiment inputs
load("data/processed/cleaned_data_for_modeling.RData")
test_df <- readRDS("data/processed/test.rds")

pred_prob <- readRDS("data/processed/RF_exports/pred_prob_RF.rds")
predicted_class <- readRDS("data/processed/RF_exports/pred_class_best_t_RF.rds")

# Build fairness dataframe
fair_df <- tibble(
  actual = factor(test_y, levels = c(0, 1)),
  predicted = factor(predicted_class, levels = c(0, 1)),
  prob = pred_prob,
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

summarise_fairness <- function(data, group_var, label) {
  # Summarise model behaviour for one protected attribute at a time.
  out <- data %>%
    # Group by the demographic variable currently being audited.
    group_by(.data[[group_var]]) %>%
    summarise(
      selection = mean(predicted == "1"),  # Share of people predicted as MCI in each group
      tpr = sensitivity_vec(actual, predicted, event_level = "second"),  # MCI recall within the group
      fpr = 1 - specificity_vec(actual, predicted, event_level = "second"),  # False alarm rate within the group
      .groups = "drop"
    )

  # Print the same summary table and max-min gaps as the manual fairness script.
  cat("\n", toupper(label), "FAIRNESS:\n", sep = "")
  print(out)
  # DPD here is the largest gap in positive prediction rate across groups.
  cat("DPD:", round(max(out$selection, na.rm = TRUE) - min(out$selection, na.rm = TRUE), 3), "\n")
  # EOD here is the largest gap in true positive rate across groups.
  cat("EOD:", round(max(out$tpr, na.rm = TRUE) - min(out$tpr, na.rm = TRUE), 3), "\n")
  # FPR Difference captures the largest gap in false positive rate across groups.
  cat("FPR Difference:", round(max(out$fpr, na.rm = TRUE) - min(out$fpr, na.rm = TRUE), 3), "\n")

  # Return the table invisibly so it can still be assigned if needed.
  invisible(out)
}

age_metrics <- summarise_fairness(fair_df, "age_group", "age")
edu_metrics <- summarise_fairness(fair_df, "education", "education")
gender_metrics <- summarise_fairness(fair_df, "gender", "gender")
race_metrics <- summarise_fairness(fair_df, "race", "race")
marital_metrics <- summarise_fairness(fair_df, "marital", "marital")

table(fair_df$age_group)
table(fair_df$age_group, fair_df$actual)

table(fair_df$education)
table(fair_df$education, fair_df$actual)

table(fair_df$gender)
table(fair_df$gender, fair_df$actual)

table(fair_df$race)
table(fair_df$race, fair_df$actual)

table(fair_df$marital)
table(fair_df$marital, fair_df$actual)

