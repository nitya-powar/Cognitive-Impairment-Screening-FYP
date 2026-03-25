make_numeric_input <- function(id, label, value, min, max, step) {
  numericInput(
    inputId = id,
    label = label,
    value = value,
    min = min,
    max = max,
    step = step
  )
}

make_select_input <- function(id, label, choices, selected) {
  selectInput(
    inputId = id,
    label = label,
    choices = choices,
    selected = selected
  )
}

demographicInputs <- function() {
  tagList(
    h4("Demographics", style = "color: #2c3e50;"),
    make_numeric_input("age_years", FEATURE_LABELS[["age_years"]], 65, 60, 120, 1),
    make_select_input("gender", FEATURE_LABELS[["gender"]], list("Male" = 1, "Female" = 2), 1),
    make_select_input(
      "race",
      FEATURE_LABELS[["race"]],
      list(
        "Mexican American" = 1,
        "Other Hispanic" = 2,
        "Non-Hispanic White" = 3,
        "Non-Hispanic Black" = 4,
        "Non-Hispanic Asian" = 5
      ),
      3
    ),
    make_select_input(
      "education_level",
      FEATURE_LABELS[["education_level"]],
      list(
        "Less than 9th grade" = 1,
        "9-11th grade" = 2,
        "High school graduate/GED" = 3,
        "Some college or AA" = 4,
        "College graduate or above" = 5
      ),
      3
    ),
    make_select_input(
      "marital_status",
      FEATURE_LABELS[["marital_status"]],
      list(
        "Married" = 1,
        "Widowed" = 2,
        "Divorced" = 3,
        "Separated" = 4,
        "Never married" = 5,
        "Living with partner" = 6
      ),
      1
    ),
    make_numeric_input("bmi", FEATURE_LABELS[["bmi"]], 25, 15, 50, 0.1),
    make_numeric_input("mean_sbp", FEATURE_LABELS[["mean_sbp"]], 120, 80, 200, 1),
    make_numeric_input("mean_dbp", FEATURE_LABELS[["mean_dbp"]], 80, 40, 120, 1),
    make_numeric_input("waist", FEATURE_LABELS[["waist"]], 90, 50, 200, 0.5),
    make_numeric_input("height", FEATURE_LABELS[["height"]], 170, 100, 220, 0.5),
    make_numeric_input("weight", FEATURE_LABELS[["weight"]], 70, 30, 200, 0.1),
    make_numeric_input("grip_strength", FEATURE_LABELS[["grip_strength"]], 30, 5, 100, 0.1),
    make_numeric_input("phq9_sum", FEATURE_LABELS[["phq9_sum"]], 5, 0, 27, 1),
    make_select_input(
      "phq9_depressed",
      FEATURE_LABELS[["phq9_depressed"]],
      list(
        "Not at all" = 0,
        "Several days" = 1,
        "More than half the days" = 2,
        "Nearly every day" = 3
      ),
      0
    )
  )
}

labInputs <- function() {
  tagList(
    h4("Lab Values", style = "color: #2c3e50;"),
    make_numeric_input("LBDTCSI", FEATURE_LABELS[["LBDTCSI"]], 4.5, 1.0, 12.0, 0.1),
    make_numeric_input("URDACT", FEATURE_LABELS[["URDACT"]], 10, 0, 1000, 1),
    make_numeric_input("LBXMMASI", FEATURE_LABELS[["LBXMMASI"]], 200, 0, 1000, 1),
    make_numeric_input("LBDSCRSI", FEATURE_LABELS[["LBDSCRSI"]], 80, 20, 300, 1),
    make_numeric_input("LBDSGBSI", FEATURE_LABELS[["LBDSGBSI"]], 30, 10, 60, 0.1),
    make_numeric_input("LBXVIDMS", FEATURE_LABELS[["LBXVIDMS"]], 60, 10, 200, 1),
    make_numeric_input("LBDHDDSI", FEATURE_LABELS[["LBDHDDSI"]], 1.3, 0.3, 3.9, 0.01),
    make_numeric_input("LBDBCDSI", FEATURE_LABELS[["LBDBCDSI"]], 0.01, 0, 1, 0.001),
    make_numeric_input("LBDGLUSI", FEATURE_LABELS[["LBDGLUSI"]], 5.5, 2.0, 20.0, 0.1),
    make_numeric_input("LBDTRSI", FEATURE_LABELS[["LBDTRSI"]], 1.5, 0.2, 15.0, 0.1)
  )
}
