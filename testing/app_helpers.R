
FEATURE_LABELS <- c(
  age_years = "Age",
  gender = "Gender",
  education_level = "Education Level",
  race = "Race/Ethnicity",
  marital_status = "Marital Status",
  bmi = "Body Mass Index",
  mean_sbp = "Systolic Blood Pressure",
  mean_dbp = "Diastolic Blood Pressure",
  waist = "Waist Circumference",
  height = "Height",
  weight = "Weight",
  grip_strength = "Grip Strength",
  phq9_sum = "PHQ-9 Score",
  phq9_depressed = "Depressed Mood",
  LBXMMASI = "Methylmalonic Acid",
  LBDHDD = "HDL Cholesterol",
  LBXSTR = "Triglycerides",
  LBXSLDSI = "Lactate Dehydrogenase",
  LBXSGB = "Globulin",
  LBXSCR = "Creatinine",
  LBXMCVSI = "Mean Cell Volume",
  LBXRDW = "Red Cell Distribution Width",
  LBXMOPCT = "Monocyte Percentage",
  LBDB12 = "Vitamin B12",
  LBDHDDSI = "HDL Cholesterol",
  LBXNEPCT = "Neutrophil Percentage",
  LBXGH = "Glycohemoglobin",
  LBXVIDMS = "Vitamin D",
  LBXLYPCT = "Lymphocyte Percentage",
  LBDLYMNO = "Lymphocyte Count",
  LBXPLTSI = "Platelet Count",
  LBXSBU = "Blood Urea Nitrogen",
  LBXMC = "Mean Cell Hemoglobin Concentration",
  LBXHCT = "Hematocrit"
)

FEATURE_CASTERS <- list(
  age_years = as.integer,
  gender = as.integer,
  education_level = as.integer,
  race = as.integer,
  marital_status = as.integer,
  bmi = as.numeric,
  mean_sbp = as.numeric,
  mean_dbp = as.numeric,
  waist = as.numeric,
  height = as.numeric,
  weight = as.numeric,
  grip_strength = as.numeric,
  phq9_sum = as.integer,
  phq9_depressed = as.integer,
  LBXMMASI = as.numeric,
  LBDHDD = as.integer,
  LBXSTR = as.integer,
  LBXSLDSI = as.integer,
  LBXSGB = as.numeric,
  LBXSCR = as.numeric,
  LBXMCVSI = as.numeric,
  LBXRDW = as.numeric,
  LBXMOPCT = as.numeric,
  LBDB12 = as.integer,
  LBDHDDSI = as.numeric,
  LBXNEPCT = as.numeric,
  LBXGH = as.numeric,
  LBXVIDMS = as.numeric,
  LBXLYPCT = as.numeric,
  LBDLYMNO = as.numeric,
  LBXPLTSI = as.integer,
  LBXSBU = as.integer,
  LBXMC = as.numeric,
  LBXHCT = as.numeric
)

build_input_data <- function(input, feature_order) {
  input_values <- lapply(feature_order, function(feature_name) {
    caster <- FEATURE_CASTERS[[feature_name]]
    
    if (is.null(caster)) {
      stop(sprintf("No caster defined for feature '%s'", feature_name))
    }
    
    caster(input[[feature_name]])
  })
  
  stats::setNames(as.data.frame(input_values, check.names = FALSE), feature_order)
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
  
  div(
    style = "margin: 8px 0;",
    if (feature_weight > 0) span("⬆️") else span("⬇️"),
    strong(FEATURE_LABELS[[feature_name]] %||% feature_name),
    paste0(" (", round(as.numeric(feature_value), 2), ") "),
    if (feature_weight > 0) "increases risk" else "decreases risk"
  )
}