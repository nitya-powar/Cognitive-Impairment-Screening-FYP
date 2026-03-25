library(caret)

df_clean <- readRDS("data/processed/dataframe/final_cleaned_dataframe.rds")

# TRAIN/TEST SPLIT

# Split data AFTER cleaning (stratified by target to preserve class balance)
set.seed(123)
idx   <- createDataPartition(df_clean$cog_impair, p = 0.8, list = FALSE)
train <- df_clean[idx, ]
test  <- df_clean[-idx, ]

train_x <- subset(train, select = -cog_impair)
train_y <- as.numeric(as.character(train$cog_impair))  # 0/1

test_x  <- subset(test,  select = -cog_impair)
test_y  <- as.numeric(as.character(test$cog_impair))   # 0/1

# Save cleaned datasets for use in model training and comparison
save(train_x, train_y, test_x, test_y,
     file = "data/processed/cleaned_data_for_modeling.RData")

print("Cleaned data saved to: data/processed/cleaned_data_for_modeling.RData")

saveRDS(test, "data/processed/test.rds")
