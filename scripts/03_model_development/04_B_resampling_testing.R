# ----------------------------------------------------------------------
# RESAMPLE UNDERREPRESENTED GROUPS (MILD - MCI ONLY)
# ----------------------------------------------------------------------

# Load cleaned data from previous step
load("data/processed/cleaned_data_for_modeling.RData")

# Define top features
top_lab_features <- c("LBXMMASI", "LBDHDD", "LBXSTR", "LBXSLDSI", "LBXSGB",
                      "LBXSCR", "LBXMCVSI", "LBXRDW", "LBXMOPCT", "LBDB12",
                      "LBDHDDSI", "LBXNEPCT", "LBXGH", "LBXVIDMS", "LBXLYPCT",
                      "LBDLYMNO", "LBXPLTSI", "LBXSBU", "LBXMC", "LBXHCT")

demographic_features <- c("age_years", "gender", "education_level", "race",
                          "marital_status", "bmi", "mean_sbp", "mean_dbp", "waist",
                          "height", "weight", "grip_strength", "phq9_sum", "phq9_depressed")

selected_features <- c(demographic_features, top_lab_features)

# Filter BEFORE resampling
train_x <- train_x[, selected_features]
test_x <- test_x[, selected_features]

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

# ----------------------------------------------------------------------------------------
# Age distribution after resampling - maybe delete code later?
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_resampling/age_distribution_mci.png", width=800, height=500)

age_breaks <- c(50, 60, 65, 70, 75, 80, Inf)
age_labels <- c("50-59", "60-64", "65-69", "70-74", "75-79", "80+")

train_resampled$age_group <- cut(train_resampled$age_years, breaks=age_breaks, labels=age_labels, right=FALSE)
age_counts <- table(train_resampled$age_group)

bp <- barplot(age_counts, col="skyblue",
              xlab="Age Group", ylab="Count",
              main="Age Distribution with MCI Counts (After Resampling)",
              ylim=c(0, max(age_counts)*1.2))

# Add MCI and non-MCI counts
for(i in 1:length(age_labels)) {
  group_data <- train_resampled[train_resampled$age_group == age_labels[i], ]
  mci_count <- sum(group_data$cog_impair == 1)
  non_mci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], age_counts[i], 
       labels=paste0("Total: ", age_counts[i], "\nMCI: ", mci_count, "\nNo MCI: ", non_mci_count), 
       pos=3, cex=0.7)
}

dev.off()

# ----------------------------------------------------------------------------------------
# Education level after resampling
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_resampling/education_level_mci.png", width=800, height=500)
edu_counts <- table(train_resampled$education_level)
bp <- barplot(edu_counts,
              col = "lightcoral",
              xlab = "Education Level Code", ylab = "Count",
              main = "Education Level with MCI Counts (After Resampling)",
              ylim = c(0, max(edu_counts) * 1.3))

# Add MCI and non-MCI counts
for(i in 1:length(edu_counts)) {
  edu_code <- as.numeric(names(edu_counts)[i])
  group_data <- train_resampled[train_resampled$education_level == edu_code, ]
  mci_count <- sum(group_data$cog_impair == 1)
  non_mci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], edu_counts[i], 
       labels=paste0("Total: ", edu_counts[i], "\nMCI: ", mci_count, "\nNo MCI: ", non_mci_count), 
       pos=3, cex=0.7)
}
dev.off()

cat("Resampled demographic plots saved to: outputs/figures/demographics_after_resampling/\n")
