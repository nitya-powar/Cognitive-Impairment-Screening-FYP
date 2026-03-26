library(naniar)
library(dplyr)

# Load the merged dataset
df <- read.csv("data/processed/dataframe/final_dataframe.csv")

# Treat the outcome as a binary classification label
df$cog_impair <- factor(df$cog_impair, levels = c(0, 1))

# ----------------------------------------------------------------------
# Missingness before cleaning
# ----------------------------------------------------------------------
# Summarise missingness in the predictor set before cleaning
missingness_vars <- c("SEQN", "age_years", "gender", "race", "education_level", "marital_status", "cog_impair")
feature_df <- df[, !(names(df) %in% missingness_vars)]

missing_table <- miss_var_summary(feature_df) %>%
  filter(pct_miss > 0) %>%
  mutate(
    n_miss = as.integer(n_miss),
    pct_miss = as.numeric(pct_miss)
  ) %>%
  as.data.frame()

cat("Total variables with missing data:", nrow(missing_table), "\n")
cat("Mean missingness:", round(mean(missing_table$pct_miss), 1), "%\n")
print(head(missing_table)) 

# Check whether missingness is associated with demographics
df$high_missingness <- rowMeans(is.na(feature_df)) > 0.1

cat("\n=== OBSERVED-VARIABLE ASSOCIATION CHECKS ===\n")
cat("Age p-value:", t.test(age_years ~ high_missingness, data = df)$p.value, "\n")
cat("Gender p-value:", chisq.test(table(df$gender, df$high_missingness))$p.value, "\n")
cat("Race p-value:", chisq.test(table(df$race, df$high_missingness))$p.value, "\n")
cat("Education p-value:", chisq.test(table(df$education_level, df$high_missingness))$p.value, "\n")
cat("Marital status p-value:", chisq.test(table(df$marital_status, df$high_missingness))$p.value, "\n")
df$high_missingness <- NULL

# ----------------------------------------------------------------------
# Clean the dataset
# ----------------------------------------------------------------------
# Remove columns that are too sparse for modeling
final_cleaned_dataframe <- df[, colSums(is.na(df)) < nrow(df) * 0.6]
print(paste("Removed", ncol(df) - ncol(final_cleaned_dataframe), "columns with >=60% missing"))
drop_col <- c("SEQN")
final_cleaned_dataframe <- final_cleaned_dataframe[, !(names(final_cleaned_dataframe) %in% drop_col)]

# ----------------------------------------------------------------------
# Missingness after cleaning
# ----------------------------------------------------------------------
# Review missingness again after column removal
print("Missingness after cleaning:")
feature_final_cleaned_dataframe <- final_cleaned_dataframe[, !(names(final_cleaned_dataframe) %in% c("age_years", "gender", "race", "education_level", "marital_status", "cog_impair"))]
print(miss_var_summary(feature_final_cleaned_dataframe))

# Calculate row-level missingness using the cleaned predictor set
final_cleaned_dataframe$overall_missing_pct <- rowMeans(is.na(feature_final_cleaned_dataframe))
final_cleaned_dataframe$high_missingness <- final_cleaned_dataframe$overall_missing_pct > 0.1

# Recheck the demographic association after cleaning
cat("\n=== ASSOCIATION CHECKS AFTER CLEANING ===\n")
cat("Age p-value:", t.test(age_years ~ high_missingness, data = final_cleaned_dataframe)$p.value, "\n")
cat("Gender p-value:", chisq.test(table(final_cleaned_dataframe$gender, final_cleaned_dataframe$high_missingness))$p.value, "\n")
cat("Race p-value:", chisq.test(table(final_cleaned_dataframe$race, final_cleaned_dataframe$high_missingness))$p.value, "\n")
cat("Education p-value:", chisq.test(table(final_cleaned_dataframe$education_level, final_cleaned_dataframe$high_missingness))$p.value, "\n")
cat("Marital status p-value:", chisq.test(table(final_cleaned_dataframe$marital_status, final_cleaned_dataframe$high_missingness))$p.value, "\n")

final_cleaned_dataframe$overall_missing_pct <- NULL
final_cleaned_dataframe$high_missingness <- NULL

# ----------------------------------------------------------------------
# Save outputs
# ----------------------------------------------------------------------
# Save the cleaned dataset for the train/test split step
write.csv(final_cleaned_dataframe, "data/processed/dataframe/final_cleaned_dataframe.csv", row.names = FALSE)
saveRDS(final_cleaned_dataframe, "data/processed/dataframe/final_cleaned_dataframe.rds")
