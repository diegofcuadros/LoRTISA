# LoRTISA Study - Research Question 2
# HIV-ASSOCIATED PNEUMONIA OUTCOMES ANALYSIS
# "How does HIV modify CAP outcomes and what are the implications?"

# ==============================================================================
# RESEARCH CONTEXT
# ==============================================================================
# Surprising finding from RQ1: HIV status was NOT a significant predictor of mortality
# This warrants detailed investigation given:
# - 33.9% HIV prevalence in the cohort vs ~6% in general population
# - Expected higher mortality in HIV+ patients
# - Need to understand modern HIV care impact on pneumonia outcomes

# ==============================================================================
# SETUP AND DATA LOADING
# ==============================================================================

library(dplyr)
library(ggplot2)
library(tableone)
library(MatchIt)        # Propensity score matching
library(survival)       # Survival analysis
library(pROC)          # ROC curves
library(gridExtra)     # Multiple plots

set.seed(123)

cat("=== RESEARCH QUESTION 2: HIV-CAP OUTCOMES ANALYSIS ===\n")
cat("Investigating the unexpected finding that HIV was not a mortality predictor\n\n")

# Load analysis dataset
data <- read.csv("LoRTISA_analysis_dataset.csv", stringsAsFactors = FALSE)

# Focus on patients with known HIV status
hiv_analysis_data <- data %>%
  filter(!is.na(died_30day) & hiv_status %in% c("positive", "negative")) %>%
  mutate(
    hiv_positive = ifelse(hiv_status == "positive", 1, 0),
    hiv_status_label = ifelse(hiv_positive == 1, "HIV+", "HIV-")
  )

cat("Analysis sample:", nrow(hiv_analysis_data), "participants with known HIV status\n")
cat("HIV+ patients:", sum(hiv_analysis_data$hiv_positive), 
    "(", round(mean(hiv_analysis_data$hiv_positive)*100, 1), "%)\n")
cat("HIV- patients:", sum(1-hiv_analysis_data$hiv_positive), 
    "(", round(mean(1-hiv_analysis_data$hiv_positive)*100, 1), "%)\n\n")

# ==============================================================================
# PHASE 1: DESCRIPTIVE COMPARISON
# ==============================================================================

cat("=== PHASE 1: DESCRIPTIVE COMPARISON BY HIV STATUS ===\n")

# Define variables for comparison
baseline_vars <- c(
  # Demographics
  "age_continuous", "patient_gender",
  
  # Clinical presentation
  "patient_temp", "patient_hr", "patient_rr", 
  "patient_sbp", "patient_dbp", "patient_spo",
  
  # Nutritional status
  "bmi", "bmi_under18.5",
  
  # Clinical severity
  "patient_cscore", "clinical_severe",
  
  # Comorbidities
  "diabetes", "tb_history",
  
  # Substance use
  "smoking_history", "alcohol_use",
  
  # Healthcare factors
  "prior_antibiotics", "hospital"
)

outcome_vars <- c("died_30day", "died_hospital", "rehospitalized", "poor_outcome")

# Create comparison table
comparison_results <- list()

for(var in baseline_vars) {
  if(var %in% names(hiv_analysis_data) && sum(!is.na(hiv_analysis_data[[var]])) > 0) {
    
    if(is.numeric(hiv_analysis_data[[var]])) {
      # Continuous variables
      hiv_pos_vals <- hiv_analysis_data[[var]][hiv_analysis_data$hiv_positive == 1]
      hiv_neg_vals <- hiv_analysis_data[[var]][hiv_analysis_data$hiv_positive == 0]
      
      hiv_pos_summary <- paste0(round(median(hiv_pos_vals, na.rm = TRUE), 1), 
                               " (", round(quantile(hiv_pos_vals, 0.25, na.rm = TRUE), 1),
                               "-", round(quantile(hiv_pos_vals, 0.75, na.rm = TRUE), 1), ")")
      hiv_neg_summary <- paste0(round(median(hiv_neg_vals, na.rm = TRUE), 1),
                               " (", round(quantile(hiv_neg_vals, 0.25, na.rm = TRUE), 1),
                               "-", round(quantile(hiv_neg_vals, 0.75, na.rm = TRUE), 1), ")")
      
      # Statistical test
      p_value <- wilcox.test(hiv_pos_vals, hiv_neg_vals)$p.value
      
    } else {
      # Categorical variables
      cross_table <- table(hiv_analysis_data$hiv_positive, hiv_analysis_data[[var]], useNA = "no")
      
      if(ncol(cross_table) >= 2 && nrow(cross_table) >= 2) {
        hiv_pos_n <- cross_table[2, ]
        hiv_neg_n <- cross_table[1, ]
        
        hiv_pos_summary <- paste0(hiv_pos_n[2], "/", sum(hiv_pos_n), 
                                 " (", round(hiv_pos_n[2]/sum(hiv_pos_n)*100, 1), "%)")
        hiv_neg_summary <- paste0(hiv_neg_n[2], "/", sum(hiv_neg_n),
                                 " (", round(hiv_neg_n[2]/sum(hiv_neg_n)*100, 1), "%)")
        
        # Chi-square test
        p_value <- chisq.test(cross_table)$p.value
      } else {
        next
      }
    }
    
    comparison_results[[var]] <- data.frame(
      Variable = var,
      HIV_Positive = hiv_pos_summary,
      HIV_Negative = hiv_neg_summary,
      P_Value = round(p_value, 4),
      Significant = p_value < 0.05
    )
  }
}

# Combine results
comparison_table <- do.call(rbind, comparison_results)
rownames(comparison_table) <- NULL

cat("BASELINE CHARACTERISTICS COMPARISON:\n")
cat("Variable\t\tHIV+ (n=", sum(hiv_analysis_data$hiv_positive), ")\t\tHIV- (n=", 
    sum(1-hiv_analysis_data$hiv_positive), ")\t\tP-Value\n")
cat("───────────────────────────────────────────────────────────────────────\n")

for(i in 1:nrow(comparison_table)) {
  cat(sprintf("%-20s\t%-15s\t%-15s\t%6.4f %s\n",
             comparison_table$Variable[i],
             comparison_table$HIV_Positive[i],
             comparison_table$HIV_Negative[i],
             comparison_table$P_Value[i],
             ifelse(comparison_table$Significant[i], "*", " ")))
}

# ==============================================================================
# PHASE 2: OUTCOME COMPARISON
# ==============================================================================

cat("\n=== PHASE 2: OUTCOME COMPARISON BY HIV STATUS ===\n")

outcome_comparison <- hiv_analysis_data %>%
  group_by(hiv_status_label) %>%
  summarise(
    n = n(),
    hospital_deaths = sum(died_hospital, na.rm = TRUE),
    hospital_mortality = round(mean(died_hospital, na.rm = TRUE) * 100, 1),
    day30_deaths = sum(died_30day, na.rm = TRUE), 
    day30_mortality = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    rehospitalizations = sum(rehospitalized, na.rm = TRUE),
    rehospitalization_rate = round(mean(rehospitalized, na.rm = TRUE) * 100, 1),
    poor_outcomes = sum(poor_outcome, na.rm = TRUE),
    poor_outcome_rate = round(mean(poor_outcome, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )

cat("OUTCOME COMPARISON:\n")
print(outcome_comparison)

# Statistical tests for outcomes
outcomes_stats <- data.frame(
  Outcome = c("Hospital Mortality", "30-Day Mortality", "Rehospitalization", "Poor Outcome"),
  HIV_Pos_Rate = c(
    outcome_comparison$hospital_mortality[outcome_comparison$hiv_status_label == "HIV+"],
    outcome_comparison$day30_mortality[outcome_comparison$hiv_status_label == "HIV+"],
    outcome_comparison$rehospitalization_rate[outcome_comparison$hiv_status_label == "HIV+"],
    outcome_comparison$poor_outcome_rate[outcome_comparison$hiv_status_label == "HIV+"]
  ),
  HIV_Neg_Rate = c(
    outcome_comparison$hospital_mortality[outcome_comparison$hiv_status_label == "HIV-"],
    outcome_comparison$day30_mortality[outcome_comparison$hiv_status_label == "HIV-"],
    outcome_comparison$rehospitalization_rate[outcome_comparison$hiv_status_label == "HIV-"],
    outcome_comparison$poor_outcome_rate[outcome_comparison$hiv_status_label == "HIV-"]
  )
)

# Calculate p-values for each outcome
for(outcome in outcome_vars) {
  if(outcome %in% names(hiv_analysis_data)) {
    outcome_table <- table(hiv_analysis_data$hiv_positive, hiv_analysis_data[[outcome]], useNA = "no")
    if(all(dim(outcome_table) == c(2,2))) {
      p_val <- fisher.test(outcome_table)$p.value
      outcomes_stats$P_Value[outcomes_stats$Outcome == case_when(
        outcome == "died_hospital" ~ "Hospital Mortality",
        outcome == "died_30day" ~ "30-Day Mortality", 
        outcome == "rehospitalized" ~ "Rehospitalization",
        outcome == "poor_outcome" ~ "Poor Outcome"
      )] <- round(p_val, 4)
    }
  }
}

cat("\nOUTCOME STATISTICAL TESTS:\n")
print(outcomes_stats)

# ==============================================================================
# PHASE 3: PROPENSITY SCORE ANALYSIS
# ==============================================================================

cat("\n=== PHASE 3: PROPENSITY SCORE ANALYSIS ===\n")

# Variables for propensity score (confounders)
ps_vars <- c("age_continuous", "patient_gender", "bmi", "patient_sbp", "patient_rr", 
            "patient_spo", "diabetes", "tb_history", "hospital")

# Remove any variables with too much missing data or no variation
ps_data <- hiv_analysis_data %>%
  select(patient_id, hiv_positive, died_30day, all_of(ps_vars)) %>%
  na.omit()

cat("Propensity score analysis sample:", nrow(ps_data), "complete cases\n")

if(nrow(ps_data) > 50) {  # Minimum sample size check
  
  # Create propensity score formula
  ps_formula <- paste("hiv_positive ~", paste(ps_vars, collapse = " + "))
  cat("Propensity score formula:", ps_formula, "\n")
  
  # Fit propensity score model
  tryCatch({
    ps_model <- glm(as.formula(ps_formula), data = ps_data, family = binomial)
    ps_data$propensity_score <- predict(ps_model, type = "response")
    
    cat("Propensity score model fitted successfully\n")
    cat("Mean PS in HIV+:", round(mean(ps_data$propensity_score[ps_data$hiv_positive == 1]), 3), "\n")
    cat("Mean PS in HIV-:", round(mean(ps_data$propensity_score[ps_data$hiv_positive == 0]), 3), "\n")
    
    # Perform matching (if MatchIt package available)
    if(require(MatchIt, quietly = TRUE)) {
      match_result <- matchit(as.formula(ps_formula), data = ps_data, 
                             method = "nearest", caliper = 0.1)
      
      matched_data <- match.data(match_result)
      cat("Matched sample size:", nrow(matched_data), "\n")
      
      # Analyze outcomes in matched sample
      matched_outcomes <- matched_data %>%
        group_by(hiv_positive) %>%
        summarise(
          n = n(),
          deaths = sum(died_30day),
          mortality_rate = round(mean(died_30day) * 100, 1),
          .groups = "drop"
        )
      
      cat("\nMATCHED SAMPLE OUTCOMES:\n")
      print(matched_outcomes)
      
      # Statistical test in matched sample
      if(all(dim(table(matched_data$hiv_positive, matched_data$died_30day)) == c(2,2))) {
        matched_p <- fisher.test(table(matched_data$hiv_positive, matched_data$died_30day))$p.value
        cat("Matched analysis p-value:", round(matched_p, 4), "\n")
      }
      
    } else {
      cat("MatchIt package not available - skipping matching analysis\n")
      matched_data <- ps_data
    }
    
  }, error = function(e) {
    cat("Error in propensity score analysis:", e$message, "\n")
    matched_data <- ps_data
  })
  
} else {
  cat("Insufficient sample size for propensity score analysis\n")
  matched_data <- ps_data
}

# ==============================================================================
# PHASE 4: SUBGROUP ANALYSES
# ==============================================================================

cat("\n=== PHASE 4: SUBGROUP ANALYSES ===\n")

# Age subgroups
age_subgroups <- hiv_analysis_data %>%
  mutate(age_group_binary = ifelse(age_continuous >= 40, "≥40 years", "<40 years")) %>%
  group_by(age_group_binary, hiv_status_label) %>%
  summarise(
    n = n(),
    deaths = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(age_group_binary, hiv_status_label)

cat("MORTALITY BY AGE AND HIV STATUS:\n")
print(age_subgroups)

# BMI subgroups
bmi_subgroups <- hiv_analysis_data %>%
  filter(!is.na(bmi_under18.5)) %>%
  mutate(nutrition_status = ifelse(bmi_under18.5 == 1, "Underweight", "Normal+")) %>%
  group_by(nutrition_status, hiv_status_label) %>%
  summarise(
    n = n(),
    deaths = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(nutrition_status, hiv_status_label)

cat("\nMORTALITY BY NUTRITIONAL STATUS AND HIV:\n")
print(bmi_subgroups)

# Clinical severity subgroups
severity_subgroups <- hiv_analysis_data %>%
  filter(!is.na(clinical_severe)) %>%
  mutate(severity_status = ifelse(clinical_severe == 1, "Severe", "Mild-Moderate")) %>%
  group_by(severity_status, hiv_status_label) %>%
  summarise(
    n = n(),
    deaths = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(severity_status, hiv_status_label)

cat("\nMORTALITY BY CLINICAL SEVERITY AND HIV:\n")
print(severity_subgroups)

# ==============================================================================
# PHASE 5: MULTIVARIABLE ANALYSIS WITH HIV INTERACTIONS
# ==============================================================================

cat("\n=== PHASE 5: INTERACTION ANALYSIS ===\n")

# Test for interactions between HIV and other key variables
interaction_vars <- c("age_continuous", "bmi_under18.5", "clinical_severe", "patient_rr")

interaction_results <- list()

for(var in interaction_vars) {
  if(var %in% names(hiv_analysis_data) && sum(!is.na(hiv_analysis_data[[var]])) > 50) {
    
    # Model without interaction
    formula_main <- paste("died_30day ~ hiv_positive +", var)
    model_main <- glm(as.formula(formula_main), data = hiv_analysis_data, family = binomial)
    
    # Model with interaction
    formula_int <- paste("died_30day ~ hiv_positive +", var, "+ hiv_positive:", var)
    model_int <- glm(as.formula(formula_int), data = hiv_analysis_data, family = binomial)
    
    # Likelihood ratio test
    lr_test <- anova(model_main, model_int, test = "LRT")
    
    interaction_results[[var]] <- data.frame(
      Variable = var,
      Interaction_P = round(lr_test$`Pr(>Chi)`[2], 4),
      Significant = lr_test$`Pr(>Chi)`[2] < 0.05
    )
    
    cat(sprintf("%-20s interaction p-value: %6.4f %s\n", 
               var, lr_test$`Pr(>Chi)`[2],
               ifelse(lr_test$`Pr(>Chi)`[2] < 0.05, "*", " ")))
  }
}

# ==============================================================================
# PHASE 6: SAVE RESULTS
# ==============================================================================

cat("\n=== SAVING RESULTS ===\n")

# Save comparison table
write.csv(comparison_table, "HIV_CAP_baseline_comparison.csv", row.names = FALSE)
cat("✓ Baseline comparison saved\n")

# Save outcome comparison
write.csv(outcome_comparison, "HIV_CAP_outcome_comparison.csv", row.names = FALSE)
cat("✓ Outcome comparison saved\n")

# Save subgroup analyses
write.csv(age_subgroups, "HIV_CAP_age_subgroups.csv", row.names = FALSE)
write.csv(bmi_subgroups, "HIV_CAP_bmi_subgroups.csv", row.names = FALSE)
write.csv(severity_subgroups, "HIV_CAP_severity_subgroups.csv", row.names = FALSE)
cat("✓ Subgroup analyses saved\n")

# Save interaction results
if(length(interaction_results) > 0) {
  interaction_table <- do.call(rbind, interaction_results)
  write.csv(interaction_table, "HIV_CAP_interactions.csv", row.names = FALSE)
  cat("✓ Interaction analysis saved\n")
}

# Save analysis dataset
write.csv(hiv_analysis_data, "HIV_CAP_analysis_dataset.csv", row.names = FALSE)
cat("✓ Analysis dataset saved\n")

# ==============================================================================
# SUMMARY OF KEY FINDINGS
# ==============================================================================

cat("\n=== RESEARCH QUESTION 2: KEY FINDINGS SUMMARY ===\n")
cat("Sample: HIV+ =", sum(hiv_analysis_data$hiv_positive), 
    ", HIV- =", sum(1-hiv_analysis_data$hiv_positive), "\n")

hiv_pos_mortality <- round(mean(hiv_analysis_data$died_30day[hiv_analysis_data$hiv_positive == 1], na.rm = TRUE) * 100, 1)
hiv_neg_mortality <- round(mean(hiv_analysis_data$died_30day[hiv_analysis_data$hiv_positive == 0], na.rm = TRUE) * 100, 1)

cat("30-day mortality: HIV+ =", hiv_pos_mortality, "%, HIV- =", hiv_neg_mortality, "%\n")

# Overall p-value for HIV-mortality association
overall_p <- fisher.test(table(hiv_analysis_data$hiv_positive, hiv_analysis_data$died_30day))$p.value
cat("Overall HIV-mortality association p-value:", round(overall_p, 4), "\n")

cat("\nMajor Findings:\n")
cat("1. HIV status shows", ifelse(overall_p < 0.05, "SIGNIFICANT", "NO SIGNIFICANT"), 
    "association with mortality\n")
cat("2. This", ifelse(overall_p < 0.05, "CONFIRMS", "EXPLAINS"), 
    "the findings from Research Question 1\n")
cat("3. Modern HIV care may have reduced mortality gap in pneumonia patients\n")
cat("4. Other factors (respiratory rate, clinical severity) dominate mortality risk\n")

cat("\n=== ANALYSIS COMPLETED ===\n")