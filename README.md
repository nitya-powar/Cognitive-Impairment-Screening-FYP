# Submission Contents

This submission contains the final code, data, outputs and web application for the Cognitive Impairment project.

## Files and folders included

`README.md`\
Short guide to the submitted project contents.

`CI-FYP.Rproj`\
RStudio project file for opening the project.

`data/`\
Project datasets used for analysis and modeling.

-   `raw/`: original source data files.
-   `processed/`: cleaned datasets, train/test data, model exports, and error-analysis csv tables.

`outputs/`\
Saved project results.

-   `figures/`: charts and visual outputs.
-   `models/`: trained model files.
-   `lime/`: LIME explanation outputs.

`scripts/`\
Main analysis pipeline.

-   `01_data_preparation/`: data cleaning, merging, missingness checks, and train/test split.
-   `02_model_development/`: feature resampling and model training.
-   `03_evaluation_and_reporting/`: fairness and calibration analysis.
-   `04_explainability_and_error_analysis/`: SHAP, LIME, and error analysis.
-   top-level `.md` and `.html` files: project notes, experiment tracking, and feature tracking.

`web-app/`\
Shiny app for entering patient information and generating CI risk predictions.

-   `app.R`: app layout and launch file.
-   `app_inputs.R`: user input fields seen on the UI.
-   `app_helpers.R`: helper functions and validation.
-   `app_server.R`: prediction logic and explanation output.
-   `.rds` files: saved model and explainer used by the app.

## Notes

Temporary local files such as `.Rhistory`, `.RData`, `Rplots.pdf`, `.DS_Store`, and `.Rproj.user/` are not part of the final submission.
