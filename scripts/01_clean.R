
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
