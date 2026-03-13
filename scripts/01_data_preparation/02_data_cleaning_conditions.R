library(tidyverse)
library(haven)
library(janitor)
library(dplyr)

# 0) Load existing final_df (demo + cog + labs)
final_df <- read_csv("data/processed/dataframe_labs_only/final_df.csv")

# 1) EXAMINATION DATA

# 1a) Blood pressure: mean SBP / DBP
bpx <- read_xpt("data/raw/EXAM_DATA/BPX_H.xpt")%>%
  select(
    SEQN,
    sbp1 = BPXSY1, sbp2 = BPXSY2, sbp3 = BPXSY3, sbp4 = BPXSY4,
    dbp1 = BPXDI1, dbp2 = BPXDI2, dbp3 = BPXDI3, dbp4 = BPXDI4
  ) %>%
  mutate(
    mean_sbp = rowMeans(select(., starts_with("sbp")), na.rm = TRUE),
    mean_dbp = rowMeans(select(., starts_with("dbp")), na.rm = TRUE),
    mean_sbp = ifelse(is.nan(mean_sbp), NA, mean_sbp),
    mean_dbp = ifelse(is.nan(mean_dbp), NA, mean_dbp)
  ) %>%
  select(SEQN, mean_sbp, mean_dbp)

# 1b) Body measures
bmx <- read_xpt("data/raw/EXAM_DATA/BMX_H.xpt") %>%
  select(
    SEQN,
    bmi   = BMXBMI,
    waist = BMXWAIST,
    height = BMXHT,
    weight = BMXWT
  )

# 1c) Grip strength: max dominant-hand grip
mgx_raw <- read_xpt("data/raw/EXAM_DATA/MGX_H.xpt")
grip_strength <- mgx_raw %>%
  select(SEQN, grip_strength = MGDCGSZ)

# 2) QUESTIONNAIRE DATA

#  Depression: PHQ-9 total + flag
dpq <- read_xpt("data/raw/QUESTIONNAIRE_DATA/DPQ_H.xpt") %>%
  transmute(
    SEQN,
    phq9_sum = rowSums(across(DPQ010:DPQ090), na.rm = TRUE),
    phq9_sum = ifelse(if_all(DPQ010:DPQ090, is.na), NA, phq9_sum),
    phq9_depressed = ifelse(is.na(phq9_sum), NA, as.integer(phq9_sum >= 10))
  )

# 3) JOIN everything onto final_df_conditions
final_df_conditions <- final_df %>%
  left_join(bpx,  by = "SEQN") %>%
  left_join(bmx,  by = "SEQN") %>%
  left_join(grip_strength, by = "SEQN") %>%
  left_join(dpq,  by = "SEQN")

# 4) Save
write_rds(final_df_conditions, "data/processed/dataframe_labs_with_conditions/final_df_conditions.rds")
write_csv(final_df_conditions, "data/processed/dataframe_labs_with_conditions/final_df_conditions.csv")
