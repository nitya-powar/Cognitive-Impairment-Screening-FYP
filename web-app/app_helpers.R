FEATURE_LABELS <- c(
  age_years = "Age (years)",
  education_level = "Education Level",
  LBDTCSI = "Total Cholesterol (mmol/L)",
  URDACT = "Albumin Creatinine Ratio (mg/g)",
  LBXMMASI = "Methylmalonic Acid (nmol/L)",
  LBDSCRSI = "Creatinine (umol/L)",
  LBDSGBSI = "Globulin (g/L)",
  grip_strength = "Grip Strength (kg)",
  height = "Height (cm)",
  LBXVIDMS = "Total Vitamin D (nmol/L)",
  mean_sbp = "Systolic BP (mmHg)",
  mean_dbp = "Diastolic BP (mmHg)",
  LBDHDDSI = "Direct HDL-Cholesterol (mmol/L)",
  LBDBCDSI = "Blood Cadmium (umol/L)",
  LBDGLUSI = "Fasting Glucose (mmol/L)",
  LBDTRSI = "Triglyceride (mmol/L)",
  bmi = "Body Mass Index (kg/m²)",
  waist = "Waist Circumference (cm)",
  weight = "Weight (kg)",
  phq9_sum = "PHQ-9 Score (0-27)",
  race = "Race/Ethnicity",
  marital_status = "Marital Status",
  gender = "Gender",
  phq9_depressed = "Depressed Mood"
)

FEATURE_CASTERS <- list(
  age_years = as.integer,
  education_level = as.integer,
  LBDTCSI = as.numeric,
  URDACT = as.numeric,
  LBXMMASI = as.numeric,
  LBDSCRSI = as.numeric,
  LBDSGBSI = as.numeric,
  grip_strength = as.numeric,
  height = as.numeric,
  LBXVIDMS = as.numeric,
  mean_sbp = as.numeric,
  mean_dbp = as.numeric,
  LBDHDDSI = as.numeric,
  LBDBCDSI = as.numeric,
  LBDGLUSI = as.numeric,
  LBDTRSI = as.numeric,
  bmi = as.numeric,
  waist = as.numeric,
  weight = as.numeric,
  phq9_sum = as.integer,
  race = as.integer,
  marital_status = as.integer,
  gender = as.integer,
  phq9_depressed = as.integer
)

FEATURE_RANGES <- list(
  age_years = c(min = 60, max = 120),
  LBDTCSI = c(min = 1, max = 12),
  URDACT = c(min = 0, max = 1000),
  LBXMMASI = c(min = 0, max = 1000),
  LBDSCRSI = c(min = 20, max = 300),
  LBDSGBSI = c(min = 10, max = 60),
  grip_strength = c(min = 5, max = 100),
  height = c(min = 100, max = 220),
  LBXVIDMS = c(min = 10, max = 200),
  mean_sbp = c(min = 80, max = 200),
  mean_dbp = c(min = 40, max = 120),
  LBDHDDSI = c(min = 0.3, max = 3.9),
  LBDBCDSI = c(min = 0, max = 1),
  LBDGLUSI = c(min = 2, max = 20),
  LBDTRSI = c(min = 0.2, max = 15),
  bmi = c(min = 15, max = 50),
  waist = c(min = 50, max = 200),
  weight = c(min = 30, max = 200),
  phq9_sum = c(min = 0, max = 27)
)

for (feature_name in names(FEATURE_RANGES)) {
  feature_range <- FEATURE_RANGES[[feature_name]]
  FEATURE_LABELS[[feature_name]] <- paste0(
    FEATURE_LABELS[[feature_name]],
    " [",
    feature_range[["min"]],
    "-",
    feature_range[["max"]],
    "]"
  )
}

# get input value - convert to the right type and return a clean input row for prediction
build_input_data <- function(input, feature_order) {
  input_values <- lapply(feature_order, function(feature_name) {
    FEATURE_CASTERS[[feature_name]](input[[feature_name]])
  })

  stats::setNames(as.data.frame(input_values, check.names = FALSE), feature_order)
}

find_out_of_range_features <- function(input) {
  invalid_features <- c()

  for (feature_name in names(FEATURE_RANGES)) {
    feature_value <- FEATURE_CASTERS[[feature_name]](input[[feature_name]])
    feature_range <- FEATURE_RANGES[[feature_name]]

    if (!is.na(feature_value) &&
        (feature_value < feature_range[["min"]] || feature_value > feature_range[["max"]])) {
      invalid_features <- c(
        invalid_features,
        paste0(
          FEATURE_LABELS[[feature_name]],
          " (entered: ",
          feature_value,
          ")"
        )
      )
    }
  }

  invalid_features
}

get_risk_level <- function(risk_percent) {
  if (risk_percent < 30) {
    "Low Risk"
  } else if (risk_percent < 70) {
    "Medium Risk"
  } else {
    "High Risk"
  }
}

format_explanation_item <- function(explanation_row) {
  feature_name <- explanation_row[["feature"]]
  feature_weight <- explanation_row[["feature_weight"]]
  feature_value <- explanation_row[["feature_value"]]
  display_label <- FEATURE_LABELS[[feature_name]] %||% feature_name
  display_label <- sub(" \\[[^]]+\\]$", "", display_label)

  div(
    style = "margin: 8px 0;",
    if (feature_weight > 0) span("⬆️") else span("⬇️"),
    strong(display_label),
    paste0(" (", round(as.numeric(feature_value), 2), ") "),
    if (feature_weight > 0) "increases risk" else "decreases risk"
  )
}
