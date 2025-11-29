
library(tidyverse); 
library(janitor); 
library(ggplot2);
library(haven);
library(dplyr)

demo <- read_xpt('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/raw/DEMO_H.xpt')

demographics_selection <- demo %>%
  select(SEQN,
         age_years = RIDAGEYR,
         gender = RIAGENDR,
         race = RIDRETH3,
         education_level = DMDEDUC2,
         annual_income = INDHHIN2,
         marital_status = DMDMARTL)

clean_demographics <- demographics_selection %>%
  drop_na(age_years, gender, race, education_level)

# plot these later

cog <- read_xpt('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/raw/CFQ_H.xpt')
cog_core <- cog %>%
  select(
    SEQN,
    cerad_trial1  = CFDCST1, # immediate re-call are cerad trails
    cerad_trial2  = CFDCST2,
    cerad_trial3  = CFDCST3,
    cerad_delayed = CFDCSR,
    animal_fluency= CFDAST,
    dsst_score    = CFDDS,
    language      = CFALANG,   
    completion_status   = CFASTAT,  
    aflu_prep     = CFDAPP,    
    dsst_prep     = CFDDPP     
  )


# impairment flag using literature-based cut-offs
cog_impaired <- cog_core %>%
  filter(!is.na(dsst_score), !is.na(animal_fluency),
         !is.na(cerad_trial1), !is.na(cerad_trial2),
         !is.na(cerad_trial3), !is.na(cerad_delayed)) %>%
  mutate(
    cerad_total = cerad_trial1 + cerad_trial2 + cerad_trial3,
    impaired_dsst  = as.integer(dsst_score < 34),
    impaired_aflu  = as.integer(animal_fluency < 14),
    impaired_cerad = as.integer(cerad_delayed < 5 | cerad_total < 17),
    cog_impair     = as.integer(impaired_dsst + impaired_aflu + impaired_cerad >= 1)
  )

# add code for bias checks later

lab_files <- list.files('/Users/nityapowar/Desktop/MCI FYP/MCI-FYP/data/raw/LAB_DATA', pattern="\\.xpt$", full.names=TRUE)
labs <- Reduce(function(x,y) full_join(x,y, by="SEQN"), lapply(lab_files, read_xpt)) %>%
  distinct(SEQN, .keep_all = TRUE)

final_df <- clean_demographics %>%
  inner_join(
    cog_impaired %>%
      select(SEQN, cog_impair, impaired_dsst, impaired_aflu, impaired_cerad, dsst_score, animal_fluency, cerad_delayed),
    by = "SEQN"
  ) %>%
  inner_join(labs, by = "SEQN")

write_rds(final_df, "data/processed/final_df.rds")
write_csv(final_df, "data/processed/final_df.csv")

# ----------------------------------------
# Lab subsets
# ----------------------------------------

# 1) METABOLIC LABS (HbA1c, Glucose, Insulin Resistance)
metabolic_cols <- c(
  "SEQN",
  names(labs)[grepl("GHB|HbA1C|GLU|INS", names(labs), ignore.case = TRUE)]
)

metabolic_df <- final_df %>%
  select(any_of(c("SEQN", "cog_impair", metabolic_cols))) %>%
  drop_na(SEQN)

write_csv(metabolic_df, "data/processed/metabolic_labs.csv")


# 2) LIPID LABS (cholesterol, HDL, LDL, triglycerides)
lipid_cols <- c(
  names(labs)[grepl("TCHOL|HDL|TRIG|LDL", names(labs), ignore.case = TRUE)]
)

lipid_df <- final_df %>%
  select(any_of(c("SEQN", "cog_impair", lipid_cols))) %>%
  drop_na(SEQN)

write_csv(lipid_df, "data/processed/lipid_labs.csv")


# 3) CBC LABS (Complete Blood Count)
cbc_cols <- names(labs)[grepl("CBC|WBC|RBC|HGB|HCT|PLT|MCV|MCH", names(labs), ignore.case = TRUE)]

cbc_df <- final_df %>%
  select(any_of(c("SEQN", "cog_impair", cbc_cols))) %>%
  drop_na(SEQN)

write_csv(cbc_df, "data/processed/cbc_labs.csv")


# 4) VITAMINS LABS (Folate, B12, Vitamin D)
vitamin_cols <- names(labs)[grepl("FOLATE|B12|VITD|VID", names(labs), ignore.case = TRUE)]

vitamins_df <- final_df %>%
  select(any_of(c("SEQN", "cog_impair", vitamin_cols))) %>%
  drop_na(SEQN)

write_csv(vitamins_df, "data/processed/vitamin_labs.csv")


# 5) KIDNEY + LIVER LABS (Creatinine, Albumin, etc.)
kidneyliver_cols <- names(labs)[grepl("ALB|CREAT|CR|AST|ALT|UREA", names(labs), ignore.case = TRUE)]

kidneyliver_df <- final_df %>%
  select(any_of(c("SEQN", "cog_impair", kidneyliver_cols))) %>%
  drop_na(SEQN)

write_csv(kidneyliver_df, "data/processed/kidneyliver_labs.csv")
