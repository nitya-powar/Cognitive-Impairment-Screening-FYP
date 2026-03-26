library(xgboost)
library(ggplot2)
library(dplyr)

imp <- xgb.importance(
  model = xgb_model,
  feature_names = colnames(train_mat)
)

imp <- imp %>%
  arrange(desc(Gain))

print(head(imp, 50))

imp20 <- head(imp, 20)

print(
  ggplot(imp20, aes(x = reorder(Feature, Gain), y = Gain)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "XGBoost Feature Importance (Gain)",
      x = "Feature",
      y = "Gain"
    ) +
    theme_minimal()
)

print(
  ggplot(imp20, aes(x = reorder(Feature, Cover), y = Cover)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "XGBoost Feature Importance (Cover)",
      x = "Feature",
      y = "Cover"
    ) +
    theme_minimal()
)

print(
  ggplot(imp20, aes(x = reorder(Feature, Frequency), y = Frequency)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "XGBoost Feature Importance (Frequency)",
      x = "Feature",
      y = "Frequency"
    ) +
    theme_minimal()
)
