# Feature Keep/Remove Tracker

This tracker shows, for each `LAB_DATA` file, which variables were kept and which were removed.

| No. | File           | Notes                                          |
|-----|----------------|------------------------------------------------|
| 1   | `SSSNFL_H.xpt` | has 68% missing data so was completely removed |
| 2   | `GHB_H.xpt`    |                                                |
| 3   | `MMA_H.xpt`    |                                                |
| 4   | `VITB12_H.xpt` |                                                |
| 5   | `GLU_H.xpt`    | has 52% missing data                           |
| 6   | `INS_H.xpt`    | has 52% missing data                           |
| 7   | `TRIGLY_H.xpt` |                                                |
| 8   | `HDL_H.xpt`    |                                                |
| 9   | `TCHOL_H.xpt`  |                                                |
| 10  | `CUSEZN_H.xpt` | has 68% missing data so was completely removed |
| 11  | `FOLATE_H.xpt` |                                                |
| 12  | `ALB_CR_H.xpt` |                                                |
| 13  | `VID_H.xpt`    |                                                |
| 14  | `PBCD_H.xpt`   | all vars have 51% missing data                 |
| 15  | `CBC_H.xpt`    |                                                |
| 16  | `BIOPRO_H.xpt` |                                                |

## 1. `SSSNFL_H.xpt`

| Status | Variables |
|----|----|
| Kept | `SSSNFL` - Serum neurofilament light chain (pg/ml) |
| Removed | `WTSSNH2Y` - SSSNFL_H 2 year weights; `SSNFLH` - Serum neurofilament above detect limit; `SSNFLL` - Serum neurofilament below detect limit |

## 2. `GHB_H.xpt`

| Status  | Variables                     |
|---------|-------------------------------|
| Kept    | `LBXGH` - Glycohemoglobin (%) |
| Removed | None                          |

## 3. `MMA_H.xpt`

| Status  | Variables                                    |
|---------|----------------------------------------------|
| Kept    | `LBXMMASI` - Methylmalonic Acid (nmol/L)     |
| Removed | `LBDMMALC` - Methylmalonic Acid comment code |

## 4. `VITB12_H.xpt`

| Status  | Variables                         |
|---------|-----------------------------------|
| Kept    | `LBDB12SI` - Vitamin B12 (pmol/L) |
| Removed | `LBDB12` - Vitamin B12 (pg/mL)    |

## 5. `GLU_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDGLUSI` - Fasting Glucose (mmol/L) |
| Removed | `LBXGLU` - Fasting Glucose (mg/dL); `WTSAF2YR` - Fasting Subsample 2 Year MEC Weight; `PHAFSTHR` - Total length of food fast, hours; `PHAFSTMN` - Total length of food fast, minutes |

## 6. `INS_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDINSI` - Insulin (pmol/L) |
| Removed | `LBXIN` - Insulin (uU/mL); `WTSAF2YR` - Fasting Subsample MEC Weight; `PHAFSTHR` - Total length of food fast, hours; `PHAFSTMN` - Total length of food fast, minutes |

## 7. `TRIGLY_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDTRSI` - Triglyceride (mmol/L); `LBDLDLSI` - LDL-cholesterol (mmol/L) |
| Removed | `LBXTR` - Triglyceride (mg/dL); `LBDLDL` - LDL-cholesterol (mg/dL); `WTSAF2YR` - Fasting Subsample 2 Year MEC Weight |

## 8. `HDL_H.xpt`

| Status  | Variables                                    |
|---------|----------------------------------------------|
| Kept    | `LBDHDDSI` - Direct HDL-Cholesterol (mmol/L) |
| Removed | `LBDHDD` - Direct HDL-Cholesterol (mg/dL)    |

## 9. `TCHOL_H.xpt`

| Status  | Variables                              |
|---------|----------------------------------------|
| Kept    | `LBDTCSI` - Total Cholesterol (mmol/L) |
| Removed | `LBXTC` - Total Cholesterol (mg/dL)    |

## 10. `CUSEZN_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDSCUSI` - Serum Copper (umol/L); `LBDSSESI` - Serum Selenium (umol/L); `LBDSZNSI` - Serum Zinc (umol/L) |
| Removed | `LBXSCU` - Serum Copper (ug/dL); `LBXSSE` - Serum Selenium (ug/L); `LBXSZN` - Serum Zinc (ug/dL); `WTSA2YR` - Subsample A weights; `URXUCR` - Urinary creatinine (mg/dL) |

## 11. `FOLATE_H.xpt`

| Status  | Variables                        |
|---------|----------------------------------|
| Kept    | `LBDRFOSI` - RBC folate (nmol/L) |
| Removed | `LBDRFO` - RBC folate (ng/mL)    |

## 12. `ALB_CR_H.xpt`

| Status | Variables |
|----|----|
| Kept | `URDACT` - Albumin creatinine ratio (mg/g) |
| Removed | `URXUMA` - Albumin, urine (ug/mL); `URXUMS` - Albumin, urine (mg/L); `URXUCR` - Creatinine, urine (mg/dL); `URXCRS` - Creatinine, urine (umol/L) |

## 13. `VID_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBXVIDMS` - 25OHD2+25OHD3 (nmol/L); `LBXVE3MS` - epi-25OHD3 (nmol/L) |
| Removed | `LBXVD2MS` - 25OHD2 (nmol/L); `LBXVD3MS` - 25OHD3 (nmol/L); `LBDVIDLC` - 25OHD2+25OHD3 comment code; `LBDVD2LC` - 25OHD2 comment code; `LBDVD3LC` - 25OHD3 comment code; `LBDVE3LC` - epi-25OHD3 comment code |

## 14. `PBCD_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDBPBSI` - Blood lead (umol/L); `LBDBCDSI` - Blood cadmium (umol/L); `LBDTHGSI` - Blood mercury, total (nmol/L); `LBDBSESI` - Blood selenium (umol/L); `LBDBMNSI` - Blood manganese (umol/L) |
| Removed | `LBXBPB` - Blood lead (ug/dL); `LBXBCD` - Blood cadmium (ug/L); `LBXTHG` - Blood mercury, total (ug/L); `LBXBSE` - Blood selenium (ug/L); `LBXBMN` - Blood manganese (ug/L); `LBDPBBLC` - Blood lead comment code; `LBDBCDLC` - Blood cadmium comment code; `LBDTHGLC` - Blood mercury, total comment code; `LBDBSELC` - Blood selenium comment code; `LBDBMNLC` - Blood manganese comment code; `WTSH2YR` - Blood metal weights |

## 15. `CBC_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBXWBCSI` - White blood cell count (1000 cells/uL); `LBXLYPCT` - Lymphocyte percent (%); `LBXMOPCT` - Monocyte percent (%); `LBXNEPCT` - Segmented neutrophils percent (%); `LBXEOPCT` - Eosinophils percent (%); `LBXBAPCT` - Basophils percent (%); `LBDLYMNO` - Lymphocyte number (1000 cells/uL); `LBDMONO` - Monocyte number (1000 cells/uL); `LBDNENO` - Segmented neutrophils number (1000 cells/uL); `LBDEONO` - Eosinophils number (1000 cells/uL); `LBDBANO` - Basophils number (1000 cells/uL); `LBXRBCSI` - Red blood cell count (million cells/uL); `LBXHGB` - Hemoglobin (g/dL); `LBXHCT` - Hematocrit (%); `LBXMCVSI` - Mean cell volume (fL); `LBXMCHSI` - Mean cell hemoglobin (pg); `LBXMC` - MCHC (g/dL); `LBXRDW` - Red cell distribution width (%); `LBXPLTSI` - Platelet count (1000 cells/uL); `LBXMPSI` - Mean platelet volume (fL) |
| Removed | None |

## 16. `BIOPRO_H.xpt`

| Status | Variables |
|----|----|
| Kept | `LBDSALSI` - Albumin (g/L); `LBXSAPSI` - Alkaline phosphatase (IU/L); `LBXSASSI` - Aspartate aminotransferase AST (U/L); `LBXSATSI` - Alanine aminotransferase ALT (U/L); `LBDSBUSI` - Blood urea nitrogen (mmol/L); `LBXSC3SI` - Bicarbonate (mmol/L); `LBDSCASI` - Total calcium (mmol/L); `LBDSCRSI` - Creatinine (umol/L); `LBDSGBSI` - Globulin (g/L); `LBXSOSSI` - Osmolality (mmol/Kg); `LBDSPHSI` - Phosphorus (mmol/L); `LBDSTBSI` - Total bilirubin (umol/L); `LBDSTPSI` - Total protein (g/L); `LBDSUASI` - Uric acid (umol/L); `LBXSGTSI` - Gamma glutamyl transferase (U/L); `LBDSIRSI` - Iron, refrigerated serum (umol/L) |
| Removed | `LBXSAL` - Albumin (g/dL); `LBXSBU` - Blood urea nitrogen (mg/dL); `LBXSCA` - Total calcium (mg/dL); `LBXSCH` - Cholesterol (mg/dL); `LBDSCHSI` - Cholesterol (mmol/L); `LBXSCR` - Creatinine (mg/dL); `LBXSGB` - Globulin (g/dL); `LBXSGL` - Glucose, refrigerated serum (mg/dL); `LBDSGLSI` - Glucose, refrigerated serum (mmol/L); `LBXSPH` - Phosphorus (mg/dL); `LBXSTB` - Total bilirubin (mg/dL); `LBXSTP` - Total protein (g/dL); `LBXSTR` - Triglycerides, refrigerated (mg/dL); `LBDSTRSI` - Triglycerides, refrigerated (mmol/L); `LBXSUA` - Uric acid (mg/dL); `LBXSIR` - Iron, refrigerated serum (ug/dL); `LBXSCK` - Creatine phosphokinase CPK (IU/L); `LBXSCLSI` - Chloride (mmol/L); `LBXSKSI` - Potassium (mmol/L); `LBXSLDSI` - Lactate dehydrogenase (U/L); `LBXSNASI` - Sodium (mmol/L) |
