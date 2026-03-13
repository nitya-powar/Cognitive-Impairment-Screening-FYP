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
          make_numeric_input("age_years", "Age (years)", 65, 60, 120, 1),
          make_select_input("gender", "Gender", list("Male" = 1, "Female" = 2), 1),
          make_select_input(
              "race",
              "Race/Ethnicity",
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
              "Education Level",
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
              "Marital Status",
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
          make_numeric_input("bmi", "Body Mass Index (kg/m²)", 25, 15, 50, 0.1),
          make_numeric_input("mean_sbp", "Systolic BP (mmHg)", 120, 80, 200, 1),
          make_numeric_input("mean_dbp", "Diastolic BP (mmHg)", 80, 40, 120, 1),
          make_numeric_input("waist", "Waist Circumference (cm)", 90, 50, 200, 0.5),
          make_numeric_input("height", "Height (cm)", 170, 100, 220, 0.5),
          make_numeric_input("weight", "Weight (kg)", 70, 30, 200, 0.1),
          make_numeric_input("grip_strength", "Grip Strength (kg)", 30, 5, 100, 0.1),
          make_numeric_input("phq9_sum", "PHQ-9 Score (0-27)", 5, 0, 27, 1),
          make_select_input(
              "phq9_depressed",
              "PHQ-9 Depressed Mood",
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
          make_numeric_input("LBXMMASI", "Methylmalonic Acid (nmol/L)", 200, 0, 1000, 1),
          make_numeric_input("LBDHDD", "Direct HDL-Cholesterol (mg/dL)", 50, 10, 150, 1),
          make_numeric_input("LBXSTR", "Triglycerides (mg/dL)", 150, 30, 500, 1),
          make_numeric_input("LBXSLDSI", "Lactate Dehydrogenase (U/L)", 150, 50, 500, 1),
          make_numeric_input("LBXSGB", "Globulin (g/dL)", 3.0, 1.0, 6.0, 0.1),
          make_numeric_input("LBXSCR", "Creatinine (mg/dL)", 1.0, 0.3, 3.0, 0.1),
          make_numeric_input("LBXMCVSI", "Mean Cell Volume (fL)", 90, 60, 120, 0.1),
          make_numeric_input("LBXRDW", "Red Cell Distribution Width (%)", 13.0, 10.0, 20.0, 0.1),
          make_numeric_input("LBXMOPCT", "Monocyte Percent (%)", 8.0, 2.0, 15.0, 0.1),
          make_numeric_input("LBDB12", "Vitamin B12 (pmol/L)", 300, 100, 1000, 1),
          make_numeric_input("LBDHDDSI", "Direct HDL-Cholesterol (mmol/L)", 1.3, 0.3, 3.9, 0.01),
          make_numeric_input("LBXNEPCT", "Segmented Neutrophils Percent (%)", 60.0, 30.0, 80.0, 0.1),
          make_numeric_input("LBXGH", "Glycohemoglobin (%)", 5.5, 4.0, 12.0, 0.1),
          make_numeric_input("LBXVIDMS", "25-hydroxyvitamin D (nmol/L)", 60, 10, 200, 1),
          make_numeric_input("LBXLYPCT", "Lymphocyte Percent (%)", 30.0, 10.0, 50.0, 0.1),
          make_numeric_input("LBDLYMNO", "Lymphocyte Number (1000 cells/uL)", 2.0, 0.5, 5.0, 0.1),
          make_numeric_input("LBXPLTSI", "Platelet Count (1000 cells/uL)", 250, 100, 500, 1),
          make_numeric_input("LBXSBU", "Blood Urea Nitrogen (mg/dL)", 15, 5, 50, 0.1),
          make_numeric_input("LBXMC", "Mean Cell Hemoglobin Concentration (g/dL)", 34.0, 30.0, 38.0, 0.1),
          make_numeric_input("LBXHCT", "Hematocrit (%)", 42.0, 30.0, 55.0, 0.1)
        )
    }
