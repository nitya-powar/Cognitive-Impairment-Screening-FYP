library(readr)
final_dataframe <- read_csv("data/processed/dataframe/final_dataframe.csv")

# Age distribution
png("outputs/figures/initial_demographics_histograms/age_distribution.png", width=800, height=500)

# Group ages into the same bands used across the analysis
age_breaks <- c(50, 60, 65, 70, 75, 80, Inf)
age_labels <- c("50-59", "60-64", "65-69", "70-74", "75-79", "80+")
counts <- table(cut(final_dataframe$age_years,
                    breaks = age_breaks,
                    labels = age_labels,
                    right = FALSE)) 

bp <- barplot(counts,
              col = "skyblue",
              xlab = "Age Group",
              ylab = "Count",
              main = "Participants by Age Group",
              ylim = c(0, max(counts) * 1.1))
text(bp, counts, labels = counts, pos = 3, cex = 0.8)
dev.off()

# Gender distribution
png("outputs/figures/initial_demographics_histograms/gender_distribution.png", width=700, height=500)
height <- table(final_dataframe$gender)
bp <- barplot(height,
              names.arg = c("Male", "Female"),
              col = "lightblue",
              xlab = "Gender", ylab = "Count",
              main = "Gender Distribution",
              ylim = c(0, 900))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Race distribution
png("outputs/figures/initial_demographics_histograms/race_distribution.png", width=800, height=500)
height <- table(final_dataframe$race)
bp <- barplot(height,
              col = "lightgreen",
              xlab = "Race Code", ylab = "Count",
              main = "Race Distribution (RIDRETH3)",
              ylim = c(0, 900))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Education level
png("outputs/figures/initial_demographics_histograms/education_level.png", width=800, height=500)
height <- table(final_dataframe$education_level)
bp <- barplot(height,
              col = "lightcoral",
              xlab = "Education Level Code", ylab = "Count",
              main = "Education Level (DMDEDUC2)",
              ylim = c(0, 500))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Marital status
png("outputs/figures/initial_demographics_histograms/marital_status.png", width=800, height=500)
marital_labels <- c("Married", "Widowed", "Divorced", "Separated", 
                    "Never married", "Living with partner")

marital_counts <- table(factor(final_dataframe$marital_status, 
                               levels = 1:6, 
                               labels = marital_labels))
bp <- barplot(marital_counts,
              col = "lightpink",
              ylab = "Count",
              main = "Marital Status Distribution",
              ylim = c(0,900))

text(bp, marital_counts, labels = marital_counts, pos = 3, cex = 1)
dev.off()

# Cognitive impairment status
png("outputs/figures/initial_demographics_histograms/cognitive_impairment_distribution.png", width=800, height=500)

# Count participants in each CI class
imp_counts <- table(final_dataframe$cog_impair)
names(imp_counts) <- c("No Impairment (0)", "CI (1)")

# Plot the class distribution
bp <- barplot(imp_counts,
              col = c("lightgreen", "salmon"),
              xlab = "Cognitive Status",
              ylab = "Count", 
              main = "Participants by Cognitive Impairment Status",
              ylim = c(0, max(imp_counts) * 1.1),
              border = NA)

# Add raw counts above each bar
text(bp, imp_counts, labels = imp_counts, pos = 3, cex = 1.2, font = 2)

# Add percentages inside the bars
percentages <- round(imp_counts / sum(imp_counts) * 100, 1)
text(bp, imp_counts/2, 
     labels = paste0(percentages, "%"), 
     cex = 1.2, 
     col = "white", 
     font = 2)

dev.off()
