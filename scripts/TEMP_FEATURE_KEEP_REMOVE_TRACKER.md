## 1. SSSNFL_H.xpt ----> has 68% missing data so was completely removed

Kept:
- `SSSNFL` - Serum neurofilament light chain (pg/ml) - NfL, marker of neuro-axonal injury -------------------------------

Removed:
- `WTSSNH2Y` - SSSNFL_H 2 year weights
- `SSNFLH` - Serum neurofilament above detect limit
- `SSNFLL` - Serum neurofilament below detect limit

## 2. GHB_H.xpt

Kept:
- `LBXGH` - Glycohemoglobin (%) - HbA1c

## 3. MMA_H.xpt

Kept:
- `LBXMMASI` - Methylmalonic Acid (nmol/L) - marker related to vitamin B12 deficiency

Removed:
- `LBDMMALC` - Methylmalonic Acid comment code

## 4. VITB12_H.xpt

Kept:
- `LBDB12SI` - Vitamin B12 (pmol/L) - vitamin B12 status

Removed:
- `LBDB12` - Vitamin B12 (pg/mL)

## 5. GLU_H.xpt ----> has 52% missing data

Kept:
- `LBDGLUSI` - Fasting Glucose (mmol/L) - blood sugar level 

Removed:
- `LBXGLU` - Fasting Glucose (mg/dL)
- `WTSAF2YR` - Fasting Subsample 2 Year MEC Weight
- `PHAFSTHR` - Total length of food fast, hours
- `PHAFSTMN` - Total length of food fast, minutes

## 6. INS_H.xpt ----> has 52% missing data

Kept:
- `LBDINSI` - Insulin (pmol/L) - fasting insulin level

Removed:
- `LBXIN` - Insulin (uU/mL)
- `WTSAF2YR` - Fasting Subsample MEC Weight
- `PHAFSTHR` - Total length of food fast, hours
- `PHAFSTMN` - Total length of food fast, minutes

## 7. TRIGLY_H.xpt

Kept:
- `LBDTRSI` - Triglyceride (mmol/L) - blood triglyceride level
- `LBDLDLSI` - LDL-cholesterol (mmol/L) - LDL cholesterol level

Removed:
- `LBXTR` - Triglyceride (mg/dL)
- `LBDLDL` - LDL-cholesterol (mg/dL)
- `WTSAF2YR` - Fasting Subsample 2 Year MEC Weight

## 8. HDL_H.xpt

Kept:
- `LBDHDDSI` - Direct HDL-Cholesterol (mmol/L) - HDL cholesterol level

Removed:
- `LBDHDD` - Direct HDL-Cholesterol (mg/dL)

## 9. TCHOL_H.xpt

Kept:
- `LBDTCSI` - Total Cholesterol (mmol/L) - total blood cholesterol level

Removed:
- `LBXTC` - Total Cholesterol (mg/dL)

## 10. CUSEZN_H.xpt ----> has 68% missing data so was completely removed

Kept:
- `LBDSCUSI` - Serum Copper (umol/L) - copper status  -------------------------------
- `LBDSSESI` - Serum Selenium (umol/L) - selenium status -------------------------------
- `LBDSZNSI` - Serum Zinc (umol/L) - zinc status -------------------------------

Removed:
- `LBXSCU` - Serum Copper (ug/dL)
- `LBXSSE` - Serum Selenium (ug/L)
- `LBXSZN` - Serum Zinc (ug/dL)
- `WTSA2YR` - Subsample A weights
- `URXUCR` - Urinary creatinine (mg/dL)


## 11. FOLATE_H.xpt

Kept:
- `LBDRFOSI` - RBC folate (nmol/L) - folate status

Removed:
- `LBDRFO` - RBC folate (ng/mL)

## 12. ALB_CR_H.xpt

Kept:
- `URDACT` - Albumin creatinine ratio (mg/g) - urine albumin-to-creatinine ratio, kidney/vascular marker

Removed:
- `URXUMA` - Albumin, urine (ug/mL)
- `URXUMS` - Albumin, urine (mg/L)
- `URXUCR` - Creatinine, urine (mg/dL)
- `URXCRS` - Creatinine, urine (umol/L)


## 13. VID_H.xpt

Kept:
- `LBXVIDMS` - 25OHD2+25OHD3 (nmol/L) - total vitamin D
- `LBXVE3MS` - epi-25OHD3 (nmol/L) - vitamin D3 epimer

Removed:
- `LBXVD2MS` - 25OHD2 (nmol/L)
- `LBXVD3MS` - 25OHD3 (nmol/L)
- `LBDVIDLC` - 25OHD2+25OHD3 comment code
- `LBDVD2LC` - 25OHD2 comment code
- `LBDVD3LC` - 25OHD3 comment code
- `LBDVE3LC` - epi-25OHD3 comment code

## 14. PBCD_H.xpt --> all vars have 51% missing data

Kept:
- `LBDBPBSI` - Blood lead (umol/L) - lead exposure 
- `LBDBCDSI` - Blood cadmium (umol/L) - cadmium exposure
- `LBDTHGSI` - Blood mercury, total (nmol/L) - mercury exposure
- `LBDBSESI` - Blood selenium (umol/L) - selenium status
- `LBDBMNSI` - Blood manganese (umol/L) - manganese status

Removed:
- `LBXBPB` - Blood lead (ug/dL)
- `LBXBCD` - Blood cadmium (ug/L)
- `LBXTHG` - Blood mercury, total (ug/L)
- `LBXBSE` - Blood selenium (ug/L)
- `LBXBMN` - Blood manganese (ug/L)
- `LBDPBBLC` - Blood lead comment code
- `LBDBCDLC` - Blood cadmium comment code
- `LBDTHGLC` - Blood mercury, total comment code
- `LBDBSELC` - Blood selenium comment code
- `LBDBMNLC` - Blood manganese comment code
- `WTSH2YR` - Blood metal weights

## 15. CBC_H.xpt

Kept:
- `LBXWBCSI` - White blood cell count (1000 cells/uL) - inflammation / immune marker
- `LBXLYPCT` - Lymphocyte percent (%) - white cell differential
- `LBXMOPCT` - Monocyte percent (%) - white cell differential
- `LBXNEPCT` - Segmented neutrophils percent (%) - white cell differential
- `LBXEOPCT` - Eosinophils percent (%) - white cell differential
- `LBXBAPCT` - Basophils percent (%) - white cell differential
- `LBDLYMNO` - Lymphocyte number (1000 cells/uL) - white cell count subtype
- `LBDMONO` - Monocyte number (1000 cells/uL) - white cell count subtype
- `LBDNENO` - Segmented neutrophils number (1000 cells/uL) - white cell count subtype
- `LBDEONO` - Eosinophils number (1000 cells/uL) - white cell count subtype
- `LBDBANO` - Basophils number (1000 cells/uL) - white cell count subtype
- `LBXRBCSI` - Red blood cell count (million cells/uL) - red blood cell count
- `LBXHGB` - Hemoglobin (g/dL) - oxygen-carrying marker
- `LBXHCT` - Hematocrit (%) - red blood cell volume fraction
- `LBXMCVSI` - Mean cell volume (fL) - red blood cell size
- `LBXMCHSI` - Mean cell hemoglobin (pg) - hemoglobin per red cell
- `LBXMC` - MCHC (g/dL) - mean cell hemoglobin concentration
- `LBXRDW` - Red cell distribution width (%) - red blood cell size variability
- `LBXPLTSI` - Platelet count (1000 cells/uL) - platelet count
- `LBXMPSI` - Mean platelet volume (fL) - platelet size

## 16. BIOPRO_H.xpt

Kept:
- `LBDSALSI` - Albumin (g/L) - serum albumin / nutritional and liver-kidney marker
- `LBXSAPSI` - Alkaline phosphatase (IU/L) - liver/bone enzyme
- `LBXSASSI` - Aspartate aminotransferase AST (U/L) - liver enzyme
- `LBXSATSI` - Alanine aminotransferase ALT (U/L) - liver enzyme
- `LBDSBUSI` - Blood urea nitrogen (mmol/L) - kidney function marker
- `LBXSC3SI` - Bicarbonate (mmol/L) - acid-base / metabolic marker
- `LBDSCASI` - Total calcium (mmol/L) - calcium status
- `LBDSCRSI` - Creatinine (umol/L) - kidney function marker
- `LBDSGBSI` - Globulin (g/L) - protein / inflammation-related marker
- `LBXSOSSI` - Osmolality (mmol/Kg) - hydration / metabolic balance marker
- `LBDSPHSI` - Phosphorus (mmol/L) - phosphorus status
- `LBDSTBSI` - Total bilirubin (umol/L) - bilirubin / liver marker
- `LBDSTPSI` - Total protein (g/L) - total serum protein
- `LBDSUASI` - Uric acid (umol/L) - uric acid level
- `LBXSGTSI` - Gamma glutamyl transferase (U/L) - liver enzyme
- `LBDSIRSI` - Iron, refrigerated serum (umol/L) - iron status

Removed:
- `LBXSAL` - Albumin (g/dL)
- `LBXSBU` - Blood urea nitrogen (mg/dL)
- `LBXSCA` - Total calcium (mg/dL)
- `LBXSCH` - Cholesterol (mg/dL)
- `LBDSCHSI` - Cholesterol (mmol/L)
- `LBXSCR` - Creatinine (mg/dL)
- `LBXSGB` - Globulin (g/dL)
- `LBXSGL` - Glucose, refrigerated serum (mg/dL)
- `LBDSGLSI` - Glucose, refrigerated serum (mmol/L)
- `LBXSPH` - Phosphorus (mg/dL)
- `LBXSTB` - Total bilirubin (mg/dL)
- `LBXSTP` - Total protein (g/dL)
- `LBXSTR` - Triglycerides, refrigerated (mg/dL)
- `LBDSTRSI` - Triglycerides, refrigerated (mmol/L)
- `LBXSUA` - Uric acid (mg/dL)
- `LBXSIR` - Iron, refrigerated serum (ug/dL)
- `LBXSCK` - Creatine phosphokinase CPK (IU/L)
- `LBXSCLSI` - Chloride (mmol/L)
- `LBXSKSI` - Potassium (mmol/L)
- `LBXSLDSI` - Lactate dehydrogenase (U/L)
- `LBXSNASI` - Sodium (mmol/L)


