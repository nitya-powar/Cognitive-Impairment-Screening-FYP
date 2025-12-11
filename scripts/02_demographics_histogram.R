FP_data <- read.csv('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/interim/FP_data.csv')
TP_data <- read.csv('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/interim/TP_data.csv') 
FN_data <- read.csv('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/interim/FN_data.csv') 
TN_data <- read.csv('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/interim/TN_data.csv') 

library(dplyr)

TP_data %>% count(gender)
FP_data %>% count(gender)
FN_data %>% count(gender)
TN_data %>% count(gender)

par(mfrow = c(2,2))
hist(TP_data$age_years, main="TP: Age", xlab="Age", col="lightblue")
hist(FP_data$age_years, main="FP: Age", xlab="Age", col="lightblue")
hist(FN_data$age_years, main="FN: Age", xlab="Age", col="lightblue")
hist(TN_data$age_years, main="TN: Age", xlab="Age", col="lightblue")

par(mfrow = c(2,2))

barplot(table(TP_data$gender), main="TP: Gender", col="lightblue")
barplot(table(FP_data$gender), main="FP: Gender", col="lightblue")
barplot(table(FN_data$gender), main="FN: Gender", col="lightblue")
barplot(table(TN_data$gender), main="TN: Gender", col="lightblue")

#par(mfrow = c(2,2))

#barplot(table(TP_data$race), main="TP: Race", col="lightblue")
#barplot(table(FP_data$race), main="FP: Race", col="lightblue")
#barplot(table(FN_data$race), main="FN: Race", col="lightblue")
#barplot(table(TN_data$race), main="TN: Race", col="lightblue")

#par(mfrow = c(2,2))

#barplot(table(TP_data$education_level), main="TP: Education", col="lightblue")
#barplot(table(FP_data$education_level), main="FP: Education", col="lightblue")
#barplot(table(FN_data$education_level), main="FN: Education", col="lightblue")
#barplot(table(TN_data$education_level), main="TN: Education", col="lightblue")

par(mfrow = c(2,2))

barplot(table(TP_data$marital_status), main="TP: Marital", col="lightblue")
barplot(table(FP_data$marital_status), main="FP: Marital", col="lightblue")
barplot(table(FN_data$marital_status), main="FN: Marital", col="lightblue")
barplot(table(TN_data$marital_status), main="TN: Marital", col="lightblue")

#par(mfrow = c(2,2))

#barplot(table(TP_data$annual_income), main="TP: Income", col="lightblue")
#barplot(table(FP_data$annual_income), main="FP: Income", col="lightblue")
#barplot(table(FN_data$annual_income), main="FN: Income", col="lightblue")
#barplot(table(TN_data$annual_income), main="TN: Income", col="lightblue")