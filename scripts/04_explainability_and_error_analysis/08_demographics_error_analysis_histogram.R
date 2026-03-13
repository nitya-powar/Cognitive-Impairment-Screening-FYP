library(dplyr)

FP_data <- read.csv('/data/processed/error_groups/FP_data.csv')
TP_data <- read.csv('/data/processed/error_groups/TP_data.csv') 
FN_data <- read.csv('/data/processed/error_groups/FN_data.csv') 
TN_data <- read.csv('/data/processed/error_groups/TN_data.csv') 

TP_data %>% count(gender)
FP_data %>% count(gender)
FN_data %>% count(gender)
TN_data %>% count(gender)

# 01 - Age histogram
png("outputs/figures/error_analysis_histograms/01_age_distribution.png", width=800, height=600)
par(mfrow = c(2,2))

hist(TP_data$age_years, main="TP: Age", xlab="Age", col="lightblue")
mtext(paste("n =", nrow(TP_data)), side=3, line=0.5, cex=0.8)
hist(FP_data$age_years, main="FP: Age", xlab="Age", col="lightblue")
mtext(paste("n =", nrow(FP_data)), side=3, line=0.5, cex=0.8)
hist(FN_data$age_years, main="FN: Age", xlab="Age", col="lightblue")
mtext(paste("n =", nrow(FN_data)), side=3, line=0.5, cex=0.8)
hist(TN_data$age_years, main="TN: Age", xlab="Age", col="lightblue")
mtext(paste("n =", nrow(TN_data)), side=3, line=0.5, cex=0.8)

dev.off()

# 02 - Gender histogram
png("outputs/figures/error_analysis_histograms/02_gender.png", width=800, height=600)
par(mfrow = c(2,2))

barplot(table(TP_data$gender), main="TP: Gender", col="lightblue")
mtext(paste("n =", nrow(TP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FP_data$gender), main="FP: Gender", col="lightblue")
mtext(paste("n =", nrow(FP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FN_data$gender), main="FN: Gender", col="lightblue")
mtext(paste("n =", nrow(FN_data)), side=3, line=0.5, cex=0.8)
barplot(table(TN_data$gender), main="TN: Gender", col="lightblue")
mtext(paste("n =", nrow(TN_data)), side=3, line=0.5, cex=0.8)

dev.off()

# 03 - Marital status histogram
png("outputs/figures/error_analysis_histograms/03_marital_status.png", width=800, height=600)
par(mfrow = c(2,2))

barplot(table(TP_data$marital_status), main="TP: Marital", col="lightblue")
mtext(paste("n =", nrow(TP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FP_data$marital_status), main="FP: Marital", col="lightblue")
mtext(paste("n =", nrow(FP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FN_data$marital_status), main="FN: Marital", col="lightblue")
mtext(paste("n =", nrow(FN_data)), side=3, line=0.5, cex=0.8)
barplot(table(TN_data$marital_status), main="TN: Marital", col="lightblue")
mtext(paste("n =", nrow(TN_data)), side=3, line=0.5, cex=0.8)

dev.off()

# 04 - Race histogram
png("outputs/figures/error_analysis_histograms/04_race.png", width=800, height=600)
par(mfrow = c(2,2))

barplot(table(TP_data$race), main="TP: Marital", col="lightblue")
mtext(paste("n =", nrow(TP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FP_data$race), main="FP: Marital", col="lightblue")
mtext(paste("n =", nrow(FP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FN_data$race), main="FN: Marital", col="lightblue")
mtext(paste("n =", nrow(FN_data)), side=3, line=0.5, cex=0.8)
barplot(table(TN_data$race), main="TN: Marital", col="lightblue")
mtext(paste("n =", nrow(TN_data)), side=3, line=0.5, cex=0.8)

dev.off()

# 05 - Education histogram
png("outputs/figures/error_analysis_histograms/05_education_level.png", width=800, height=600)
par(mfrow = c(2,2))

barplot(table(TP_data$education_level), main="TP: Education", col="lightblue")
mtext(paste("n =", nrow(TP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FP_data$education_level), main="FP: Education", col="lightblue")
mtext(paste("n =", nrow(FP_data)), side=3, line=0.5, cex=0.8)
barplot(table(FN_data$education_level), main="FN: Education", col="lightblue")
mtext(paste("n =", nrow(FN_data)), side=3, line=0.5, cex=0.8)
barplot(table(TN_data$education_level), main="TN: Education", col="lightblue")
mtext(paste("n =", nrow(TN_data)), side=3, line=0.5, cex=0.8)

dev.off()