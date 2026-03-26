library(tidyverse)
library(haven)
library(dlookr)

base_df <- read_rds("data/processed/dataframe/base_df.rds")

# duplicate units, survey weights, comment codes, variables intentionally excluded - refer FEATURE_KEEP_REMOVE_TRACKER.md
drop_cols <- c( 
  # not to drop SEQN here
  "WTSSNH2Y", "SSNFLH", "SSNFLL", "LBDMMALC", "LBDB12",
  "LBXGLU", "WTSAF2YR", "WTSAF2YR.x", "WTSAF2YR.y",
  "PHAFSTHR", "PHAFSTHR.x", "PHAFSTHR.y",
  "PHAFSTMN", "PHAFSTMN.x", "PHAFSTMN.y", "LBXIN",
  "LBXTR", "LBDLDL", "LBDHDD", "LBXTC", "LBXSCU", "LBXSSE",
  "LBXSZN", "WTSA2YR", "URXUCR", "URXUCR.x", "URXUCR.y", "LBDRFO", "URXUMA", "URXUMS",
  "URXCRS", "LBXVD2MS", "LBXVD3MS", "LBDVIDLC", "LBDVD2LC",
  "LBDVD3LC", "LBDVE3LC", "LBXBPB", "LBXBCD", "LBXTHG", "LBXBSE",
  "LBXBMN", "LBDBPBLC", "LBDBCDLC", "LBDTHGLC", "LBDBSELC",
  "LBDBMNLC", "WTSH2YR", "LBXSAL", "LBXSBU", "LBXSCA", "LBXSCH",
  "LBDSCHSI", "LBXSCR", "LBXSGB", "LBXSGL", "LBDSGLSI", "LBXSPH",
  "LBXSTB", "LBXSTP", "LBXSTR", "LBDSTRSI", "LBXSUA", "LBXSIR",
  "LBXSCK", "LBXSCLSI", "LBXSKSI", "LBXSLDSI", "LBXSNASI"
)


# LOAD & MERGE ALL LAB DATA
lab_files <- list.files("data/raw/LAB_DATA", pattern = "\\.xpt$", full.names = TRUE)

labs <- Reduce(function(x, y) full_join(x, y, by = "SEQN"), lapply(lab_files, read_xpt)) %>%
  distinct(SEQN, .keep_all = TRUE)

# CREATE FINAL MERGED DATASET & EXPORT
base_df_with_labs <- base_df %>%
  inner_join(labs, by = "SEQN") %>%
  select(-any_of(drop_cols))

# GENERATE PARETO ANALYSIS
png("outputs/figures/missing_data_pareto.png",
    width = 800, height = 600)
plot_na_pareto(base_df_with_labs, only_na = TRUE)
dev.off()

write_rds(base_df_with_labs, "data/processed/dataframe/base_df_with_labs.rds")
write_csv(base_df_with_labs, "data/processed/dataframe/base_df_with_labs.csv")
