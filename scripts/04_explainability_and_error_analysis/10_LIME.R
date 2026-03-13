library(lime)
library(ggplot2)
library(randomForest)

# ----------------------------------------------------------------------------------------
# 1) Load final RF model inputs
# ----------------------------------------------------------------------------------------
model <- readRDS("outputs/models/random_forest_model.rds")
train_x_imp <- readRDS("data/processed/train_x_imp_RF.rds")
test_x_imp <- readRDS("data/processed/test_x_imp_RF.rds")
test_y <- readRDS("data/processed/test_y.rds")
results <- readRDS("data/interim/results_test_RF.rds")
decision_threshold <- 0.471
lime_dir <- "outputs/lime/rf"
explainer_path <- "outputs/lime_explainer_RF.rds"

dir.create(lime_dir, recursive = TRUE, showWarnings = FALSE)

# ----------------------------------------------------------------------------------------
# 2) LIME model interface for RF
# ----------------------------------------------------------------------------------------
model_type.randomForest <- function(x, ...) "classification"
predict_model.randomForest <- function(x, newdata, ...) {
  as.data.frame(predict(x, newdata, type = "prob"))
}

train_df <- as.data.frame(train_x_imp)
test_df <- as.data.frame(test_x_imp)
test_pred <- predict_model.randomForest(model, test_df[1:5, , drop = FALSE])
pred_probs_all <- predict_model.randomForest(model, test_df)[, "MCI"]

print("Test prediction function (first 5 cases):")
print(test_pred)

# ----------------------------------------------------------------------------------------
# 3) Create LIME explainer
# ----------------------------------------------------------------------------------------
explainer <- lime(
  train_df,
  model = model,
  bin_continuous = TRUE,
  n_bins = 10,
  quantile_bins = TRUE,
  kernel_width = 0.75
)

print("LIME explainer created successfully!")
print(class(explainer))

# ----------------------------------------------------------------------------------------
# 4) Select 3 strategic cases from each group
# ----------------------------------------------------------------------------------------
print("Number of each case type:")
print(table(results$case))

select_strategic_cases <- function(case_type, threshold) {
  indices <- which(results$case == case_type)
  probs <- pred_probs_all[indices]

  if (case_type %in% c("TP", "FP")) {
    high_conf <- indices[which.max(probs)]
  } else {
    high_conf <- indices[which.min(probs)]
  }

  borderline <- indices[which.min(abs(probs - threshold))]
  typical <- indices[which.min(abs(probs - median(probs)))]

  c(
    high_confidence = high_conf,
    borderline = borderline,
    typical = typical
  )
}

selected_cases <- list(
  TP = select_strategic_cases("TP", decision_threshold),
  FP = select_strategic_cases("FP", decision_threshold),
  FN = select_strategic_cases("FN", decision_threshold),
  TN = select_strategic_cases("TN", decision_threshold)
)

print("Strategically selected case indices:")
print(selected_cases)

# ----------------------------------------------------------------------------------------
# 5) Explain all 12 cases (3 × 4 groups)
# ----------------------------------------------------------------------------------------
for (group in names(selected_cases)) {
  for (case_name in names(selected_cases[[group]])) {
    case_idx <- selected_cases[[group]][[case_name]]
    case_data <- test_df[case_idx, , drop = FALSE]
    actual <- test_y[case_idx]
    pred_probs <- predict_model.randomForest(model, case_data)
    pred_prob_mci <- pred_probs[, "MCI"]
    predicted <- ifelse(pred_prob_mci > decision_threshold, 1, 0)

    cat(sprintf(
      "\n%s %s Case %d: Actual=%d, Predicted=%d (Prob=%.3f)\n",
      group, case_name, case_idx, actual, predicted, pred_prob_mci
    ))

    explanation <- lime::explain(
      case_data,
      explainer = explainer,
      n_features = 8,
      n_labels = 1
    )

    print(explanation[, c("feature", "feature_value", "feature_weight")])

    p <- plot_features(explanation) +
      ggtitle(sprintf(
        "%s: %s Case %d\nActual=%d, Predicted=%d",
        group, case_name, case_idx, actual, predicted
      ))

    print(p)

    ggsave(
      sprintf("%s/%s_%s_%d.png", lime_dir, group, case_name, case_idx),
      plot = p,
      width = 10,
      height = 6
    )
  }
}

saveRDS(explainer, explainer_path)
