# ----------------------------------------------------------------------
# RESAMPLE UNDERREPRESENTED GROUPS (MILD - MCI ONLY)
# ----------------------------------------------------------------------

# Load cleaned data from previous step
load("data/processed/cleaned_data_for_modeling.RData")

# Combine features and target for resampling
train_combined <- cbind(train_x, cog_impair = train_y)

# 1. Education 4 & 5 MCI cases only
edu4_mci <- which(train_combined$education_level == 4 & train_combined$cog_impair == 1)
edu5_mci <- which(train_combined$education_level == 5 & train_combined$cog_impair == 1)

# 2. Age 65-69 MCI cases only
age_65_69_mci <- which(train_combined$age_years >= 65 & 
                         train_combined$age_years < 70 & 
                         train_combined$cog_impair == 1)

# Combine all target rows and duplicate each selected row only once
resample_idx <- unique(c(edu4_mci, edu5_mci, age_65_69_mci))

# Create resampled dataset: original + extra MCI cases
train_resampled <- rbind(train_combined,                    # Original data
                         train_combined[resample_idx, ])    # Extra selected MCI rows

# Shuffle
set.seed(123)
train_resampled <- train_resampled[sample(nrow(train_resampled)), ]

# Split back to X and y
train_x_resampled <- subset(train_resampled, select = -cog_impair)
train_y_resampled <- train_resampled$cog_impair

# Save resampled data
save(train_x_resampled, train_y_resampled, test_x, test_y,
     file = "data/processed/cleaned_data_resampled.RData")
print("Resampled data saved to: data/processed/cleaned_data_resampled.RData")

# Compare sizes
cat("Original training size:", nrow(train_x), "\n")
cat("Resampled training size:", nrow(train_x_resampled), "\n")
cat("Education 4 MCI added:", length(edu4_mci), "rows\n")
cat("Education 5 MCI added:", length(edu5_mci), "rows\n")
cat("Age 65-69 MCI added:", length(age_65_69_mci), "rows\n")
cat("Unique rows added after overlap check:", length(resample_idx), "rows\n")
