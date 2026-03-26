library(randomForest)
library(fastshap)
library(shapviz)

# ----------------------------------------------------------------------------------------
# Load model inputs
# ----------------------------------------------------------------------------------------
rf_model <- readRDS("outputs/models/random_forest_model.rds")
train_x_imp <- readRDS("data/processed/RF_exports/train_x_imp_RF.rds")

dir.create("outputs/figures/error_analysis_SHAP", recursive = TRUE, showWarnings = FALSE)

pred_wrapper <- function(object, newdata) {
  predict(object, newdata = newdata, type = "prob")[, "CI"]
}

# ----------------------------------------------------------------------------------------
# Global SHAP summary
# ----------------------------------------------------------------------------------------
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
