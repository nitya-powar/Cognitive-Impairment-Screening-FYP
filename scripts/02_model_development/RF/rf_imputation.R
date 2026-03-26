# Data imputation using missRanger package
library(missRanger)

imputation_models <- missRanger(
  train_x,
#  train_x_resampled,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  keep_forests = TRUE  
)

train_x_imp <- imputation_models$data  
fits <- imputation_models$forests   

test_x_imp <- missRanger(
  test_x,
  pmm.k = 3,
  seed = 123,
  verbose = 1,
  forests = fits  
)
