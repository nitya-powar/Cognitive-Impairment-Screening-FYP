load("data/processed/cleaned_data_for_modeling.RData")

train <- cbind(train_x, cog_impair = factor(train_y, levels = c(0, 1)))

# ----------------------------------------------------------------------------------------
# Age distribution
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/age_distribution_ci.png", width=800, height=500)

age_breaks <- c(50, 60, 65, 70, 75, 80, Inf)
age_labels <- c("50-59", "60-64", "65-69", "70-74", "75-79", "80+")

train$age_group <- cut(train$age_years, breaks=age_breaks, labels=age_labels, right=FALSE)
age_counts <- table(train$age_group)

bp <- barplot(age_counts, col="skyblue",
              xlab="Age Group", ylab="Count",
              main="Age Distribution with CI Counts",
              ylim=c(0, max(age_counts)*1.2))

# Add CI and non-CI counts
for(i in 1:length(age_labels)) {
  group_data <- train[train$age_group == age_labels[i], ]
  ci_count <- sum(group_data$cog_impair == 1)
  non_ci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], age_counts[i],
       labels=paste0("Total: ", age_counts[i], "\nCI: ", ci_count, "\nNo CI: ", non_ci_count),
       pos=3, cex=0.7)
}

dev.off()

# ----------------------------------------------------------------------------------------
# Gender distribution
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/gender_distribution_ci.png", width=700, height=500)
gender_counts <- table(train$gender)
bp <- barplot(gender_counts,
              names.arg = c("Male", "Female"),
              col = "lightblue",
              xlab = "Gender", ylab = "Count",
              main = "Gender Distribution with CI Counts",
              ylim = c(0, max(gender_counts) * 1.3))

# Add CI and non-CI counts
for(i in 1:2) {
  group_data <- train[train$gender == i, ]
  ci_count <- sum(group_data$cog_impair == 1)
  non_ci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], gender_counts[i],
       labels=paste0("Total: ", gender_counts[i], "\nCI: ", ci_count, "\nNo CI: ", non_ci_count),
       pos=3, cex=0.7)
}
dev.off()

# ----------------------------------------------------------------------------------------
# Race distribution
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/race_distribution_ci.png", width=800, height=500)
race_counts <- table(train$race)
bp <- barplot(race_counts,
              col = "lightgreen",
              xlab = "Race Code", ylab = "Count",
              main = "Race Distribution with CI Counts",
              ylim = c(0, max(race_counts) * 1.3))

# Add CI and non-CI counts
for(i in 1:length(race_counts)) {
  race_code <- as.numeric(names(race_counts)[i])
  group_data <- train[train$race == race_code, ]
  ci_count <- sum(group_data$cog_impair == 1)
  non_ci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], race_counts[i],
       labels=paste0("Total: ", race_counts[i], "\nCI: ", ci_count, "\nNo CI: ", non_ci_count),
       pos=3, cex=0.7)
}
dev.off()

# ----------------------------------------------------------------------------------------
# Education level
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/education_level_ci.png", width=800, height=500)
edu_counts <- table(train$education_level)
bp <- barplot(edu_counts,
              col = "lightcoral",
              xlab = "Education Level Code", ylab = "Count",
              main = "Education Level with CI Counts",
              ylim = c(0, max(edu_counts) * 1.3))

# Add CI and non-CI counts
for(i in 1:length(edu_counts)) {
  edu_code <- as.numeric(names(edu_counts)[i])
  group_data <- train[train$education_level == edu_code, ]
  ci_count <- sum(group_data$cog_impair == 1)
  non_ci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], edu_counts[i],
       labels=paste0("Total: ", edu_counts[i], "\nCI: ", ci_count, "\nNo CI: ", non_ci_count),
       pos=3, cex=0.7)
}
dev.off()

# ----------------------------------------------------------------------------------------
# Marital status
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/marital_status_ci.png", width=800, height=500)
marital_labels <- c("Married", "Widowed", "Divorced", "Separated",
                    "Never married", "Living with partner")

marital_counts <- table(factor(train$marital_status,
                               levels = 1:6,
                               labels = marital_labels))
bp <- barplot(marital_counts,
              col = "lightpink",
              ylab = "Count",
              main = "Marital Status Distribution with CI Counts",
              ylim = c(0, max(marital_counts) * 1.3))

# Add CI and non-CI counts
for(i in 1:6) {
  group_data <- train[train$marital_status == i, ]
  ci_count <- sum(group_data$cog_impair == 1)
  non_ci_count <- sum(group_data$cog_impair == 0)
  text(bp[i], marital_counts[i],
       labels=paste0("Total: ", marital_counts[i], "\nCI: ", ci_count, "\nNo CI: ", non_ci_count),
       pos=3, cex=0.7)
}
dev.off()

# ----------------------------------------------------------------------------------------
# Cognitive Impairment
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics_after_cleaning/cognitive_impairment_distribution.png",
    width=800, height=500)

imp_counts <- table(train$cog_impair)
names(imp_counts) <- c("No Impairment (0)", "CI (1)")

bp <- barplot(imp_counts,
              col = c("lightgreen", "salmon"),
              xlab = "Cognitive Status",
              ylab = "Count",
              main = "Cognitive Impairment (Cleaned Data)",
              ylim = c(0, max(imp_counts) * 1.1),
              border = NA)

text(bp, imp_counts, labels = imp_counts, pos = 3, cex = 1.2, font = 2)

percentages <- round(imp_counts / sum(imp_counts) * 100, 1)
text(bp, imp_counts/2,
     labels = paste0(percentages, "%"),
     cex = 1.2,
     col = "white",
     font = 2)

dev.off()

cat("Demographic plots saved to: outputs/figures/demographics_after_cleaning/\n")
