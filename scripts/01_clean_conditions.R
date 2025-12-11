# -------------------------------------------------------------------------------------------------------
# Add exam + questionnaire vars to final_df --> currently only using some vars from the examination data
# -------------------------------------------------------------------------------------------------------

library(tidyverse)
library(haven)
library(janitor)
library(dplyr)

# 0) Load existing final_df (demo + cog + labs)
final_df <- read_csv("data/processed/final_df.csv")

# ----------------------------------------
# 1) EXAMINATION DATA
# ----------------------------------------

# 1a) Blood pressure: mean SBP / DBP
bpx <- read_xpt("data/raw/EXAM_DATA/BPX_H.XPT") %>%
  select(
    SEQN,
    sbp1 = BPXSY1, sbp2 = BPXSY2, sbp3 = BPXSY3, sbp4 = BPXSY4,
    dbp1 = BPXDI1, dbp2 = BPXDI2, dbp3 = BPXDI3, dbp4 = BPXDI4
  ) %>%
  mutate(
    mean_sbp = rowMeans(select(., starts_with("sbp")), na.rm = TRUE),
    mean_dbp = rowMeans(select(., starts_with("dbp")), na.rm = TRUE)
  ) %>%
  select(SEQN, mean_sbp, mean_dbp)

# 1b) Body measures
bmx <- read_xpt("data/raw/EXAM_DATA/BMX_H.XPT") %>%
  select(
    SEQN,
    bmi   = BMXBMI,
    waist = BMXWAIST,
    height = BMXHT,
    weight = BMXWT
  )

# 1c) Grip strength: max dominant-hand grip
mgx_raw <- read_xpt("data/raw/EXAM_DATA/MGX_H.XPT")

grip <- mgx_raw %>%
  select(SEQN, starts_with("MGDCGS")) %>%
  mutate(
    grip_max = apply(select(., -SEQN), 1, function(x) {
      if (all(is.na(x))) NA else max(x, na.rm = TRUE)
    })
  ) %>%
  select(SEQN, grip_max)

# ----------------------------------------
# 2) QUESTIONNAIRE DATA
# ----------------------------------------

# 2a) Depression: PHQ-9 total + flag
dpq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/DPQ_H.XPT") %>%
  select(SEQN, DPQ010:DPQ090) %>%
  mutate(
    phq9_sum  = rowSums(across(DPQ010:DPQ090), na.rm = TRUE),
    phq9_depressed = as.integer(phq9_sum >= 10)
  ) %>%
  select(SEQN, phq9_sum, phq9_depressed)

# 2b) Diabetes diagnosis
diq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/DIQ_H.XPT") %>%
  select(SEQN, DIQ010) %>%
  mutate(
    diabetes_dx = case_when(
      DIQ010 == 1 ~ 1L,
      DIQ010 %in% c(2, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  ) %>%
  select(SEQN, diabetes_dx)

# 2c) Cardiovascular disease (any)
cdq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/CDQ_H.XPT") %>%
  select(
    SEQN,
    chf  = CDQ001,
    chd  = CDQ002,
    mi   = CDQ003,
    stroke = CDQ004
  ) %>%
  mutate(
    cvd_any = as.integer(chf == 1 | chd == 1 | mi == 1 | stroke == 1)
  ) %>%
  select(SEQN, cvd_any)

# 2d) Sleep hours
slq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/SLQ_H.XPT") %>%
  select(SEQN, sleep_hours = SLD010H)

# 2e) Alcohol
alq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/ALQ_H.XPT") %>%
  select(SEQN, drinks_per_week = ALQ130)

# 2f) Smoking
smq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/SMQ_H.XPT") %>%
  select(
    SEQN,
    ever_smoke = SMQ020,
    now_smoke  = SMQ040
  ) %>%
  mutate(
    ever_smoker    = as.integer(ever_smoke == 1),
    current_smoker = as.integer(now_smoke == 1)
  ) %>%
  select(SEQN, ever_smoker, current_smoker)

# ----------------------------------------
# 3) JOIN everything onto final_df
# ----------------------------------------

final_df_conditions <- final_df %>%
  left_join(bpx,  by = "SEQN") %>%
  left_join(bmx,  by = "SEQN") %>%
  left_join(grip, by = "SEQN") %>%
  left_join(dpq,  by = "SEQN") %>%
  left_join(diq,  by = "SEQN") %>%
  left_join(cdq,  by = "SEQN") %>%
  left_join(slq,  by = "SEQN") %>%
  left_join(alq,  by = "SEQN") %>%
  left_join(smq,  by = "SEQN")

# drop weak / noisy predictors
weak_cols <- c(
  "drinks_per_week",
  "current_smoker",
  "ever_smoker",
  "waist",
  "PHAFSTMN.x", "PHAFSTMN.y",
  "PHAFSTHR.x", "PHAFSTHR.y",
  "phq9_depressed",
  "diabetes_dx",
  "cvd_any",
  "sleep_hours"
)

final_df_conditions <- final_df_conditions[, !(names(final_df_conditions) %in% weak_cols)]

# ----------------------------------------
# 4) Save
# ----------------------------------------

write_rds(final_df_conditions, "data/processed/final_df_conditions.rds")
write_csv(final_df_conditions, "data/processed/final_df_conditions.csv")