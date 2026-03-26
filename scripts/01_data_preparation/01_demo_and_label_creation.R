library(tidyverse)
library(haven)
library(dplyr)

# 1. LOAD & CLEAN DEMOGRAPHICS
demo <- read_xpt('data/raw/DEMO_H.xpt')

demographics_selection <- demo %>%
  select(SEQN,
         age_years = RIDAGEYR,          
         gender = RIAGENDR,             
         race = RIDRETH3,              
         education_level = DMDEDUC2,
         marital_status = DMDMARTL)    

clean_demographics <- demographics_selection %>%
  drop_na(age_years, gender, race, education_level, marital_status) %>%
  filter(!education_level %in% c(7, 9)) %>%
  filter(!marital_status %in% c(77, 99)) %>%
  filter(race != 7)  # Remove "Other race - including multi racial"

# 2. LOAD & PROCESS COGNITIVE TESTS (Create Impairment Flags)
cog <- read_xpt('data/raw/CFQ_H.xpt')
cog_core <- cog %>%
  select(
    SEQN,
    cerad_trial1  = CFDCST1, 
    cerad_trial2  = CFDCST2,
    cerad_trial3  = CFDCST3,
    cerad_delayed = CFDCSR,
    animal_fluency= CFDAST,
    dsst_score    = CFDDS,
  )

# impairment flag using literature-based cut-offs
cog_impaired <- cog_core %>%
  filter(!is.na(dsst_score), !is.na(animal_fluency), # keep patient with each one present
         !is.na(cerad_trial1), !is.na(cerad_trial2),
         !is.na(cerad_trial3), !is.na(cerad_delayed)) %>%
  
  mutate(
    cerad_total = cerad_trial1 + cerad_trial2 + cerad_trial3,
    impaired_cerad = as.integer(cerad_delayed < 5 | cerad_total < 17),
    impaired_dsst  = as.integer(dsst_score < 34),
    impaired_aflu  = as.integer(animal_fluency < 14),
    
    cog_impair     = as.integer(impaired_dsst + impaired_aflu + impaired_cerad >= 1)
  )

# 3. CREATE BASE DATAFRAME (DEMOGRAPHICS + COGNITIVE LABEL)
base_df <- clean_demographics %>%
  inner_join(
    cog_impaired %>%
      select(SEQN, cog_impair),
    by = "SEQN"
  )

write_rds(base_df, "data/processed/dataframe/base_df.rds")
write_csv(base_df, "data/processed/dataframe/base_df.csv")
