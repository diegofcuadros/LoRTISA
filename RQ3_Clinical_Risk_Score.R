# LoRTISA Study - Research Question 3
# CLINICAL RISK SCORE DEVELOPMENT
# "Can we develop a simple risk score for CAP mortality in resource-limited settings?"

# ==============================================================================
# RESEARCH CONTEXT
# ==============================================================================
# Goal: Create a simple integer-based bedside risk score using only clinical variables
# Innovation: No laboratory tests required - feasible for resource-limited settings
# Based on RQ1 validated predictors: respiratory rate, SBP, SpO2
# Target: 0-7 point score for frontline healthcare workers

# ==============================================================================
# SETUP AND DATA LOADING
# ==============================================================================

library(dplyr)
library(ggplot2)
library(pROC)
library(boot)

set.seed(123)

cat("=== RESEARCH QUESTION 3: CLINICAL RISK SCORE DEVELOPMENT ===\n")
cat("Developing simple bedside risk score for CAP mortality prediction\n\n")

# Load corrected analysis dataset
data <- read.csv("LoRTISA_analysis_dataset_corrected.csv", stringsAsFactors = FALSE)

# Create analysis dataset with complete cases for key variables
key_vars <- c("patient_id", "died_30day", "age_continuous", "patient_gender", 
              "patient_sbp", "patient_rr", "patient_spo", "bmi", 
              "hiv_positive", "clinical_severe", "hospital")

score_data <- data %>%
  filter(!is.na(died_30day)) %>%
  select(all_of(key_vars)) %>%
  na.omit()

cat("Analysis sample:", nrow(score_data), "participants with complete data\n")
cat("30-day mortality rate:", round(mean(score_data$died_30day)*100, 1), "%\n\n")

# ==============================================================================
# PHASE 1: CANDIDATE VARIABLE SELECTION AND CUTPOINT OPTIMIZATION
# ==============================================================================

cat("=== PHASE 1: CANDIDATE VARIABLE SELECTION ===\n")

# Define candidate variables with clinical cutpoints based on literature and RQ1 results
candidate_vars <- list(
  age_65plus = list(
    var = "age_continuous", 
    cutpoint = 65, 
    direction = ">=",
    rationale = "Standard geriatric cutpoint, but may need Uganda-specific adjustment"
  ),
  age_50plus = list(
    var = "age_continuous", 
    cutpoint = 50, 
    direction = ">=",
    rationale = "Alternative age cutpoint for younger African population"
  ),
  rr_high = list(
    var = "patient_rr", 
    cutpoint = 30, 
    direction = ">=",
    rationale = "Severe tachypnea indicating respiratory distress"
  ),
  rr_moderate = list(
    var = "patient_rr", 
    cutpoint = 24, 
    direction = ">=",
    rationale = "Moderate tachypnea, more sensitive cutpoint"
  ),
  sbp_low = list(
    var = "patient_sbp", 
    cutpoint = 90, 
    direction = "<",
    rationale = "Hypotension indicating shock/severe illness"
  ),
  spo2_low = list(
    var = "patient_spo", 
    cutpoint = 90, 
    direction = "<",
    rationale = "Severe hypoxemia requiring immediate attention"
  ),
  bmi_severe_malnutrition = list(
    var = "bmi", 
    cutpoint = 16, 
    direction = "<",
    rationale = "Severe malnutrition (WHO Grade III)"
  ),
  bmi_underweight = list(
    var = "bmi", 
    cutpoint = 18.5, 
    direction = "<",
    rationale = "Underweight (WHO standard)"
  ),
  hiv_positive = list(
    var = "hiv_positive", 
    cutpoint = 1, 
    direction = "==",
    rationale = "HIV status (though RQ2 showed no mortality effect)"
  ),
  clinical_severe = list(
    var = "clinical_severe", 
    cutpoint = 1, 
    direction = "==",
    rationale = "Severe functional impairment (≥50% bedbound)"
  )
)

# Function to create binary variables and calculate OR
create_binary_predictor <- function(data, var_name, var_info) {
  var_col <- var_info$var
  cutpoint <- var_info$cutpoint
  direction <- var_info$direction
  
  if (direction == ">=") {
    binary_var <- ifelse(data[[var_col]] >= cutpoint, 1, 0)
  } else if (direction == "<") {
    binary_var <- ifelse(data[[var_col]] < cutpoint, 1, 0)
  } else if (direction == "==") {
    binary_var <- ifelse(data[[var_col]] == cutpoint, 1, 0)
  }
  
  # Calculate OR and 95% CI
  tryCatch({
    model <- glm(data$died_30day ~ binary_var, family = binomial)
    coef_summary <- summary(model)$coefficients
    
    if(nrow(coef_summary) > 1) {
      or <- exp(coef_summary[2, 1])
      ci <- exp(confint(model)[2, ])
      p_val <- coef_summary[2, 4]
      
      # Create cross-tabulation for prevalence
      crosstab <- table(binary_var, data$died_30day)
      if(ncol(crosstab) >= 2) {
        prevalence <- round(mean(binary_var, na.rm = TRUE) * 100, 1)
        
        return(list(
          variable = var_name,
          binary_data = binary_var,
          or = round(or, 2),
          ci_lower = round(ci[1], 2),
          ci_upper = round(ci[2], 2),
          p_value = round(p_val, 4),
          prevalence = prevalence,
          cutpoint = paste(var_info$var, direction, cutpoint),
          rationale = var_info$rationale
        ))
      }
    }
  }, error = function(e) {
    return(NULL)
  })
}

# Analyze all candidate variables
cat("CANDIDATE VARIABLE ANALYSIS:\n")
cat("Variable                 Cutpoint          OR (95% CI)      P-value  Prevalence\n")
cat("─────────────────────────────────────────────────────────────────────────────\n")

candidate_results <- list()
for(var_name in names(candidate_vars)) {
  result <- create_binary_predictor(score_data, var_name, candidate_vars[[var_name]])
  if(!is.null(result)) {
    candidate_results[[var_name]] <- result
    cat(sprintf("%-20s %-15s %4.2f (%4.2f-%4.2f) %6.4f   %5.1f%%\n",
               var_name, result$cutpoint, result$or, result$ci_lower, 
               result$ci_upper, result$p_value, result$prevalence))
  }
}

# Select variables with OR ≥ 1.5 and clinical relevance
significant_predictors <- names(candidate_results)[
  sapply(candidate_results, function(x) x$or >= 1.5 && x$p_value < 0.20)
]

cat("\nSELECTED PREDICTORS FOR RISK SCORE (OR ≥1.5, p<0.20):\n")
cat(paste(significant_predictors, collapse = ", "), "\n")

# ==============================================================================
# PHASE 2: MULTIVARIABLE MODEL FOR COEFFICIENT-BASED SCORING
# ==============================================================================

cat("\n=== PHASE 2: MULTIVARIABLE MODEL FOR SCORING ===\n")

if(length(significant_predictors) > 0) {
  
  # Add selected binary variables to dataset
  for(var_name in significant_predictors) {
    score_data[[var_name]] <- candidate_results[[var_name]]$binary_data
  }
  
  # Fit multivariable model
  formula_score <- paste("died_30day ~", paste(significant_predictors, collapse = " + "))
  cat("Multivariable formula:", formula_score, "\n")
  
  score_model <- glm(as.formula(formula_score), data = score_data, family = binomial)
  
  # Extract coefficients
  coef_table <- summary(score_model)$coefficients
  conf_int <- confint(score_model)
  
  cat("\nMULTIVARIABLE MODEL RESULTS:\n")
  cat("Variable                 Coefficient    OR (95% CI)      P-value\n")
  cat("─────────────────────────────────────────────────────────────────\n")
  
  # Store coefficients for scoring
  scoring_coefficients <- list()
  
  for(i in 2:nrow(coef_table)) {  # Skip intercept
    var_name <- rownames(coef_table)[i]
    coef <- coef_table[i, 1]
    or <- exp(coef)
    ci_lower <- exp(conf_int[i, 1])
    ci_upper <- exp(conf_int[i, 2])
    p_val <- coef_table[i, 4]
    
    scoring_coefficients[[var_name]] <- coef
    
    cat(sprintf("%-20s %10.3f    %4.2f (%4.2f-%4.2f) %6.4f\n",
               var_name, coef, or, ci_lower, ci_upper, p_val))
  }
  
  # ==============================================================================
  # PHASE 3: INTEGER SCORE CREATION
  # ==============================================================================
  
  cat("\n=== PHASE 3: INTEGER SCORE CREATION ===\n")
  
  # Method 1: Beta coefficient-based scoring
  # Divide each coefficient by the smallest coefficient and round
  min_coef <- min(abs(unlist(scoring_coefficients)))
  
  cat("RISK SCORE POINT ASSIGNMENT:\n")
  cat("Variable                 Coefficient    Points\n")
  cat("───────────────────────────────────────────────\n")
  
  score_points <- list()
  total_max_points <- 0
  
  for(var_name in names(scoring_coefficients)) {
    coef <- scoring_coefficients[[var_name]]
    points <- round(coef / min_coef)
    points <- max(1, points)  # Minimum 1 point for any significant predictor
    
    score_points[[var_name]] <- points
    total_max_points <- total_max_points + points
    
    cat(sprintf("%-20s %10.3f    %6d\n", var_name, coef, points))
  }
  
  cat(sprintf("\nMaximum possible score: %d points\n", total_max_points))
  
  # Calculate risk score for each patient
  score_data$risk_score <- 0
  for(var_name in names(score_points)) {
    score_data$risk_score <- score_data$risk_score + 
      (score_data[[var_name]] * score_points[[var_name]])
  }
  
  # ==============================================================================
  # PHASE 4: SCORE VALIDATION AND PERFORMANCE
  # ==============================================================================
  
  cat("\n=== PHASE 4: SCORE VALIDATION ===\n")
  
  # Score distribution
  score_distribution <- table(score_data$risk_score)
  cat("SCORE DISTRIBUTION:\n")
  for(score in names(score_distribution)) {
    n <- score_distribution[score]
    pct <- round(n/nrow(score_data)*100, 1)
    cat(sprintf("Score %s: %d patients (%5.1f%%)\n", score, n, pct))
  }
  
  # ROC analysis for score performance
  roc_score <- roc(score_data$died_30day, score_data$risk_score, 
                   levels = c(0, 1), direction = "<", quiet = TRUE)
  auc_score <- as.numeric(auc(roc_score))
  
  cat(sprintf("\nSCORE PERFORMANCE:\n"))
  cat(sprintf("C-statistic (AUC): %.3f\n", auc_score))
  
  # Compare with original RQ1 model performance
  # Load RQ1 results for comparison
  if(file.exists("mortality_analysis_results_simplified.csv")) {
    rq1_data <- read.csv("mortality_analysis_results_simplified.csv")
    if("predicted_prob" %in% names(rq1_data)) {
      roc_rq1 <- roc(rq1_data$died_30day, rq1_data$predicted_prob, 
                     levels = c(0, 1), direction = "<", quiet = TRUE)
      auc_rq1 <- as.numeric(auc(roc_rq1))
      cat(sprintf("RQ1 model AUC: %.3f\n", auc_rq1))
      cat(sprintf("Performance difference: %.3f\n", auc_score - auc_rq1))
    }
  }
  
  # ==============================================================================
  # PHASE 5: RISK STRATIFICATION
  # ==============================================================================
  
  cat("\n=== PHASE 5: RISK STRATIFICATION ===\n")
  
  # Create risk categories based on score distribution and clinical utility
  # Low: 0-1 points, Moderate: 2-3 points, High: 4+ points
  score_data$risk_category <- cut(
    score_data$risk_score,
    breaks = c(-0.5, 1.5, 3.5, max(score_data$risk_score) + 0.5),
    labels = c("Low Risk", "Moderate Risk", "High Risk"),
    include.lowest = TRUE
  )
  
  # Risk stratification analysis
  risk_analysis <- score_data %>%
    group_by(risk_category) %>%
    summarise(
      n = n(),
      deaths = sum(died_30day),
      mortality_rate = round(mean(died_30day) * 100, 1),
      score_range = paste(min(risk_score), "-", max(risk_score)),
      .groups = "drop"
    )
  
  cat("RISK STRATIFICATION RESULTS:\n")
  cat("Risk Category    N    Deaths  Mortality  Score Range\n")
  cat("─────────────────────────────────────────────────────\n")
  
  for(i in 1:nrow(risk_analysis)) {
    cat(sprintf("%-13s %4d    %2d     %5.1f%%     %s\n",
               risk_analysis$risk_category[i],
               risk_analysis$n[i],
               risk_analysis$deaths[i],
               risk_analysis$mortality_rate[i],
               risk_analysis$score_range[i]))
  }
  
  # Statistical test for trend
  if(nrow(risk_analysis) >= 3) {
    # Test for linear trend in mortality rates
    trend_test <- cor.test(1:nrow(risk_analysis), risk_analysis$mortality_rate, 
                          method = "spearman")
    cat(sprintf("\nTrend test p-value: %.4f\n", trend_test$p.value))
  }
  
  # ==============================================================================
  # PHASE 6: CLINICAL UTILITY ANALYSIS
  # ==============================================================================
  
  cat("\n=== PHASE 6: CLINICAL UTILITY ANALYSIS ===\n")
  
  # Calculate performance metrics at different score cutpoints
  cutpoints <- 1:max(score_data$risk_score)
  
  performance_metrics <- data.frame(
    cutpoint = cutpoints,
    sensitivity = numeric(length(cutpoints)),
    specificity = numeric(length(cutpoints)),
    ppv = numeric(length(cutpoints)),
    npv = numeric(length(cutpoints)),
    accuracy = numeric(length(cutpoints))
  )
  
  for(i in 1:length(cutpoints)) {
    cut <- cutpoints[i]
    predictions <- ifelse(score_data$risk_score >= cut, 1, 0)
    
    # Confusion matrix
    tp <- sum(predictions == 1 & score_data$died_30day == 1)
    tn <- sum(predictions == 0 & score_data$died_30day == 0)
    fp <- sum(predictions == 1 & score_data$died_30day == 0)
    fn <- sum(predictions == 0 & score_data$died_30day == 1)
    
    performance_metrics$sensitivity[i] <- tp / (tp + fn)
    performance_metrics$specificity[i] <- tn / (tn + fp)
    performance_metrics$ppv[i] <- tp / (tp + fp)
    performance_metrics$npv[i] <- tn / (tn + fn)
    performance_metrics$accuracy[i] <- (tp + tn) / nrow(score_data)
  }
  
  # Find optimal cutpoint using Youden index
  youden <- performance_metrics$sensitivity + performance_metrics$specificity - 1
  optimal_idx <- which.max(youden)
  optimal_cutpoint <- cutpoints[optimal_idx]
  
  cat("PERFORMANCE AT DIFFERENT CUTPOINTS:\n")
  cat("Cutpoint  Sensitivity  Specificity   PPV    NPV   Accuracy\n")
  cat("───────────────────────────────────────────────────────────\n")
  
  for(i in 1:nrow(performance_metrics)) {
    marker <- ifelse(i == optimal_idx, "*", " ")
    cat(sprintf("%s   %2d      %7.3f     %7.3f  %6.3f %6.3f   %7.3f\n",
               marker, performance_metrics$cutpoint[i],
               performance_metrics$sensitivity[i],
               performance_metrics$specificity[i],
               performance_metrics$ppv[i],
               performance_metrics$npv[i],
               performance_metrics$accuracy[i]))
  }
  
  cat(sprintf("\n* Optimal cutpoint: %d (Youden index = %.3f)\n", 
             optimal_cutpoint, max(youden)))
  
  # ==============================================================================
  # PHASE 7: SAVE RESULTS AND CREATE CLINICAL TOOL
  # ==============================================================================
  
  cat("\n=== PHASE 7: SAVING RESULTS ===\n")
  
  # Save risk score dataset
  write.csv(score_data, "clinical_risk_score_dataset.csv", row.names = FALSE)
  cat("✓ Risk score dataset saved\n")
  
  # Save risk stratification results
  write.csv(risk_analysis, "clinical_risk_stratification.csv", row.names = FALSE)
  cat("✓ Risk stratification results saved\n")
  
  # Save performance metrics
  write.csv(performance_metrics, "clinical_score_performance.csv", row.names = FALSE)
  cat("✓ Performance metrics saved\n")
  
  # Create clinical scoring tool documentation
  scoring_tool <- data.frame(
    Variable = character(0),
    Criteria = character(0),
    Points = numeric(0),
    Rationale = character(0),
    stringsAsFactors = FALSE
  )
  
  for(var_name in names(score_points)) {
    var_info <- candidate_vars[[var_name]]
    scoring_tool <- rbind(scoring_tool, data.frame(
      Variable = var_name,
      Criteria = paste(var_info$var, var_info$direction, var_info$cutpoint),
      Points = score_points[[var_name]],
      Rationale = var_info$rationale,
      stringsAsFactors = FALSE
    ))
  }
  
  write.csv(scoring_tool, "clinical_scoring_tool.csv", row.names = FALSE)
  cat("✓ Clinical scoring tool saved\n")
  
  # ==============================================================================
  # PHASE 8: BOOTSTRAP VALIDATION
  # ==============================================================================
  
  cat("\n=== PHASE 8: BOOTSTRAP VALIDATION ===\n")
  
  # Bootstrap function for score validation
  bootstrap_score_validation <- function(data, indices) {
    boot_data <- data[indices, ]
    
    # Recalculate risk score (points remain the same)
    boot_data$risk_score <- 0
    for(var_name in names(score_points)) {
      boot_data$risk_score <- boot_data$risk_score + 
        (boot_data[[var_name]] * score_points[[var_name]])
    }
    
    # Calculate AUC
    roc_boot <- roc(boot_data$died_30day, boot_data$risk_score, 
                   levels = c(0, 1), direction = "<", quiet = TRUE)
    return(as.numeric(auc(roc_boot)))
  }
  
  # Perform bootstrap validation (100 iterations for speed)
  set.seed(123)
  boot_results <- boot(score_data, bootstrap_score_validation, R = 100)
  
  # Calculate bias-corrected AUC
  bias_corrected_auc <- 2 * auc_score - mean(boot_results$t)
  auc_ci <- quantile(boot_results$t, c(0.025, 0.975))
  
  cat(sprintf("Bootstrap validation (100 iterations):\n"))
  cat(sprintf("Original AUC: %.3f\n", auc_score))
  cat(sprintf("Bootstrap mean AUC: %.3f\n", mean(boot_results$t)))
  cat(sprintf("Bias-corrected AUC: %.3f\n", bias_corrected_auc))
  cat(sprintf("95%% CI: %.3f - %.3f\n", auc_ci[1], auc_ci[2]))
  
  # ==============================================================================
  # SUMMARY AND CLINICAL INTERPRETATION
  # ==============================================================================
  
  cat("\n=== RESEARCH QUESTION 3: CLINICAL RISK SCORE SUMMARY ===\n")
  
  cat(sprintf("Final Risk Score: %d variables, maximum %d points\n", 
             length(score_points), total_max_points))
  cat(sprintf("Score Performance: C-statistic = %.3f (95%% CI: %.3f-%.3f)\n",
             auc_score, auc_ci[1], auc_ci[2]))
  
  cat("\nRisk Score Components:\n")
  for(var_name in names(score_points)) {
    var_info <- candidate_vars[[var_name]]
    cat(sprintf("• %s (%s): %d point(s)\n", 
               var_info$cutpoint, var_name, score_points[[var_name]]))
  }
  
  cat("\nRisk Stratification:\n")
  for(i in 1:nrow(risk_analysis)) {
    cat(sprintf("• %s (%s points): %5.1f%% mortality (%d/%d patients)\n",
               risk_analysis$risk_category[i],
               risk_analysis$score_range[i],
               risk_analysis$mortality_rate[i],
               risk_analysis$deaths[i],
               risk_analysis$n[i]))
  }
  
  cat("\nClinical Interpretation:\n")
  cat("• Low Risk (0-1 points): Consider outpatient management if other factors allow\n")
  cat("• Moderate Risk (2-3 points): Standard inpatient care with regular monitoring\n")
  cat("• High Risk (4+ points): Intensive monitoring, consider HDU/ICU if available\n")
  
  cat("\nKey Advantages:\n")
  cat("• No laboratory tests required - bedside assessment only\n")
  cat("• Simple integer scoring system for frontline healthcare workers\n")
  cat("• Validated in sub-Saharan African population\n")
  cat("• Resource-appropriate for limited-resource settings\n")
  
} else {
  cat("No variables met criteria for risk score development\n")
}

cat("\n=== ANALYSIS COMPLETED ===\n")