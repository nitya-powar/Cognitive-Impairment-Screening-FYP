# Script Notes

This file only explains the demographic and cognitive test codes used in `01_demo_and_label_creation.R`.

## Demographics

-   `age_years = RIDAGEYR` Age in years. `80` means 80 and above.

-   `gender = RIAGENDR` `1 = Male` `2 = Female`

-   `race = RIDRETH3` `1 = Mexican American` `2 = Other Hispanic` `3 = Non-Hispanic White` `4 = Non-Hispanic Black` `6 = Non-Hispanic Asian` `7 = Other race, including multi-racial`

-   `education_level = DMDEDUC2` `1 = Less than 9th grade` `2 = 9-11th grade` `3 = High school graduate / GED` `4 = Some college or AA degree` `5 = College graduate or above` `7 = Refused` `9 = Don't know`

-   `marital_status = DMDMARTL` `1 = Married` `2 = Widowed` `3 = Divorced` `4 = Separated` `5 = Never married` `6 = Living with partner` `77 = Refused` `99 = Don't know`

## Cognitive Tests

-   `cerad_trial1 = CFDCST1` First immediate recall trial.

-   `cerad_trial2 = CFDCST2` Second immediate recall trial.

-   `cerad_trial3 = CFDCST3` Third immediate recall trial.

-   `cerad_delayed = CFDCSR` Delayed recall score.

-   `animal_fluency = CFDAST` Number of animals named in one minute.

-   `dsst_score = CFDDS` Digit Symbol Substitution Test score.

## Cognitive Impairment Label

-   `cerad_total = cerad_trial1 + cerad_trial2 + cerad_trial3`
-   `impaired_cerad = 1` if `cerad_delayed < 5` or `cerad_total < 17`
-   `impaired_dsst = 1` if `dsst_score < 34`
-   `impaired_aflu = 1` if `animal_fluency < 14`
-   `cog_impair = 1` if any of the three impairment flags is present
