library(lime)
library(ggplot2)
library(randomForest)

# 1) Load final RF model inputs
model <- readRDS("outputs/models/random_forest_model.rds")
train_x_imp <- readRDS("data/processed/RF_exports/train_x_imp_RF.rds")
test_x_imp <- readRDS("data/processed/RF_exports/test_x_imp_RF.rds")
test_y <- readRDS("data/processed/RF_exports/test_y_RF.rds")
results <- readRDS("data/processed/RF_exports/results_test_RF.rds")

lime_dir <- "outputs/lime/rf"
explainer_path <- "outputs/lime/rf/lime_explainer_RF.rds"

dir.create(lime_dir, recursive = TRUE, showWarnings = FALSE)

# 2) LIME model interface for RF
model_type.randomForest <- function(x, ...) "classification"
predict_model.randomForest <- function(x, newdata, ...) {
  as.data.frame(predict(x, newdata = newdata, type = "prob"))
}
registerS3method("model_type", "randomForest", model_type.randomForest)
registerS3method("predict_model", "randomForest", predict_model.randomForest)

train_df <- as.data.frame(train_x_imp)
test_df <- as.data.frame(test_x_imp)

# 3) Create explainer
explainer <- lime(
  train_df,
  model = model,
  bin_continuous = TRUE,
  n_bins = 10,
  quantile_bins = TRUE,
  kernel_width = 0.75
)

pred_probs_all <- predict_model.randomForest(model, test_df)[, "MCI"]

# 4) Pick 3 cases from each error group
select_strategic_cases <- function(case_type) {
  indices <- which(results$case == case_type)
  probs <- pred_probs_all[indices]

  if (case_type %in% c("TP", "FP")) {
    high_conf <- indices[which.max(probs)]
  } else {
    high_conf <- indices[which.min(probs)]
  }

  borderline <- indices[which.min(abs(probs - 0.5))]
  typical <- indices[which.min(abs(probs - median(probs)))]

  c(high_confidence = high_conf, borderline = borderline, typical = typical)
}

selected_cases <- list(
  TP = select_strategic_cases("TP"),
  FP = select_strategic_cases("FP"),
  FN = select_strategic_cases("FN"),
  TN = select_strategic_cases("TN")
)

# 5) Explain selected cases
for (group in names(selected_cases)) {
  for (case_name in names(selected_cases[[group]])) {
    case_idx <- selected_cases[[group]][[case_name]]
    case_data <- test_df[case_idx, , drop = FALSE]
    actual <- test_y[case_idx]
    pred_prob_mci <- predict_model.randomForest(model, case_data)[, "MCI"]
    predicted <- results$predicted[case_idx]

    explanation <- lime::explain(
      case_data,
      explainer = explainer,
      n_features = 8,
      labels = "MCI"
    )

    p <- plot_features(explanation) +
      ggtitle(sprintf(
        "%s: %s Case %d\nActual=%d, Predicted=%d",
        group, case_name, case_idx, actual, predicted
      )) +
      theme_minimal(base_size = 11)

    print(p)

    ggsave(
      sprintf("%s/%s_%s_%d.png", lime_dir, group, case_name, case_idx),
      plot = p,
      width = 7,
      height = 4.5,
      dpi = 300
    )
  }
}

saveRDS(explainer, explainer_path)
