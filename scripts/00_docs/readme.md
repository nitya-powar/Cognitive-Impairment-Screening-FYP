---
editor_options: 
  markdown: 
    wrap: 72
---

## 01 and 02:

## DEMOGRAPHICS

-   **age_years = RIDAGEYR,**\
    60-79 (range)\
    80 (80 and over)

-   **gender = RIAGENDR,**\
    1 male 2 female

-   **race = RIDRETH3,**\
    1 Mexican american,\
    2 other hispanic,\
    3 Non-hispanic white,\
    4 Non-hispanic black,\
    5 -\
    6 Non-hispanic Asian,\
    7 Other race - including multi racial

-   **education_level = DMDEDUC2,**\
    1 Less than 9th grade\
    2 9-11th grade (Includes 12th grade with no diploma)\
    3 High school graduate/GED or equivalent\
    4 Some college or AA degree\
    5 College graduate or above\
    6 -\
    7 Refused\
    8 -\
    9 Don't Know

-   **income_to_poverty_ratio = INDFMPIR,**\
    0-4.99 (range)\
    5 (5 and above)

-   **marital_status = DMDMARTL**\
    1 Married\
    2 Widowed\
    3 Divorced\
    4 Separated\
    5 Never married\
    6 Living with partner\
    77 Refused\
    99 Don't Know

## COGNITIVE TESTS

-   cerad_trial1 = CFDCST1\
    First immediate word recall trial (0-10)

-   cerad_trial2 = CFDCST2\
    Second immediate word recall trial (0-10)

-   cerad_trial3 = CFDCST3\
    Third immediate word recall trial (0-10)

-   cerad_delayed = CFDCSR\
    Delayed word recall after interference (0-10)

-   animal_fluency= CFDAST\
    Number of animals named in one minute

-   dsst_score = CFDDS

    Digit Symbol Substitution Test score (processing speed)

## FINAL DATAFRAME (clean) WITH demo, cog_imp flag, and laboratory tests

-   Pareto\
    The Pareto chart visualizes the distribution of missing values
    across variables, helping prioritize which columns to address during
    data cleaning

## FINAL DATAFRAME WITH CONDITIONS

-   Same DF as above but with 3 examination and 1 questionnaire data

    1.  Blood pressure, body measures and grip strength

    2.  Depression

------------------------------------------------------------------------

## 03:

-   This file does the exploratory data analysis: meaning, here we are
    exploring the demographics data available in our "customised" data
    frame.

-   These number change slightly when model removes some rows that have
    more than 50%\> missing values

------------------------------------------------------------------------

## 04:

-   Purpose

    -   identify patterns of missingness

    -   check for demographic bias

    -   clean data for MCI prediction modeling

-   Process

    1.  **First, we calculate the percentage of missing values for each
        laboratory variable** and visualize the patterns using heatmaps.

    2.  **Next, we identify which laboratory tests tend to be missing
        together** in the same participants, revealing systematic
        patterns in data collection.

    3.  **We then examine whether missingness in the most frequently
        absent tests relates to demographic factors** like age, gender,
        race, and education level.

    4.  **Based on this analysis, we clean the dataset by removing
        columns and rows with more than 50% missing values** to ensure
        model reliability.

    5.  **We also drop non-laboratory columns** such as participant IDs
        and survey weights that shouldn't be used as predictive
        features.

    6.  **After cleaning, we check overall missingness patterns** by
        calculating what percentage of tests each participant is
        missing.

    7.  **Finally, we discover systematic bias:** younger participants
        and certain racial groups have significantly more missing data,
        which must be addressed to ensure fair model performance.

-   Output

    -   Saved cleaned data sets: train_x, train_y, test_x, test_y

-   BIAS for missing data:

    -   **Age Bias:** Participants with \>10% missing data are 2.5 years
        younger on average (67.3 vs 69.9 years).

    -   **Race Bias:** Participants with \>10% missing data have higher
        race codes (mean 3.87 vs 3.17), meaning more Non-Hispanic Black,
        Asian, and Other/Multi-racial participants have incomplete data
        compared to Non-Hispanic White participants.

    -   Participants with \>10% missing data have **higher poverty
        ratios** (mean 3.18 vs 2.64, p=0.096), suggesting **lower-income
        individuals** have more incomplete lab data.

-   BIAS fairness check - MCI prevalence differs by demographics

    -   check oneNote

------------------------------------------------------------------------

## 06:

-   Script performs error analysis on trained model's predictions.

-   Supports fairness evaluation.

-   The visualizations show the distribution of demographic values
    (e.g., which ages are most/least common) **within each error
    group**, allowing for direct comparison across True Positives, False
    Positives, False Negatives, and True Negatives.

-   Performed on the test set to evaluate models final performance on
    unseen data

------------------------------------------------------------------------

## 08:

-   Performs advanced error specific SHAP analysis to understand which
    features drive diff types of model mistakes

-   It calculates SHAP values for the entire test set - splits them into
    four groups - plots the summary plots.

------------------------------------------------------------------------

## 09:

------------------------------------------------------------------------

## 12:

-   Brier score:

    -   tells us how well calibrated the predictions are - measures
        accuracy of the probability estimates themselves

    -   
