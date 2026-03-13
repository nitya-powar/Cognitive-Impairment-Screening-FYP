library(tidyverse); 
library(janitor); 
library(ggplot2);
library(haven);
library(dplyr);
library(dlookr)

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
  filter(race != 7)  # Remove "Other race - including multi racial" - too few samples

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

# 3. LOAD & MERGE ALL LAB DATA
lab_files <- list.files('data/raw/LAB_DATA', pattern="\\.xpt$", full.names=TRUE)

labs <- Reduce(function(x,y) full_join(x,y, by="SEQN"), lapply(lab_files, read_xpt)) %>%
  distinct(SEQN, .keep_all = TRUE)

# 4. CREATE FINAL MERGED DATASET & EXPORT
final_df <- clean_demographics %>%
  inner_join(cog_impaired %>%
               select(SEQN, cog_impair), by = "SEQN") %>%
  inner_join(labs, by = "SEQN")

png('outputs/figures/missing_data_pareto.png', 
    width = 800, height = 600)
plot_na_pareto(final_df, only_na = TRUE)
dev.off()

write_rds(final_df, 'data/processed/dataframe_labs_only/final_df.rds')
write_csv(final_df, "data/processed/dataframe_labs_only/final_df.csv")

# 5. CREATE SPECIALISED LAB SUBSETS FOR TESTING
base_df <- clean_demographics %>%
  inner_join(cog_impaired %>%
               select(SEQN, cog_impair), by = "SEQN")

# Function to load specific lab files and merge with base
create_lab_subset <- function(file_names, output_name) {
  df <- file_names %>%
    map(~ read_xpt(file.path('data/raw/LAB_DATA', .x))) %>%
    reduce(~ left_join(.x, .y, by = "SEQN"), .init = base_df) %>%
    select(SEQN, cog_impair, everything())
  
  write_csv(df, paste0("data/processed/lab_groups/", output_name, ".csv"))
  return(df)
}

# Create each subset
metabolic_files <- c("GHB_H(HbA1C).xpt", "GLU_H(fastingGlucose).xpt", "INS_H(insulinResistance).xpt")
metabolic_df <- create_lab_subset(metabolic_files, "metabolic_labs")

lipid_files <- c("TCHOL_H(totalChol).xpt", "HDL_H(cholHDL).xpt", "TRIGLY_H(chol_LDL_&_triglycerides).xpt")
lipid_df <- create_lab_subset(lipid_files, "lipid_labs")

cbc_files <- c("CBC_H(CompleteBloodCount).xpt")
cbc_df <- create_lab_subset(cbc_files, "cbc_labs")

vitamin_files <- c("FOLATE_H.xpt", "VITB12_H.xpt", "VID_H(VitaminD).xpt", "MMA_H.xpt")
vitamin_df <- create_lab_subset(vitamin_files, "vitamin_labs")

kidneyliver_files <- c("ALB_CR_H(kidney&LiverFunc).xpt", "BIOPRO_H(biochemProfile).xpt")
kidneyliver_df <- create_lab_subset(kidneyliver_files, "kidneyliver_labs")
