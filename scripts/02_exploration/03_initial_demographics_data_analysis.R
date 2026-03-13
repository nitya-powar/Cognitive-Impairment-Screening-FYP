library(readr)
final_df <- read_csv('/data/processed/dataframe_labs_only/final_df.csv')

# ----------------------------------------------------------------------------------------
# Age distribution
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics/age_distribution.png", width=800, height=500)

# Create custom age breaks
age_breaks <- c(50, 60, 65, 70, 75, 80, Inf)
age_labels <- c("50-59", "60-64", "65-69", "70-74", "75-79", "80+")
counts <- table(cut(final_df$age_years,
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

# ----------------------------------------------------------------------------------------
# Gender distribution
# ----------------------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------------------
# Race distribution
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics/race_distribution.png", width=800, height=500)
height <- table(final_df$race)
bp <- barplot(height,
              col = "lightgreen",
              xlab = "Race Code", ylab = "Count",
              main = "Race Distribution (RIDRETH3)",
              ylim = c(0, 900))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# ----------------------------------------------------------------------------------------
# Education level
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics/education_level.png", width=800, height=500)
height <- table(final_df$education_level)
bp <- barplot(height,
              col = "lightcoral",
              xlab = "Education Level Code", ylab = "Count",
              main = "Education Level (DMDEDUC2)",
              ylim = c(0, 500))
text(bp, height, labels = height, pos = 3, cex = 0.8)
dev.off()

# ----------------------------------------------------------------------------------------
# Marital status 
# ----------------------------------------------------------------------------------------
png("outputs/figures/demographics/marital_status.png", width=800, height=500)
marital_labels <- c("Married", "Widowed", "Divorced", "Separated", 
                    "Never married", "Living with partner")

marital_counts <- table(factor(final_df$marital_status, 
                               levels = 1:6, 
                               labels = marital_labels))
bp <- barplot(marital_counts,
              col = "lightpink",
              ylab = "Count",
              main = "Marital Status Distribution",
              ylim = c(0,900))

text(bp, marital_counts, labels = marital_counts, pos = 3, cex = 1)
dev.off()

# ----------------------------------------------------------------------------------------
# Cog Impair
# ----------------------------------------------------------------------------------------
  

png("outputs/figures/demographics/cognitive_impairment_distribution.png", width=800, height=500)

# Create count table
imp_counts <- table(final_df$cog_impair)
names(imp_counts) <- c("No Impairment (0)", "MCI (1)")

# Create barplot
bp <- barplot(imp_counts,
              col = c("lightgreen", "salmon"),
              xlab = "Cognitive Status",
              ylab = "Count", 
              main = "Participants by Cognitive Impairment Status",
              ylim = c(0, max(imp_counts) * 1.1),
              border = NA)

# Add count labels
text(bp, imp_counts, labels = imp_counts, pos = 3, cex = 1.2, font = 2)

# Add percentage labels
percentages <- round(imp_counts / sum(imp_counts) * 100, 1)
text(bp, imp_counts/2, 
     labels = paste0(percentages, "%"), 
     cex = 1.2, 
     col = "white", 
     font = 2)

dev.off()

