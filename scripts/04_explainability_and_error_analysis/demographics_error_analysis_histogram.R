FP_data <- read.csv("data/processed/error_groups/RF/FP_data.csv")
TP_data <- read.csv("data/processed/error_groups/RF/TP_data.csv")
FN_data <- read.csv("data/processed/error_groups/RF/FN_data.csv")
TN_data <- read.csv("data/processed/error_groups/RF/TN_data.csv")

plot_case_histograms <- function(filename, column, title_prefix, kind = "bar") {
  png(paste0("outputs/figures/error_analysis_histograms/", filename), width = 800, height = 600)
  par(mfrow = c(2, 2))

  plot_one <- function(data, label) {
    values <- data[[column]]
    if (kind == "hist") {
      hist(values, main = paste(label, title_prefix), xlab = column, col = "lightblue")
    } else {
      barplot(table(values), main = paste(label, title_prefix), col = "lightblue")
    }
    mtext(paste("n =", nrow(data)), side = 3, line = 0.5, cex = 0.8)
  }

  plot_one(TP_data, "TP:")
  plot_one(FP_data, "FP:")
  plot_one(FN_data, "FN:")
  plot_one(TN_data, "TN:")
  dev.off()
}

plot_case_histograms("01_age_distribution.png", "age_years", "Age", kind = "hist")
plot_case_histograms("02_gender.png", "gender", "Gender")
plot_case_histograms("03_marital_status.png", "marital_status", "Marital")
plot_case_histograms("04_race.png", "race", "Race")
plot_case_histograms("05_education_level.png", "education_level", "Education")
