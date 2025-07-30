# LoRTISA Study - Research Question 1 (SIMPLIFIED VERSION)
# MORTALITY RISK PREDICTION MODEL
# Using minimal package dependencies

# ==============================================================================
# SETUP - Using base R and essential packages only
# ==============================================================================

cat("=== RESEARCH QUESTION 1: MORTALITY PREDICTION (SIMPLIFIED) ===\n")

# Load only essential packages (with error handling)
load_package <- function(pkg) {
  if(require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("✓ Loaded:", pkg, "\n")
    return(TRUE)
  } else {
    cat("✗ Could not load:", pkg, "\n")
    return(FALSE)
  }
}

# Try to load packages
has_dplyr <- load_package("dplyr")
has_proc <- load_package("pROC")
has_boot <- load_package("boot")

set.seed(123)

# ==============================================================================
# DATA LOADING AND PREPARATION
# ==============================================================================

cat("\n=== LOADING DATA ===\n")
data <- read.csv("LoRTISA_analysis_dataset_corrected.csv", stringsAsFactors = FALSE)
cat("Dataset loaded:", nrow(data), "participants\n")

# Key variables for analysis
key_vars <- c("patient_id", "died_30day", "age_continuous", "patient_gender", 
              "patient_sbp", "patient_rr", "patient_spo", "bmi", 
              "hiv_positive", "clinical_severe", "hospital")

# Create analysis dataset with complete cases
if(has_dplyr) {
  analysis_data <- data %>%
    filter(!is.na(died_30day)) %>%
    select(all_of(key_vars)) %>%
    na.omit()
} else {
  # Base R approach
  analysis_data <- data[!is.na(data$died_30day), key_vars]
  analysis_data <- analysis_data[complete.cases(analysis_data), ]
}

cat("Complete cases for analysis:", nrow(analysis_data), "\n")
cat("30-day mortality rate:", round(mean(analysis_data$died_30day)*100, 1), "%\n")

# ==============================================================================
# UNIVARIABLE ANALYSIS
# ==============================================================================

cat("\n=== UNIVARIABLE ANALYSIS ===\n")

# Function for univariable logistic regression
univar_analysis <- function(data, outcome, predictor) {
  formula_str <- paste(outcome, "~", predictor)
  
  tryCatch({
    model <- glm(as.formula(formula_str), data = data, family = binomial)
    coef_summary <- summary(model)$coefficients
    
    if(nrow(coef_summary) > 1) {
      or <- exp(coef_summary[2, 1])
      ci <- exp(confint(model)[2, ])
      p_val <- coef_summary[2, 4]
      
      return(list(
        variable = predictor,
        or = round(or, 2),
        ci_lower = round(ci[1], 2),
        ci_upper = round(ci[2], 2),
        p_value = round(p_val, 4)
      ))
    }
  }, error = function(e) {
    return(NULL)
  })
}

# Analyze each predictor
predictors <- c("age_continuous", "patient_sbp", "patient_rr", "patient_spo", 
                "bmi", "hiv_positive", "clinical_severe")

univar_results <- list()
for(pred in predictors) {
  if(pred %in% names(analysis_data)) {
    result <- univar_analysis(analysis_data, "died_30day", pred)
    if(!is.null(result)) {
      univar_results[[pred]] <- result
      cat(sprintf("%-15s OR: %5.2f (%4.2f-%4.2f) p=%6.4f\n", 
                 pred, result$or, result$ci_lower, result$ci_upper, result$p_value))
    }
  }
}

# Select variables for multivariable model (p < 0.20)
significant_vars <- names(univar_results)[
  sapply(univar_results, function(x) x$p_value < 0.20)
]
cat("\nVariables for multivariable model (p<0.20):\n")
cat(paste(significant_vars, collapse = ", "), "\n")

# ==============================================================================
# MULTIVARIABLE MODEL
# ==============================================================================

if(length(significant_vars) > 0) {
  cat("\n=== MULTIVARIABLE MODEL ===\n")
  
  # Create formula
  formula_mv <- paste("died_30day ~", paste(significant_vars, collapse = " + "))
  cat("Formula:", formula_mv, "\n")
  
  # Fit model
  mv_model <- glm(as.formula(formula_mv), data = analysis_data, family = binomial)
  
  # Print summary
  cat("\nModel Summary:\n")
  print(summary(mv_model))
  
  # Extract coefficients
  coef_table <- summary(mv_model)$coefficients
  conf_int <- confint(mv_model)
  
  cat("\nFinal Model Results:\n")
  for(i in 2:nrow(coef_table)) {  # Skip intercept
    var_name <- rownames(coef_table)[i]
    or <- exp(coef_table[i, 1])
    ci_lower <- exp(conf_int[i, 1])
    ci_upper <- exp(conf_int[i, 2])
    p_val <- coef_table[i, 4]
    
    cat(sprintf("%-20s OR: %5.2f (%4.2f-%4.2f) p=%6.4f\n", 
               var_name, or, ci_lower, ci_upper, p_val))
  }
  
  # Model fit statistics
  cat("\nModel Fit:\n")
  cat("AIC:", round(AIC(mv_model), 1), "\n")
  cat("Null deviance:", round(mv_model$null.deviance, 1), "\n")
  cat("Residual deviance:", round(mv_model$deviance, 1), "\n")
  pseudo_r2 <- 1 - (mv_model$deviance / mv_model$null.deviance)
  cat("Pseudo R-squared:", round(pseudo_r2, 3), "\n")
  
  # ==============================================================================
  # MODEL PERFORMANCE
  # ==============================================================================
  
  cat("\n=== MODEL PERFORMANCE ===\n")
  
  # Generate predictions
  analysis_data$predicted_prob <- predict(mv_model, type = "response")
  
  # ROC Analysis (if pROC package available)
  if(has_proc) {
    roc_result <- roc(analysis_data$died_30day, analysis_data$predicted_prob, 
                     levels = c(0, 1), direction = "<", quiet = TRUE)
    auc_value <- as.numeric(auc(roc_result))
    cat("C-statistic (AUC):", round(auc_value, 3), "\n")
    
    # Find optimal threshold using Youden index
    # Use a more basic approach that works across pROC versions
    roc_coords <- coords(roc_result, "all", ret=c("threshold", "sensitivity", "specificity"))
    youden_index <- roc_coords$sensitivity + roc_coords$specificity - 1
    best_idx <- which.max(youden_index)
    
    optimal_threshold <- roc_coords$threshold[best_idx]
    sensitivity <- roc_coords$sensitivity[best_idx]
    specificity <- roc_coords$specificity[best_idx]
    
    cat("Optimal threshold:", round(optimal_threshold, 3), "\n")
    cat("Sensitivity:", round(sensitivity, 3), "\n")
    cat("Specificity:", round(specificity, 3), "\n")
    
  } else {
    # Basic performance without pROC
    # Use median probability as threshold
    threshold <- median(analysis_data$predicted_prob)
    predictions <- ifelse(analysis_data$predicted_prob >= threshold, 1, 0)
    
    # Confusion matrix
    confusion <- table(Observed = analysis_data$died_30day, Predicted = predictions)
    cat("Confusion Matrix (threshold =", round(threshold, 3), "):\n")
    print(confusion)
    
    # Basic metrics
    if(nrow(confusion) == 2 && ncol(confusion) == 2) {
      sensitivity <- confusion[2,2] / (confusion[2,1] + confusion[2,2])
      specificity <- confusion[1,1] / (confusion[1,1] + confusion[1,2])
      cat("Sensitivity:", round(sensitivity, 3), "\n")
      cat("Specificity:", round(specificity, 3), "\n")
    }
  }
  
  # ==============================================================================
  # RISK STRATIFICATION
  # ==============================================================================
  
  cat("\n=== RISK STRATIFICATION ===\n")
  
  # Create tertiles for risk groups
  risk_cutoffs <- quantile(analysis_data$predicted_prob, probs = c(1/3, 2/3))
  
  analysis_data$risk_group <- cut(
    analysis_data$predicted_prob,
    breaks = c(0, risk_cutoffs[1], risk_cutoffs[2], 1),
    labels = c("Low Risk", "Moderate Risk", "High Risk"),
    include.lowest = TRUE
  )
  
  # Risk stratification table
  risk_table <- aggregate(died_30day ~ risk_group, data = analysis_data, 
                         FUN = function(x) c(n = length(x), deaths = sum(x), 
                                           rate = round(mean(x)*100, 1)))
  
  cat("Risk Stratification:\n")
  for(i in 1:nrow(risk_table)) {
    group <- risk_table$risk_group[i]
    n <- risk_table$died_30day[i, "n"]
    deaths <- risk_table$died_30day[i, "deaths"]
    rate <- risk_table$died_30day[i, "rate"]
    cat(sprintf("%-15s: %2.0f/%2.0f (%4.1f%%)\n", group, deaths, n, rate))
  }
  
  # ==============================================================================
  # SAVE RESULTS
  # ==============================================================================
  
  cat("\n=== SAVING RESULTS ===\n")
  
  # Save model
  saveRDS(mv_model, "mortality_prediction_model_simplified.rds")
  cat("✓ Model saved\n")
  
  # Save data with predictions
  write.csv(analysis_data, "mortality_analysis_results_simplified.csv", row.names = FALSE)
  cat("✓ Results saved\n")
  
  # Save summary results
  summary_results <- data.frame(
    variable = rownames(coef_table)[-1],
    coefficient = round(coef_table[-1, 1], 3),
    or = round(exp(coef_table[-1, 1]), 2),
    ci_lower = round(exp(conf_int[-1, 1]), 2),
    ci_upper = round(exp(conf_int[-1, 2]), 2),
    p_value = round(coef_table[-1, 4], 4)
  )
  
  write.csv(summary_results, "mortality_model_coefficients_simplified.csv", row.names = FALSE)
  cat("✓ Model coefficients saved\n")
  
  # ==============================================================================
  # SUMMARY
  # ==============================================================================
  
  cat("\n=== ANALYSIS SUMMARY ===\n")
  cat("Sample size:", nrow(analysis_data), "\n")
  cat("30-day mortality:", sum(analysis_data$died_30day), "/", nrow(analysis_data),
      "(", round(mean(analysis_data$died_30day)*100, 1), "%)\n")
  cat("Variables in final model:", length(significant_vars), "\n")
  if(exists("auc_value")) {
    cat("Model C-statistic:", round(auc_value, 3), "\n")
  }
  
  cat("\nKey Findings:\n")
  for(i in 1:nrow(summary_results)) {
    var <- summary_results$variable[i]
    or <- summary_results$or[i]
    p <- summary_results$p_value[i]
    significance <- ifelse(p < 0.05, "***", ifelse(p < 0.10, "**", "*"))
    cat("- ", var, ": OR =", or, significance, "\n")
  }
  
} else {
  cat("No variables met criteria for multivariable modeling\n")
}

cat("\n=== ANALYSIS COMPLETED ===\n")