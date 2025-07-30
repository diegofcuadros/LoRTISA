# LoRTISA Study - Clinical Implementation Tools
# Creating user-friendly risk calculator and clinical decision support tools

# ==============================================================================
# SETUP AND DOCUMENTATION
# ==============================================================================

library(dplyr)

cat("=== LoRTISA CLINICAL IMPLEMENTATION TOOLS ===\n")
cat("Creating practical tools for immediate clinical implementation\n\n")

# ==============================================================================
# TOOL 1: SIMPLE RISK CALCULATOR FUNCTION
# ==============================================================================

cat("=== TOOL 1: BEDSIDE RISK CALCULATOR ===\n")

# Create simple risk calculator function
calculate_cap_risk <- function(respiratory_rate, oxygen_saturation, verbose = TRUE) {
  
  # Input validation
  if(is.na(respiratory_rate) || is.na(oxygen_saturation)) {
    if(verbose) cat("Error: Missing required values\n")
    return(list(error = "Missing values"))
  }
  
  if(respiratory_rate < 0 || respiratory_rate > 60) {
    if(verbose) cat("Warning: Respiratory rate outside normal range (0-60)\n")
  }
  
  if(oxygen_saturation < 0 || oxygen_saturation > 100) {
    if(verbose) cat("Warning: Oxygen saturation outside normal range (0-100)\n")
  }
  
  # Calculate risk score
  score <- 0
  components <- c()
  
  # Respiratory rate component (3 points)
  if(respiratory_rate >= 30) {
    score <- score + 3
    components <- c(components, "Respiratory rate ≥30/min (+3 points)")
  }
  
  # Oxygen saturation component (1 point)  
  if(oxygen_saturation < 90) {
    score <- score + 1
    components <- c(components, "SpO2 <90% (+1 point)")
  }
  
  # Determine risk category
  if(score <= 1) {
    risk_category <- "LOW RISK"
    mortality_estimate <- "6.4%"
    clinical_action <- "Consider outpatient management if other factors allow"
    color_code <- "GREEN"
  } else if(score == 3) {
    risk_category <- "MODERATE RISK"  
    mortality_estimate <- "17.8%"
    clinical_action <- "Standard inpatient care with regular monitoring"
    color_code <- "YELLOW"
  } else if(score >= 4) {
    risk_category <- "HIGH RISK"
    mortality_estimate <- "25.0%"
    clinical_action <- "Intensive monitoring, consider HDU/ICU if available"
    color_code <- "RED"
  }
  
  # Create results
  results <- list(
    total_score = score,
    risk_category = risk_category,
    mortality_estimate = mortality_estimate,
    clinical_action = clinical_action,
    color_code = color_code,
    components_present = components,
    respiratory_rate = respiratory_rate,
    oxygen_saturation = oxygen_saturation
  )
  
  # Print results if verbose
  if(verbose) {
    cat("\\n=== LoRTISA CAP RISK ASSESSMENT ===\\n")
    cat("Patient Assessment:\\n")
    cat("• Respiratory Rate:", respiratory_rate, "/min\\n")
    cat("• Oxygen Saturation:", oxygen_saturation, "%\\n\\n")
    
    cat("Risk Score Calculation:\\n")
    if(length(components) > 0) {
      for(component in components) {
        cat("✓", component, "\\n")
      }
    } else {
      cat("• No high-risk features present\\n")
    }
    cat("\\nTOTAL SCORE:", score, "points\\n\\n")
    
    cat("=== CLINICAL ASSESSMENT ===\\n")
    cat("Risk Category:", risk_category, "(", color_code, ")\\n")
    cat("30-day Mortality Risk:", mortality_estimate, "\\n")
    cat("Recommended Action:", clinical_action, "\\n")
    cat("================================\\n\\n")
  }
  
  return(results)
}

# Test the calculator with examples
cat("Testing risk calculator with example patients:\\n\\n")

cat("Example 1 - Low Risk Patient:\\n")
test1 <- calculate_cap_risk(20, 95)

cat("Example 2 - Moderate Risk Patient:\\n")  
test2 <- calculate_cap_risk(32, 95)

cat("Example 3 - High Risk Patient:\\n")
test3 <- calculate_cap_risk(35, 85)

# ==============================================================================
# TOOL 2: CLINICAL DECISION FLOWCHART (TEXT-BASED)
# ==============================================================================

cat("=== TOOL 2: CLINICAL DECISION FLOWCHART ===\\n")

create_clinical_flowchart <- function() {
  flowchart <- "
=============================================================================
                    LoRTISA CAP MORTALITY RISK ASSESSMENT
                           Clinical Decision Flowchart
=============================================================================

STEP 1: MEASURE VITAL SIGNS
│
├─ Respiratory Rate: _____ breaths/minute
│  
└─ Oxygen Saturation: _____ %


STEP 2: CALCULATE RISK SCORE
│
├─ Is Respiratory Rate ≥ 30/min?
│  │
│  ├─ YES → Add 3 points
│  └─ NO  → Add 0 points
│
└─ Is SpO2 < 90%?
   │
   ├─ YES → Add 1 point  
   └─ NO  → Add 0 points

   TOTAL SCORE: _____ points (0-4 possible)


STEP 3: DETERMINE RISK CATEGORY & ACTION

┌─────────────────┬────────────────┬──────────────────┬─────────────────────┐
│   SCORE RANGE   │  RISK CATEGORY │   MORTALITY RISK │   CLINICAL ACTION   │
├─────────────────┼────────────────┼──────────────────┼─────────────────────┤
│   0-1 points    │   🟢 LOW RISK   │      6.4%        │ • Consider outpatient│
│                 │                │                  │   if other factors  │
│                 │                │                  │   allow             │
│                 │                │                  │ • Regular follow-up  │
├─────────────────┼────────────────┼──────────────────┼─────────────────────┤
│   3 points      │ 🟡 MODERATE RISK│     17.8%        │ • Standard inpatient│
│                 │                │                  │   care              │ 
│                 │                │                  │ • Regular monitoring │
├─────────────────┼────────────────┼──────────────────┼─────────────────────┤
│   4 points      │  🔴 HIGH RISK   │     25.0%        │ • Intensive         │
│                 │                │                  │   monitoring        │
│                 │                │                  │ • Consider HDU/ICU  │
│                 │                │                  │   if available      │
└─────────────────┴────────────────┴──────────────────┴─────────────────────┘


ADDITIONAL CLINICAL CONSIDERATIONS:
• Consider patient age, comorbidities, and social factors
• HIV status does not significantly affect mortality risk
• Re-assess if clinical condition changes
• Document risk score in patient record

=============================================================================
        Developed from LoRTISA Study (N=354, Uganda)
        Validated C-statistic: 0.675 | Bootstrap validated
=============================================================================
"
  
  return(flowchart)
}

# Save flowchart to file
flowchart_text <- create_clinical_flowchart()
writeLines(flowchart_text, "Clinical_Decision_Flowchart.txt")
cat("✓ Clinical decision flowchart saved to file\\n")

# Print flowchart
cat(flowchart_text)

# ==============================================================================
# TOOL 3: BATCH RISK CALCULATOR FOR MULTIPLE PATIENTS
# ==============================================================================

cat("=== TOOL 3: BATCH RISK CALCULATOR ===\\n")

calculate_batch_risk <- function(patient_data) {
  
  # Validate input data
  required_cols <- c("patient_id", "respiratory_rate", "oxygen_saturation")
  missing_cols <- setdiff(required_cols, names(patient_data))
  
  if(length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Calculate risk for each patient
  results <- patient_data %>%
    rowwise() %>%
    mutate(
      # Calculate components
      rr_component = ifelse(respiratory_rate >= 30, 3, 0),
      spo2_component = ifelse(oxygen_saturation < 90, 1, 0),
      
      # Total score
      total_score = rr_component + spo2_component,
      
      # Risk category
      risk_category = case_when(
        total_score <= 1 ~ "Low Risk",
        total_score == 3 ~ "Moderate Risk", 
        total_score >= 4 ~ "High Risk"
      ),
      
      # Mortality estimate
      mortality_estimate = case_when(
        total_score <= 1 ~ "6.4%",
        total_score == 3 ~ "17.8%",
        total_score >= 4 ~ "25.0%"
      ),
      
      # Clinical action
      clinical_action = case_when(
        total_score <= 1 ~ "Consider outpatient management",
        total_score == 3 ~ "Standard inpatient care",
        total_score >= 4 ~ "Intensive monitoring/HDU"
      ),
      
      # Components present
      components_present = case_when(
        rr_component > 0 & spo2_component > 0 ~ "RR≥30 + SpO2<90",
        rr_component > 0 & spo2_component == 0 ~ "RR≥30 only",
        rr_component == 0 & spo2_component > 0 ~ "SpO2<90 only", 
        TRUE ~ "No high-risk features"
      )
    ) %>%
    ungroup()
  
  return(results)
}

# Example batch calculation
cat("Example batch calculation:\\n")
example_patients <- data.frame(
  patient_id = c("P001", "P002", "P003", "P004", "P005"),
  respiratory_rate = c(18, 25, 32, 28, 38),
  oxygen_saturation = c(96, 92, 88, 94, 85)
)

batch_results <- calculate_batch_risk(example_patients)
print(batch_results[, c("patient_id", "respiratory_rate", "oxygen_saturation", 
                        "total_score", "risk_category", "mortality_estimate")])

# Save batch function example
write.csv(batch_results, "Batch_Risk_Calculator_Example.csv", row.names = FALSE)
cat("\\n✓ Batch calculator example saved\\n")

# ==============================================================================
# TOOL 4: QUALITY IMPROVEMENT MONITORING TEMPLATE
# ==============================================================================

cat("\\n=== TOOL 4: QUALITY IMPROVEMENT TEMPLATE ===\\n")

create_qi_template <- function() {
  
  qi_template <- data.frame(
    Metric = c(
      "Total CAP Admissions",
      "Risk Assessments Performed", 
      "Risk Assessment Completion Rate",
      "Low Risk Patients (0-1 points)",
      "Moderate Risk Patients (3 points)",
      "High Risk Patients (4 points)",
      "Low Risk - Outpatient Management",
      "High Risk - ICU/HDU Admission", 
      "Overall 30-day Mortality",
      "Low Risk Mortality",
      "Moderate Risk Mortality", 
      "High Risk Mortality",
      "Risk Score Documentation Rate"
    ),
    Description = c(
      "Number of patients admitted with CAP diagnosis",
      "Number of patients with LoRTISA risk score calculated",
      "Percentage of CAP patients assessed (Target: >90%)",
      "Number and % of patients in low risk category",
      "Number and % of patients in moderate risk category", 
      "Number and % of patients in high risk category",
      "% of low-risk patients managed as outpatients (when appropriate)",
      "% of high-risk patients receiving intensive care",
      "Overall 30-day mortality rate (Benchmark: ~13%)",
      "Mortality rate in low-risk group (Benchmark: ~6%)",
      "Mortality rate in moderate-risk group (Benchmark: ~18%)",
      "Mortality rate in high-risk group (Benchmark: ~25%)",
      "% of assessments properly documented in medical records"
    ),
    Target_Value = c(
      "Hospital-specific",
      "≥90% of admissions",
      ">90%",
      "~53% of patients",
      "~30% of patients", 
      "~17% of patients",
      ">50% when appropriate",
      ">80% when available",
      "<15%",
      "<10%",
      "<20%",
      "<30%",
      ">95%"
    ),
    Current_Value = rep("", 13),
    Comments = rep("", 13)
  )
  
  return(qi_template)
}

qi_template <- create_qi_template()
write.csv(qi_template, "Quality_Improvement_Template.csv", row.names = FALSE)
cat("✓ Quality improvement monitoring template created\\n")

# ==============================================================================
# TOOL 5: TRAINING MATERIALS TEMPLATE
# ==============================================================================

cat("\\n=== TOOL 5: TRAINING MATERIALS ===\\n")

create_training_materials <- function() {
  
  training_content <- "
=============================================================================
                        LoRTISA CAP RISK SCORE
                    Healthcare Worker Training Module
=============================================================================

LEARNING OBJECTIVES:
After completing this training, healthcare workers will be able to:
1. Accurately assess CAP mortality risk using the LoRTISA score
2. Make appropriate clinical decisions based on risk stratification
3. Document risk assessments properly
4. Monitor quality improvement metrics

BACKGROUND:
• Community-acquired pneumonia (CAP) is a leading cause of mortality
• Early risk assessment improves patient outcomes
• LoRTISA score developed specifically for African populations
• No laboratory tests required - bedside assessment only

THE LoRTISA RISK SCORE:
┌─────────────────────────┬─────────┬────────────────────────┐
│      RISK FACTOR        │ POINTS  │      HOW TO ASSESS     │
├─────────────────────────┼─────────┼────────────────────────┤
│ Respiratory Rate ≥30/min│    3    │ Count breaths for 1 min│
│ SpO2 < 90%              │    1    │ Use pulse oximeter     │
└─────────────────────────┴─────────┴────────────────────────┘

RISK INTERPRETATION:
• 0-1 points = LOW RISK (6% mortality)
• 3 points = MODERATE RISK (18% mortality)  
• 4 points = HIGH RISK (25% mortality)

CLINICAL ACTIONS:
LOW RISK:    Consider outpatient care if socially appropriate
MODERATE:    Standard inpatient care with regular monitoring
HIGH RISK:   Intensive monitoring, ICU/HDU if available

PRACTICE CASES:
Case 1: 45-year-old patient, RR=28, SpO2=94% → Score=0 (Low Risk)
Case 2: 38-year-old patient, RR=32, SpO2=92% → Score=3 (Moderate Risk)
Case 3: 52-year-old patient, RR=36, SpO2=87% → Score=4 (High Risk)

DOCUMENTATION:
□ Record respiratory rate and SpO2
□ Calculate and document total score
□ Note risk category in clinical notes
□ Document clinical decision rationale

QUALITY ASSURANCE:
• Aim for >90% of CAP patients assessed
• Monitor mortality rates by risk category
• Regular audits of score calculation accuracy
• Feedback on clinical decision appropriateness

=============================================================================
"
  
  return(training_content)
}

training_materials <- create_training_materials()
writeLines(training_materials, "Healthcare_Worker_Training.txt")
cat("✓ Training materials created\\n")

# ==============================================================================
# SAVE ALL CLINICAL TOOLS SUMMARY
# ==============================================================================

cat("\\n=== SAVING CLINICAL TOOLS SUMMARY ===\\n")

# Create comprehensive tools summary
tools_summary <- data.frame(
  Tool_Name = c(
    "Bedside Risk Calculator Function",
    "Clinical Decision Flowchart", 
    "Batch Risk Calculator",
    "Quality Improvement Template",
    "Healthcare Worker Training Materials"
  ),
  File_Name = c(
    "calculate_cap_risk() function in R",
    "Clinical_Decision_Flowchart.txt",
    "Batch_Risk_Calculator_Example.csv", 
    "Quality_Improvement_Template.csv",
    "Healthcare_Worker_Training.txt"
  ),
  Purpose = c(
    "Individual patient risk assessment at bedside",
    "Step-by-step clinical decision support",
    "Multiple patient risk calculation for ward rounds",
    "Hospital quality monitoring and improvement",  
    "Staff education and competency development"
  ),
  Target_Users = c(
    "Physicians, Nurses, Clinical Officers",
    "All clinical staff managing CAP patients",
    "Senior clinicians, Ward teams",
    "Quality improvement teams, Hospital administrators",
    "Training coordinators, Clinical educators"
  ),
  Implementation_Level = c(
    "Individual Patient",
    "Individual Patient", 
    "Ward/Department",
    "Hospital System",
    "Health System"
  )
)

write.csv(tools_summary, "Clinical_Implementation_Tools_Summary.csv", row.names = FALSE)
cat("✓ Implementation tools summary saved\\n")

# ==============================================================================
# FINAL IMPLEMENTATION CHECKLIST
# ==============================================================================

cat("\\n=== IMPLEMENTATION CHECKLIST ===\\n")

implementation_checklist <- "
=============================================================================
                    LoRTISA CLINICAL IMPLEMENTATION CHECKLIST
=============================================================================

PRE-IMPLEMENTATION:
□ Staff training completed (use Healthcare_Worker_Training.txt)
□ Clinical decision flowchart posted in clinical areas
□ Pulse oximeters available and calibrated
□ Documentation templates updated
□ Quality improvement metrics baseline established

IMPLEMENTATION PHASE:
□ Risk calculator function integrated into clinical workflow
□ All CAP patients assessed using LoRTISA score within 4 hours
□ Risk scores documented in patient records
□ Clinical decisions aligned with risk categories
□ Weekly quality audits conducted

POST-IMPLEMENTATION:
□ Monthly review of mortality rates by risk category
□ Quarterly assessment of score utilization rates
□ Annual validation of score performance
□ Continuous staff education and feedback
□ Integration with electronic health records (if available)

SUCCESS METRICS:
□ >90% of CAP patients assessed
□ >95% documentation compliance
□ Mortality rates within expected ranges by risk category
□ Appropriate resource utilization (ICU/HDU for high-risk)
□ Staff satisfaction with clinical decision support

TROUBLESHOOTING:
□ Low utilization → Increase training, simplify workflow
□ Poor documentation → Template updates, audit feedback  
□ Unexpected mortality → Validate score calculation, consider confounders
□ Resource constraints → Adapt recommendations to local capacity

=============================================================================
"

writeLines(implementation_checklist, "Implementation_Checklist.txt")
cat("✓ Implementation checklist created\\n")

cat("\\n=== CLINICAL IMPLEMENTATION TOOLS COMPLETED ===\\n")
cat("Created comprehensive clinical implementation package:\\n")
cat("• Interactive risk calculator function\\n")
cat("• Clinical decision flowchart\\n") 
cat("• Batch processing capabilities\\n")
cat("• Quality improvement monitoring tools\\n")
cat("• Training materials and implementation checklist\\n")
cat("• All tools ready for immediate deployment\\n\\n")

# Test final calculator one more time
cat("=== FINAL DEMONSTRATION ===\\n")
cat("Testing complete clinical workflow:\\n\\n")
final_test <- calculate_cap_risk(34, 88)
cat("Clinical implementation tools package ready for deployment!\\n")