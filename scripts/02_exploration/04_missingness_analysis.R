library(ggplot2)
library(naniar)
library(caret)
library(dplyr)

# ----------------------------------------------------------------------
# 1. LOAD DATA
# ----------------------------------------------------------------------
df <- read.csv("data/processed/dataframe_labs_with_conditions/final_df_conditions.csv")
#df <- read.csv("data/processed/dataframe_labs_only/final_df.csv")

# Convert target variable to factor for classification (0 = normal, 1 = MCI)
df$cog_impair <- factor(df$cog_impair, levels = c(0, 1))

# ----------------------------------------------------------------------
# 2. EXPLORE MISSINGNESS PATTERNS (BEFORE CLEANING DATA)
# ----------------------------------------------------------------------
# Create summary table - FIXED
missing_table <- miss_var_summary(df) %>%
  filter(pct_miss > 0) %>%
  mutate(
    n_miss = as.integer(n_miss),
    pct_miss = as.numeric(pct_miss)
  ) %>%
  as.data.frame()

# Save as CSV
write.csv(missing_table, "outputs/tables/table_3_1_missingness.csv", 
          row.names = FALSE)

# Print summary
cat("Total variables with missing data:", nrow(missing_table), "\n")
cat("Mean missingness:", round(mean(missing_table$pct_miss), 1), "%\n")
print(head(missing_table))

# Visualizations
vis_miss_plot <- vis_miss(df)
png("outputs/figures/vis_miss_plot.png", width = 1200, height = 700)
print(vis_miss(df))
dev.off()

miss_upset_plot <- gg_miss_upset(df)
png("outputs/figures/missing_data_upset.png", width = 1200, height = 700)
print(gg_miss_upset(df))
dev.off()
# ----------------------------------------------------------------------
# 3. CHECK IF MISSINGNESS IS RELATED TO DEMOGRAPHICS
# ----------------------------------------------------------------------
# Simple observed-variable association checks using overall feature missingness
feature_df <- subset(df, select = -cog_impair)
feature_df <- feature_df[, !(names(feature_df) %in% c("SEQN", "WTSH2YR"))]
df$high_missingness <- rowMeans(is.na(feature_df)) > 0.1

cat("\n=== OBSERVED-VARIABLE ASSOCIATION CHECKS ===\n")
cat("Age p-value:", t.test(age_years ~ high_missingness, data = df)$p.value, "\n")
cat("Gender p-value:", chisq.test(table(df$gender, df$high_missingness))$p.value, "\n")
cat("Race p-value:", chisq.test(table(df$race, df$high_missingness))$p.value, "\n")
cat("Education p-value:", chisq.test(table(df$education_level, df$high_missingness))$p.value, "\n")
cat("Marital status p-value:", chisq.test(table(df$marital_status, df$high_missingness))$p.value, "\n")
df$high_missingness <- NULL

# ----------------------------------------------------------------------
# 4. CLEAN DATA BASED ON MISSINGNESS ANALYSIS
# ----------------------------------------------------------------------
# Remove columns with >50% missing values (too sparse for modeling)
df_clean <- df[, colSums(is.na(df)) < nrow(df) * 0.6] # ------------------------> with 0.6, race related missingness after cleaning went away!!!!!!!
print(paste("Removed", ncol(df) - ncol(df_clean), "columns with >50% missing"))

# Remove identifier columns (not features for modeling)
drop_cols <- c("SEQN", "WTSH2YR")  # ID and survey weights
df_clean <- df_clean[, !(names(df_clean) %in% drop_cols)]

# ----------------------------------------------------------------------
# 5. TRAIN/TEST SPLIT
# ----------------------------------------------------------------------
# Split data AFTER cleaning (stratified by target to preserve class balance)
set.seed(123)
idx   <- createDataPartition(df_clean$cog_impair, p = 0.8, list = FALSE)
train <- df_clean[idx, ]
test  <- df_clean[-idx, ]

# ----------------------------------------------------------------------
# 6. FINAL MISSINGNESS CHECK AND ROW REMOVAL - not doing any more
# ----------------------------------------------------------------------
# Remove rows with >50% missing values in features (not target)
train_x <- subset(train, select = -cog_impair)
test_x  <- subset(test,  select = -cog_impair)

train_y <- as.numeric(as.character(train$cog_impair))  # 0/1
test_y  <- as.numeric(as.character(test$cog_impair))   # 0/1

# Keep only rows with <50% missing feature values ---> removed since this introduced age bias
#row_missing <- rowMeans(is.na(train_x)) < 0.5
#train_x <- train_x[row_missing, ]
#train_y <- train_y[row_missing]

#print(paste("Removed", sum(!row_missing), "training rows with >50% missing features"))

# ----------------------------------------------------------------------
# 7. VERIFY CLEANED DATA MISSINGNESS PATTERNS
# ----------------------------------------------------------------------
# Check missing percentage in cleaned dataset
print("Missingness after cleaning:")
print(miss_var_summary(train_x))

cols_to_drop <- c("WTSAF2YR", "WTSAF2YR.x", "WTSAF2YR.y", "LBXSATSI"
                  #                  , "race","marital_status", "education_level"
)
train_x <- train_x[, !(names(train_x) %in% cols_to_drop)]
test_x <- test_x[, !(names(test_x) %in% cols_to_drop)]
print(miss_var_summary(train_x))

# Verify missingness after cleaning
train_x$overall_missing_pct <- rowMeans(is.na(train_x))
train_x$high_missingness <- train_x$overall_missing_pct > 0.1

# -----------------------------------------------------------------------
# Test if missingness relates to demographics after cleaning
# -----------------------------------------------------------------------
cat("\n=== ASSOCIATION CHECKS AFTER CLEANING ===\n")
cat("Age p-value:", t.test(age_years ~ high_missingness, data = train_x)$p.value, "\n")
cat("Gender p-value:", chisq.test(table(train_x$gender, train_x$high_missingness))$p.value, "\n")
cat("Race p-value:", chisq.test(table(train_x$race, train_x$high_missingness))$p.value, "\n")
cat("Education p-value:", chisq.test(table(train_x$education_level, train_x$high_missingness))$p.value, "\n")
cat("Marital status p-value:", chisq.test(table(train_x$marital_status, train_x$high_missingness))$p.value, "\n")

train_x$overall_missing_pct <- NULL
train_x$high_missingness <- NULL


# ----------------------------------------------------------------------
# 8. SAVE CLEANED DATA FOR MODELING
# ----------------------------------------------------------------------
# Save cleaned datasets for use in model training and comparison
save(train_x, train_y, test_x, test_y, 
     file = "data/processed/cleaned_data_for_modeling.RData")
print("Cleaned data saved to: data/processed/cleaned_data_for_modeling.RData")

saveRDS(test, "data/processed/test.rds")
