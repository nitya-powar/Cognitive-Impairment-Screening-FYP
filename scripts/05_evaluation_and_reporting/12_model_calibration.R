library(ggplot2)
library(dplyr)

# ----------------------------------------------------------------------------------------
# 1) Load predictions and actuals
# ----------------------------------------------------------------------------------------
pred_prob <- readRDS('data/processed/pred_prob_RF.rds')
test_y <- readRDS('data/processed/test_y.rds')

# ----------------------------------------------------------------------------------------
# 2) Brier Score (Mean Squared Error of probabilities)
# ----------------------------------------------------------------------------------------
brier_score <- mean((pred_prob - test_y)^2)
cat("Brier Score:", round(brier_score, 3), "\n") # the lower the better. below 0.3 is generally considered good.

# ----------------------------------------------------------------------------------------
# 3) Calibration Plot (Reliability diagram)
# ----------------------------------------------------------------------------------------
calibration_data <- data.frame(
  predicted_prob = pred_prob,
  actual = test_y
)

# Bin probabilities into deciles
calibration_data$bin <- cut(calibration_data$predicted_prob, 
                            breaks = seq(0, 1, by = 0.2),
                            include.lowest = TRUE)

# Calculate mean predicted vs actual per bin
calibration_summary <- calibration_data %>%
  group_by(bin) %>%
  summarise(
    mean_predicted = mean(predicted_prob),
    mean_actual = mean(actual),
    n = n()
  )

# Plot calibration curve
calibration_plot <- ggplot(calibration_summary, aes(x = mean_predicted, y = mean_actual)) +
  geom_point(aes(size = n), color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  geom_smooth(method = "loess", se = TRUE, color = "darkgreen") +
  labs(title = "Calibration Curve (Reliability Diagram)",
       x = "Mean Predicted Probability",
       y = "Mean Actual Outcome",
       subtitle = paste("Brier Score =", round(brier_score, 4))) +
  theme_minimal() +
  coord_equal()

print(calibration_plot)

# ----------------------------------------------------------------------------------------
# 4) Over/Under-confidence analysis
# ----------------------------------------------------------------------------------------
# Expected Calibration Error (ECE)
ece <- calibration_summary %>%
  mutate(weight = n / sum(n),
         error = abs(mean_predicted - mean_actual)) %>%
  summarise(ece = sum(weight * error)) %>%
  pull(ece)

cat("\nExpected Calibration Error (ECE):", round(ece, 4), "\n")

# Better: Check if extreme predictions are CORRECT
overconfident_wrong <- mean(
  (pred_prob > 0.8 & test_y == 0) |  # Very sure of MCI but wrong
    (pred_prob < 0.2 & test_y == 1)    # Very sure of No_MCI but wrong
)

cat("\nPercentage of WRONGLY overconfident predictions:", 
    round(overconfident_wrong * 100, 1), "%\n")

# Also check calibration of extreme predictions separately
high_conf <- pred_prob > 0.9
if(sum(high_conf) > 0) {
  cat("When predicting >90% MCI probability:\n")
  cat("  Actual MCI rate:", round(mean(test_y[high_conf]), 3), "\n")
  cat("  Should be close to 0.95+ for well-calibrated\n")
}

low_conf <- pred_prob < 0.1  
if(sum(low_conf) > 0) {
  cat("When predicting <10% MCI probability:\n")
  cat("  Actual MCI rate:", round(mean(test_y[low_conf]), 3), "\n")
  cat("  Should be close to 0.05- for well-calibrated\n")
}

# ----------------------------------------------------------------------------------------
# 5) Save results
# ----------------------------------------------------------------------------------------
calibration_results <- list(
  brier_score = brier_score,
  ece = ece,
  overconfident_pct = overconfident_wrong,
  calibration_data = calibration_summary
)

saveRDS(calibration_results, 
        'outputs/calibration_results.rds')

# Save plot
ggsave('outputs/plots/calibration_curve.png',
       calibration_plot, width = 8, height = 6, dpi = 300)
