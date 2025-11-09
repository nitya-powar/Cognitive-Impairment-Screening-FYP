final_df <- read_csv("data/processed/final_df.csv")

dir.create("outputs/figures/demographics", recursive = TRUE, showWarnings = FALSE)

# Age distribution
png("outputs/figures/demographics/age_distribution.png", width=800, height=500)
counts <- table(cut(final_df$age_years,
                    breaks = c(0, 30, 40, 50, 60, Inf),
                    labels = c("0–30", "30–40", "40–50", "50–60", "60+")))
bp <- barplot(counts,
              col = "skyblue",
              xlab = "Age Group",
              ylab = "Count",
              main = "Participants by Age Group",
              ylim = c(0, 1800))
text(bp, counts, labels = counts, pos = 3, cex = 0.8)
dev.off()

# Gender distribution
png("outputs/figures/demographics/gender_distribution.png", width=700, height=500)
height <- table(final_df$gender)
bp <- barplot(height,
              names.arg = c("Male", "Female"),
              col = "lightblue",
              xlab = "Gender", ylab = "Count",
              main = "Gender Distribution",
              ylim = c(0, 900))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Race distribution
png("outputs/figures/demographics/race_distribution.png", width=800, height=500)
height <- table(final_df$race)
bp <- barplot(height,
              col = "lightgreen",
              xlab = "Race Code", ylab = "Count",
              main = "Race Distribution (RIDRETH3)",
              ylim = c(0, 900))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Education level
png("outputs/figures/demographics/education_level.png", width=800, height=500)
height <- table(final_df$education_level)
bp <- barplot(height,
              col = "lightcoral",
              xlab = "Education Level Code", ylab = "Count",
              main = "Education Level (DMDEDUC2)",
              ylim = c(0, 500))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# Annual income
png("outputs/figures/demographics/income_distribution.png", width=800, height=500)
height <- table(final_df$annual_income)
bp <- barplot(height,
              col = "khaki",
              xlab = "Annual Income Code", ylab = "Count",
              main = "Household Income (INDHHIN2)",
              ylim = c(0, 250))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()
