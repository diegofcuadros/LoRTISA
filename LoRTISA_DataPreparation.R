# LoRTISA Study: Comprehensive Data Preparation
# Community-Acquired Pneumonia Analysis in Uganda
# Author: Analysis Team
# Date: July 2025

# ==============================================================================
# PHASE 1: ENVIRONMENT SETUP AND DATA LOADING
# ==============================================================================

# Load required libraries
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(VIM)          # For missing data visualization
library(mice)         # Multiple imputation
library(Hmisc)        # Statistical functions
library(tableone)     # Table 1 generation
library(knitr)
library(lubridate)    # Date handling
library(janitor)      # Data cleaning

# Set options
options(scipen = 999)  # Disable scientific notation
set.seed(123)         # For reproducibility

# ==============================================================================
# PHASE 2: DATA LOADING AND INITIAL EXAMINATION
# ==============================================================================

cat("=== LoRTISA DATA PREPARATION ===\n")
cat("Starting comprehensive data preparation...\n\n")

# Load the complete dataset
cat("Loading dataset...\n")
cap_data_raw <- read_csv("C:/Users/cuadrodo/Documents/Claude_Code/CAP_072125/CAP_dataset.csv")

# Basic dataset information
cat("DATASET OVERVIEW:\n")
cat("- Total observations:", nrow(cap_data_raw), "\n")
cat("- Total variables:", ncol(cap_data_raw), "\n")
cat("- Date range:", min(as.Date(cap_data_raw$dos, format="%m/%d/%Y"), na.rm=TRUE), 
    "to", max(as.Date(cap_data_raw$dos, format="%m/%d/%Y"), na.rm=TRUE), "\n\n")

# Examine data structure
cat("VARIABLE TYPES:\n")
str(cap_data_raw, list.len = 10)  # Show first 10 variables
cat("\nFirst few observations:\n")
head(cap_data_raw, 3)

# ==============================================================================
# PHASE 3: STUDY POPULATION DEFINITION
# ==============================================================================

cat("\n=== STUDY POPULATION DEFINITION ===\n")

# Examine event types
event_summary <- cap_data_raw %>%
  count(redcap_event_name, sort = TRUE)
cat("Event types in dataset:\n")
print(event_summary)

# Define baseline population
cat("\nDefining baseline study population...\n")
cap_baseline <- cap_data_raw %>%
  filter(redcap_event_name == "baseline_arm_1") %>%
  distinct(patient_id, .keep_all = TRUE)

cat("- Baseline records:", nrow(cap_baseline), "\n")

# Check for duplicate patient IDs at baseline
duplicate_check <- cap_baseline %>%
  count(patient_id, sort = TRUE) %>%
  filter(n > 1)

if(nrow(duplicate_check) > 0) {
  cat("WARNING: Found", nrow(duplicate_check), "duplicate patient IDs at baseline\n")
  print(duplicate_check)
} else {
  cat("✓ No duplicate patient IDs found at baseline\n")
}

# Hospital distribution
hospital_dist <- cap_baseline %>%
  count(hospital, sort = TRUE) %>%
  mutate(percent = round(n/sum(n)*100, 1))

cat("\nHospital distribution:\n")
print(hospital_dist)

# ==============================================================================
# PHASE 4: OUTCOME VARIABLE DEFINITION
# ==============================================================================

cat("\n=== OUTCOME VARIABLES DEFINITION ===\n")

# Extract follow-up data for mortality assessment
followup_data <- cap_data_raw %>%
  filter(patient_id %in% cap_baseline$patient_id) %>%
  select(patient_id, redcap_event_name, follow_up_schedule, 
         patient_discharge_status, death_date, alive_discharge_date,
         possible_followup, no_followup, no_followupdied) %>%
  arrange(patient_id, redcap_event_name)

# Create comprehensive outcome dataset
outcomes <- cap_baseline %>%
  select(patient_id, patient_discharge_status, death_date, alive_discharge_date) %>%
  left_join(
    cap_data_raw %>%
      filter(!is.na(follow_up_schedule) & grepl("Day 30|Month1", follow_up_schedule)) %>%
      distinct(patient_id, .keep_all = TRUE) %>%
      select(patient_id, follow_hosp, possible_followup, no_followup, 
             no_followupdied, date_followup),
    by = "patient_id"
  ) %>%
  mutate(
    # Primary outcome: 30-day mortality
    died_hospital = case_when(
      patient_discharge_status == "Dead" ~ 1,
      patient_discharge_status == "Alive" ~ 0,
      TRUE ~ NA_real_
    ),
    died_30day = case_when(
      died_hospital == 1 ~ 1,  # Died in hospital
      no_followupdied == "Yes" ~ 1,  # Died during follow-up
      possible_followup == "No" & no_followup == "Patient Died" ~ 1,  # Alternative coding
      !is.na(date_followup) ~ 0,  # Alive at follow-up
      patient_discharge_status == "Alive" & is.na(no_followupdied) ~ 0,  # Assume alive if discharged alive and no death reported
      TRUE ~ NA_real_
    ),
    # Secondary outcomes
    rehospitalized = case_when(
      follow_hosp == "Yes" ~ 1,
      follow_hosp == "No" ~ 0,
      TRUE ~ NA_real_
    ),
    # Composite poor outcome
    poor_outcome = case_when(
      died_30day == 1 | rehospitalized == 1 ~ 1,
      died_30day == 0 & rehospitalized == 0 ~ 0,
      TRUE ~ NA_real_
    )
  )

# Outcome summary
cat("OUTCOME VARIABLES:\n")
cat("Hospital mortality:", sum(outcomes$died_hospital, na.rm=TRUE), 
    "/", sum(!is.na(outcomes$died_hospital)), 
    "(", round(mean(outcomes$died_hospital, na.rm=TRUE)*100, 1), "%)\n")

cat("30-day mortality:", sum(outcomes$died_30day, na.rm=TRUE), 
    "/", sum(!is.na(outcomes$died_30day)), 
    "(", round(mean(outcomes$died_30day, na.rm=TRUE)*100, 1), "%)\n")

cat("Rehospitalization:", sum(outcomes$rehospitalized, na.rm=TRUE), 
    "/", sum(!is.na(outcomes$rehospitalized)), 
    "(", round(mean(outcomes$rehospitalized, na.rm=TRUE)*100, 1), "%)\n")

# ==============================================================================
# PHASE 5: MISSING DATA ASSESSMENT
# ==============================================================================

cat("\n=== MISSING DATA ASSESSMENT ===\n")

# Key variables for analysis
key_vars <- c("patient_age", "patient_gender", "patient_temp", "patient_hr", 
              "patient_rr", "patient_sbp", "patient_dbp", "patient_spo", 
              "patient_height", "patient_weight", "patient_cscore", 
              "hiv_result_ipq", "mental_status", "smoked_100", "months12_alcohol", 
              "diag_diabetes", "treated_4tb", "take_antibodies", "hospital")

# Missing data summary for key variables
missing_summary <- cap_baseline %>%
  select(all_of(key_vars)) %>%
  summarise_all(~sum(is.na(.))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing") %>%
  mutate(
    total = nrow(cap_baseline),
    percent_missing = round(missing/total*100, 1)
  ) %>%
  arrange(desc(percent_missing))

cat("Missing data summary for key variables:\n")
print(missing_summary, n = Inf)

# Missing data patterns
cat("\nMissing data patterns visualization:\n")
# Create missing data pattern matrix
missing_pattern <- cap_baseline %>%
  select(all_of(key_vars)) %>%
  md.pattern(rotate.names = TRUE)

# ==============================================================================
# PHASE 6: DERIVED VARIABLES CREATION
# ==============================================================================

cat("\n=== CREATING DERIVED VARIABLES ===\n")

# Merge baseline data with outcomes
analysis_dataset <- cap_baseline %>%
  left_join(outcomes %>% select(patient_id, died_hospital, died_30day, 
                               rehospitalized, poor_outcome), 
           by = "patient_id") %>%
  mutate(
    # Age categories
    age_group = case_when(
      patient_age >= 18 & patient_age <= 34 ~ "18-34",
      patient_age >= 35 & patient_age <= 44 ~ "35-44", 
      patient_age >= 45 & patient_age <= 54 ~ "45-54",
      patient_age >= 55 ~ "55+",
      TRUE ~ "missing"
    ),
    age_65plus = ifelse(patient_age >= 65, 1, 0),
    age_continuous = patient_age,
    
    # BMI calculation and categories
    bmi = patient_weight / (patient_height/100)^2,
    bmi_category = case_when(
      bmi < 16 ~ "severe_underweight",
      bmi >= 16 & bmi < 18.5 ~ "underweight",
      bmi >= 18.5 & bmi < 25 ~ "normal",
      bmi >= 25 & bmi < 30 ~ "overweight",
      bmi >= 30 ~ "obese",
      TRUE ~ "missing"
    ),
    bmi_under18.5 = ifelse(bmi < 18.5, 1, 0),
    bmi_under16 = ifelse(bmi < 16, 1, 0),
    
    # Vital signs abnormalities
    sbp_low = ifelse(patient_sbp < 90, 1, 0),
    dbp_low = ifelse(patient_dbp < 60, 1, 0),
    hr_high = ifelse(patient_hr > 100, 1, 0),
    rr_high = ifelse(patient_rr > 24, 1, 0),
    rr_very_high = ifelse(patient_rr >= 30, 1, 0),
    spo2_low = ifelse(patient_spo < 90, 1, 0),
    temp_low = ifelse(patient_temp < 36, 1, 0),
    temp_high = ifelse(patient_temp >= 38, 1, 0),
    
    # Clinical severity
    clinical_severe = case_when(
      grepl("Severely affected|Completely disabled", patient_cscore) ~ 1,
      grepl("Significantly affected", patient_cscore) ~ 0,
      grepl("Mildly affected|Not affected", patient_cscore) ~ 0,
      TRUE ~ NA_real_
    ),
    
    # HIV status (clean coding)
    hiv_status = case_when(
      hiv_result_ipq == "Positive" ~ "positive",
      hiv_result_ipq == "Negative" ~ "negative",
      TRUE ~ "unknown"
    ),
    hiv_positive = ifelse(hiv_status == "positive", 1, 0),
    
    # Comorbidities
    diabetes = ifelse(diag_diabetes == "Yes", 1, 0),
    tb_history = ifelse(treated_4tb == "Yes", 1, 0),
    prior_antibiotics = ifelse(take_antibodies == "Yes", 1, 0),
    
    # Substance use
    smoking_history = ifelse(smoked_100 == "Yes", 1, 0),
    alcohol_use = case_when(
      months12_alcohol == "Yes" ~ 1,
      months12_alcohol == "No" ~ 0,
      TRUE ~ NA_real_
    ),
    
    # Region grouping
    region_central = ifelse(region == "Central", 1, 0),
    
    # Hospital grouping
    hospital_kirrudu = ifelse(hospital == "Kirrudu", 1, 0),
    hospital_mulago = ifelse(hospital == "Mulago", 1, 0),
    
    # Date variables
    dos_date = as.Date(dos, format = "%m/%d/%Y"),
    enrollment_year = year(dos_date),
    
    # Composite risk factors
    vital_signs_abnormal = pmax(sbp_low, rr_high, spo2_low, na.rm = TRUE),
    comorbidity_count = diabetes + tb_history + hiv_positive
  )

cat("Created derived variables:\n")
cat("- Age categories and continuous\n")
cat("- BMI categories and thresholds\n") 
cat("- Vital sign abnormalities\n")
cat("- Clinical severity indicators\n")
cat("- HIV status coding\n")
cat("- Comorbidity indicators\n")
cat("- Substance use variables\n")
cat("- Geographic and hospital indicators\n")

# ==============================================================================
# PHASE 7: DATA QUALITY CHECKS
# ==============================================================================

cat("\n=== DATA QUALITY CHECKS ===\n")

# Check for extreme/implausible values
quality_checks <- list(
  age_range = range(analysis_dataset$patient_age, na.rm = TRUE),
  weight_range = range(analysis_dataset$patient_weight, na.rm = TRUE),
  height_range = range(analysis_dataset$patient_height, na.rm = TRUE),
  bmi_range = range(analysis_dataset$bmi, na.rm = TRUE),
  sbp_range = range(analysis_dataset$patient_sbp, na.rm = TRUE),
  dbp_range = range(analysis_dataset$patient_dbp, na.rm = TRUE),
  hr_range = range(analysis_dataset$patient_hr, na.rm = TRUE),
  rr_range = range(analysis_dataset$patient_rr, na.rm = TRUE),
  temp_range = range(analysis_dataset$patient_temp, na.rm = TRUE),
  spo2_range = range(analysis_dataset$patient_spo, na.rm = TRUE)
)

cat("Data quality checks - Range of values:\n")
for(check in names(quality_checks)) {
  cat(sprintf("%-15s: %6.1f - %6.1f\n", check, 
              quality_checks[[check]][1], quality_checks[[check]][2]))
}

# Flag extreme values
extreme_values <- analysis_dataset %>%
  mutate(
    extreme_age = patient_age < 18 | patient_age > 100,
    extreme_weight = patient_weight < 30 | patient_weight > 150,
    extreme_height = patient_height < 130 | patient_height > 200,
    extreme_bmi = bmi < 10 | bmi > 50,
    extreme_sbp = patient_sbp < 50 | patient_sbp > 250,
    extreme_hr = patient_hr < 40 | patient_hr > 200,
    extreme_temp = patient_temp < 32 | patient_temp > 42
  ) %>%
  select(patient_id, starts_with("extreme_")) %>%
  pivot_longer(cols = starts_with("extreme_"), 
               names_to = "check", values_to = "extreme") %>%
  filter(extreme == TRUE, !is.na(extreme))

if(nrow(extreme_values) > 0) {
  cat("\nWARNING: Found", nrow(extreme_values), "extreme values:\n")
  print(extreme_values)
} else {
  cat("\n✓ No extreme values detected\n")
}

# ==============================================================================
# PHASE 8: FINAL DATASET SUMMARY
# ==============================================================================

cat("\n=== FINAL ANALYSIS DATASET SUMMARY ===\n")
cat("Total participants:", nrow(analysis_dataset), "\n")
cat("Variables created:", ncol(analysis_dataset), "\n")

# Primary outcome distribution
outcome_summary <- analysis_dataset %>%
  summarise(
    n_total = n(),
    hospital_deaths = sum(died_hospital, na.rm = TRUE),
    hospital_death_rate = round(mean(died_hospital, na.rm = TRUE) * 100, 1),
    day30_deaths = sum(died_30day, na.rm = TRUE),
    day30_death_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    rehospitalizations = sum(rehospitalized, na.rm = TRUE),
    rehospitalization_rate = round(mean(rehospitalized, na.rm = TRUE) * 100, 1),
    poor_outcomes = sum(poor_outcome, na.rm = TRUE),
    poor_outcome_rate = round(mean(poor_outcome, na.rm = TRUE) * 100, 1)
  )

cat("\nOUTCOME SUMMARY:\n")
cat("Hospital mortality:", outcome_summary$hospital_deaths, 
    "(", outcome_summary$hospital_death_rate, "%)\n")
cat("30-day mortality:", outcome_summary$day30_deaths, 
    "(", outcome_summary$day30_death_rate, "%)\n")
cat("Rehospitalization:", outcome_summary$rehospitalizations, 
    "(", outcome_summary$rehospitalization_rate, "%)\n")

# HIV status distribution
hiv_summary <- analysis_dataset %>%
  count(hiv_status) %>%
  mutate(percent = round(n/sum(n)*100, 1))

cat("\nHIV STATUS DISTRIBUTION:\n")
print(hiv_summary)

# Save the prepared dataset
write_csv(analysis_dataset, "LoRTISA_analysis_dataset.csv")
cat("\n✓ Analysis dataset saved as 'LoRTISA_analysis_dataset.csv'\n")

# Create data dictionary
variable_descriptions <- data.frame(
  variable = c("died_30day", "died_hospital", "rehospitalized", "poor_outcome",
               "age_65plus", "bmi_under18.5", "sbp_low", "rr_high", "spo2_low",
               "clinical_severe", "hiv_positive", "diabetes", "tb_history"),
  description = c("30-day mortality (0/1)", "Hospital mortality (0/1)", 
                 "30-day rehospitalization (0/1)", "Composite poor outcome (0/1)",
                 "Age ≥65 years (0/1)", "BMI <18.5 kg/m² (0/1)", 
                 "Systolic BP <90 mmHg (0/1)", "Respiratory rate >24/min (0/1)",
                 "SpO2 <90% (0/1)", "Severely affected clinical status (0/1)",
                 "HIV positive (0/1)", "Diabetes mellitus (0/1)", "TB history (0/1)"),
  type = c(rep("Outcome", 4), rep("Predictor", 9))
)

write_csv(variable_descriptions, "LoRTISA_data_dictionary.csv")
cat("✓ Data dictionary saved as 'LoRTISA_data_dictionary.csv'\n")

cat("\n=== DATA PREPARATION COMPLETED SUCCESSFULLY ===\n")
cat("Ready for analysis!\n")