library(randomForest)
library(fastshap)
library(shapviz)

# use gini impurity than this.

train_x_imp <- readRDS("data/processed/train_x_imp_RF.rds")
model <- readRDS("outputs/models/random_forest_model.rds")

pred_wrapper <- function(object, newdata) {
  predict(object, newdata, type = "prob")[, "MCI"]
}

set.seed(123)
shap_sample <- train_x_imp[sample(seq_len(nrow(train_x_imp)), min(200, nrow(train_x_imp))), , drop = FALSE]

shap_values <- fastshap::explain(
  object = model,
  X = shap_sample,
  pred_wrapper = pred_wrapper,
  nsim = 20
)

shap_obj <- shapviz::shapviz(shap_values, X = shap_sample)

png("outputs/figures/SHAP_global_summary_RF.png", width = 1000, height = 700)
print(sv_importance(shap_obj, kind = "bar", max_display = 20))
dev.off()

saveRDS(shap_values, "outputs/shap_values_RF.rds")
