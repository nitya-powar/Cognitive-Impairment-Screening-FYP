library(xgboost)

# ----------------------------------------------------------------------------------------
# Prepare matrices and training weights
# ----------------------------------------------------------------------------------------
train_mat <- as.matrix(train_x_imp)
test_mat  <- as.matrix(test_x_imp)

C_FN <- 1.5
C_FP <- 1.0

#sample_w <- ifelse(train_y_resampled == 1, C_FN, C_FP)
sample_w <- ifelse(train_y == 1, C_FN, C_FP)
sample_w <- sample_w / mean(sample_w)

dtrain <- xgb.DMatrix(
  data   = train_mat,
#  label  = train_y_resampled,
  label  = train_y,
  weight = sample_w
)

dtest <- xgb.DMatrix(
  data  = test_mat,
  label = test_y
)

# ----------------------------------------------------------------------------------------
# Hyperparameter tuning
# ----------------------------------------------------------------------------------------
param_grid <- expand.grid(
  max_depth = c(3, 5),
  eta = c(0.05, 0.1),
  subsample = c(0.8),
  colsample_bytree = c(0.8),
  min_child_weight = c(1, 3),
  gamma = c(0, 0.1)
)

set.seed(123)
cv_results <- lapply(seq_len(nrow(param_grid)), function(i) {
  params <- c(
    list(
      objective = "binary:logistic",
      eval_metric = "logloss",
      lambda = 1.0,
      seed = 123
    ),
    as.list(param_grid[i, ])
  )
  
  cv <- xgb.cv(
    params = params,
    data = dtrain,
    nrounds = 500,
    nfold = 5,
    early_stopping_rounds = 20,
    prediction = TRUE,
    verbose = 0
  )
  
  list(
    params = params,
    best_nrounds = cv$best_iteration,
    best_logloss = min(cv$evaluation_log$test_logloss_mean),
    pred = cv$pred,
    evaluation_log = cv$evaluation_log
  )
})

best_idx <- which.min(sapply(cv_results, function(x) x$best_logloss))
best_params <- cv_results[[best_idx]]$params
best_nrounds <- cv_results[[best_idx]]$best_nrounds
cv_pred <- cv_results[[best_idx]]$pred
best_eval_log <- cv_results[[best_idx]]$evaluation_log

mean_logloss <- best_eval_log$test_logloss_mean[best_nrounds]
sd_logloss   <- best_eval_log$test_logloss_std[best_nrounds]
var_logloss  <- sd_logloss^2

cat("CV mean logloss:", round(mean_logloss, 4), "\n")
cat("CV SD logloss:", round(sd_logloss, 4), "\n")
cat("CV variance:", round(var_logloss, 5), "\n")

# ----------------------------------------------------------------------------------------
# Train the final XGBoost model
# ----------------------------------------------------------------------------------------
xgb_model <- xgb.train(
  params  = best_params,
  data    = dtrain,
  nrounds = best_nrounds,
  verbose = 0
)
