# ------------------------------------------------------
# Print marital status distribution for error analysis
# ------------------------------------------------------
test_x_imp <- readRDS('/data/processed/test_x_imp.rds')
results <- readRDS('/data/interim/results_test.rds')

# 1. Overall distribution in the test set

cat("\n1. Overall distribution in TEST set:\n")
print(table(test_x_imp$age_years))

# 2. Distribution in each error category

cat("\n2. Distribution in FALSE POSITIVES (FP):\n")
print(table(test_x_imp$age_years[results$case == "FP"]))

cat("\n3. Distribution in FALSE NEGATIVES (FN):\n")
print(table(test_x_imp$age_years[results$case == "FN"]))

cat("\n4. Distribution in TRUE POSITIVES (TP):\n")
print(table(test_x_imp$age_years[results$case == "TP"]))

cat("\n5. Distribution in TRUE NEGATIVES (TN):\n")
print(table(test_x_imp$age_years[results$case == "TN"]))

# 6. Calculate proportions for ALL error groups
cat("\n6. Proportions in each error group vs Overall:\n")

error_groups <- c("FP", "FN", "TP", "TN")
for(group in error_groups) {
  cat("\n", group, "vs Overall:\n")
  group_table <- table(factor(test_x_imp$age_years[results$case == group], levels = all_ages))
  group_prop <- prop.table(group_table)
  print(round(cbind(Overall = overall_prop, 
                    Group = group_prop, 
                    Difference = group_prop - overall_prop), 3))
}