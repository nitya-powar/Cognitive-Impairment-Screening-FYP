library(randomForest)
library(fastshap)
library(shapviz)

rf_model <- readRDS("outputs/models/random_forest_model.rds")
train_x_imp <- readRDS("data/processed/RF_exports/train_x_imp_RF.rds")
test_x_imp <- readRDS("data/processed/RF_exports/test_x_imp_RF.rds")
results <- readRDS("data/processed/RF_exports/results_test_RF.rds")

dir.create("outputs/figures/error_analysis_SHAP", recursive = TRUE, showWarnings = FALSE)

pred_wrapper <- function(object, newdata) {
  predict(object, newdata = newdata, type = "prob")[, "MCI"]
}

set.seed(123)
train_idx <- sample(seq_len(nrow(train_x_imp)), min(250, nrow(train_x_imp)))
train_sample <- train_x_imp[train_idx, , drop = FALSE]

shap_train <- fastshap::explain(
  object = rf_model,
  X = train_sample,
  pred_wrapper = pred_wrapper,
  nsim = 20,
  adjust = TRUE
)

sv_train <- shapviz(shap_train, X = train_sample)

png("outputs/figures/error_analysis_SHAP/SHAP_global_summary_RF.png", width = 1000, height = 700)
print(sv_importance(sv_train, kind = "beeswarm"))
dev.off()

saveRDS(shap_train, "outputs/shap_values_RF.rds")

save_group_plot <- function(case_name) {
  idx <- which(results$case == case_name)
  if (length(idx) == 0) return(NULL)

  group_idx <- idx[seq_len(min(50, length(idx)))]
  group_data <- test_x_imp[group_idx, , drop = FALSE]

  shap_group <- fastshap::explain(
    object = rf_model,
    X = train_sample,
    pred_wrapper = pred_wrapper,
    newdata = group_data,
    nsim = 20,
    adjust = TRUE
  )

  sv_group <- shapviz(shap_group, X = group_data)

  png(paste0("outputs/figures/error_analysis_SHAP/", case_name, "_SHAP_RF.png"), width = 800, height = 600)
  print(sv_importance(sv_group, kind = "beeswarm"))
  dev.off()
}

save_group_plot("FP")
save_group_plot("FN")
save_group_plot("TP")
save_group_plot("TN")
