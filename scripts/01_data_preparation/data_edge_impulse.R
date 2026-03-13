
# ----------------------------------------------------------------------------------------
# 1) Load original data (not resampled)
# ----------------------------------------------------------------------------------------
load("data/processed/cleaned_data_for_modeling.RData")

# ----------------------------------------------------------------------------------------
# 2) Combine train and test back to full dataset
# ----------------------------------------------------------------------------------------
full_x <- rbind(train_x, test_x)
full_y <- c(train_y, test_y)

# Create full dataset with target
full_data <- data.frame(full_x, cog_impair = full_y)

print("Full dataset dimensions:")
print(dim(full_data))
cat("MCI cases in full data:", sum(full_y), "out of", length(full_y), "\n")

# ----------------------------------------------------------------------------------------
# 3) Apply your SAME imputation to full dataset
# ----------------------------------------------------------------------------------------
library(missRanger)

set.seed(123)
full_imputed <- missRanger(
  full_data,
  pmm.k = 3,
  seed = 123,
  verbose = 1
)

# ----------------------------------------------------------------------------------------
# 4) Save for Edge Impulse
# ----------------------------------------------------------------------------------------
# Save as CSV
write.csv(full_imputed, 
          "data/processed/full_dataset_for_edgeimpulse.csv", 
          row.names = FALSE)

# Also save as RDS for later use
saveRDS(full_imputed, "data/processed/full_dataset_imputed.rds")

cat("\nDataset saved for Edge Impulse:\n")
cat("1. data/processed/full_dataset_for_edgeimpulse.csv (for upload)\n")
cat("2. data/processed/full_dataset_imputed.rds (for R use)\n")
cat("Rows:", nrow(full_imputed), "Columns:", ncol(full_imputed), "\n")