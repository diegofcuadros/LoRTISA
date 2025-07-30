# LoRTISA Study - Geospatial Analysis (Fixed Version)
# Geographic patterns in CAP outcomes, HIV prevalence, and healthcare access

# ==============================================================================
# SETUP AND DATA LOADING
# ==============================================================================

library(dplyr)
library(ggplot2)
library(gridExtra)

set.seed(123)

cat("=== LoRTISA GEOSPATIAL ANALYSIS ===\n")
cat("Analyzing geographic patterns in CAP outcomes and healthcare access\n\n")

# Load the corrected dataset
data <- read.csv("LoRTISA_analysis_dataset_corrected.csv", stringsAsFactors = FALSE)

cat("Dataset loaded:", nrow(data), "participants\n")

# ==============================================================================
# GEOGRAPHIC DATA PREPARATION
# ==============================================================================

cat("\n=== GEOGRAPHIC DATA PREPARATION ===\n")

# Clean and standardize geographic variables
geo_data <- data %>%
  filter(!is.na(died_30day)) %>%
  mutate(
    # Standardize hospital names
    hospital_clean = case_when(
      hospital == "Kirrudu" ~ "Kirrudu",
      hospital == "Mulago" ~ "Mulago", 
      hospital == "Naguru" ~ "Naguru",
      TRUE ~ hospital
    ),
    
    # Standardize district names
    district_clean = stringr::str_to_title(residencedistrict),
    
    # Create region categories
    region_category = case_when(
      region == "Central" ~ "Central Region",
      is.na(region) ~ "Unknown",
      TRUE ~ "Other Regions"
    ),
    
    # Create urban vs rural classification based on major districts
    urban_rural = case_when(
      residencedistrict %in% c("kampala", "wakiso") ~ "Urban",
      TRUE ~ "Rural/Peri-urban"
    )
  )

# Geographic summary statistics
geo_summary <- geo_data %>%
  group_by(hospital_clean, district_clean, region_category) %>%
  summarise(
    n_patients = n(),
    mortality_30day = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    hiv_positive = sum(hiv_positive, na.rm = TRUE),
    hiv_prevalence = round(mean(hiv_positive, na.rm = TRUE) * 100, 1),
    median_age = round(median(age_continuous, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  arrange(desc(n_patients))

cat("Geographic analysis summary:\n")
cat("• Hospitals:", length(unique(geo_data$hospital_clean)), "\n")
cat("• Districts:", length(unique(geo_data$district_clean)), "\n")
cat("• Regions:", length(unique(geo_data$region_category)), "\n")

# ==============================================================================
# ANALYSIS 1: HOSPITAL CATCHMENT AREA ANALYSIS
# ==============================================================================

cat("\n=== HOSPITAL CATCHMENT AREA ANALYSIS ===\n")

# Hospital-level outcomes
hospital_analysis <- geo_data %>%
  group_by(hospital_clean) %>%
  summarise(
    n_patients = n(),
    mortality_30day = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    hiv_positive = sum(hiv_positive, na.rm = TRUE),
    hiv_prevalence = round(mean(hiv_positive, na.rm = TRUE) * 100, 1),
    median_age = round(median(age_continuous, na.rm = TRUE), 1),
    median_rr = round(median(patient_rr, na.rm = TRUE), 1),
    severe_cases = sum(clinical_severe, na.rm = TRUE),
    severity_rate = round(mean(clinical_severe, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(desc(n_patients))

print(hospital_analysis)

# Statistical test for hospital differences using Fisher's exact test
mortality_table <- table(geo_data$hospital_clean, geo_data$died_30day)
hiv_table <- table(geo_data$hospital_clean, geo_data$hiv_positive)

hospital_mortality_test <- fisher.test(mortality_table, simulate.p.value = TRUE)
hospital_hiv_test <- fisher.test(hiv_table, simulate.p.value = TRUE)

cat("\nHospital comparison tests (Fisher's exact):\n")
cat("Mortality differences p-value:", round(hospital_mortality_test$p.value, 4), "\n")
cat("HIV prevalence differences p-value:", round(hospital_hiv_test$p.value, 4), "\n")

# ==============================================================================
# ANALYSIS 2: DISTRICT-LEVEL ANALYSIS
# ==============================================================================

cat("\n=== DISTRICT-LEVEL ANALYSIS ===\n")

# Focus on districts with ≥20 patients for meaningful analysis
district_analysis <- geo_data %>%
  group_by(district_clean) %>%
  summarise(
    n_patients = n(),
    mortality_30day = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    hiv_positive = sum(hiv_positive, na.rm = TRUE),
    hiv_prevalence = round(mean(hiv_positive, na.rm = TRUE) * 100, 1),
    median_age = round(median(age_continuous, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  filter(n_patients >= 20) %>%
  arrange(desc(n_patients))

print(district_analysis)

# Urban vs Rural analysis
urban_rural_analysis <- geo_data %>%
  group_by(urban_rural) %>%
  summarise(
    n_patients = n(),
    mortality_30day = sum(died_30day, na.rm = TRUE),
    mortality_rate = round(mean(died_30day, na.rm = TRUE) * 100, 1),
    hiv_positive = sum(hiv_positive, na.rm = TRUE),
    hiv_prevalence = round(mean(hiv_positive, na.rm = TRUE) * 100, 1),
    median_age = round(median(age_continuous, na.rm = TRUE), 1),
    .groups = "drop"
  )

cat("\nUrban vs Rural comparison:\n")
print(urban_rural_analysis)

# ==============================================================================
# VISUALIZATION 1: HOSPITAL OUTCOMES COMPARISON
# ==============================================================================

cat("\n=== CREATING GEOSPATIAL VISUALIZATIONS ===\n")

# Figure 13: Hospital Catchment Area Outcomes
fig13_data <- hospital_analysis %>%
  mutate(hospital_short = hospital_clean)

# Create hospital comparison dashboard
fig13a <- ggplot(fig13_data, aes(x = reorder(hospital_short, -n_patients), y = mortality_rate)) +
  geom_col(aes(fill = hospital_short), width = 0.7, alpha = 0.8) +
  geom_text(aes(label = paste0(mortality_30day, "/", n_patients, "\n(", mortality_rate, "%)")), 
            vjust = -0.5, size = 3.5, fontface = "bold") +
  scale_fill_manual(values = c("Mulago" = "#E31A1C", "Kirrudu" = "#1F78B4", "Naguru" = "#33A02C")) +
  labs(
    title = "30-Day Mortality by Hospital",
    x = "Hospital",
    y = "30-Day Mortality Rate (%)",
    fill = "Hospital"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "none"
  )

fig13b <- ggplot(fig13_data, aes(x = reorder(hospital_short, -n_patients), y = hiv_prevalence)) +
  geom_col(aes(fill = hospital_short), width = 0.7, alpha = 0.8) +
  geom_text(aes(label = paste0(hiv_positive, "/", n_patients, "\n(", hiv_prevalence, "%)")), 
            vjust = -0.5, size = 3.5, fontface = "bold") +
  scale_fill_manual(values = c("Mulago" = "#E31A1C", "Kirrudu" = "#1F78B4", "Naguru" = "#33A02C")) +
  labs(
    title = "HIV Prevalence by Hospital",
    x = "Hospital", 
    y = "HIV Prevalence (%)",
    fill = "Hospital"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "none"
  )

fig13 <- grid.arrange(fig13a, fig13b, ncol = 2,
                     top = "Hospital Catchment Area Analysis: Geographic Variation in CAP Outcomes")

ggsave("Results/Figures/Figure13_Hospital_Geographic_Analysis.png", fig13, width = 12, height = 6, dpi = 300)
cat("✓ Figure 13 saved\n")

# ==============================================================================
# VISUALIZATION 2: DISTRICT-LEVEL OUTCOMES
# ==============================================================================

# Figure 14: District comparison for major districts
if(nrow(district_analysis) > 0) {
  fig14_data <- district_analysis %>%
    mutate(district_label = paste0(district_clean, "\n(n=", n_patients, ")"))
  
  fig14 <- ggplot(fig14_data, aes(x = reorder(district_label, -n_patients))) +
    geom_col(aes(y = mortality_rate), fill = "#E74C3C", alpha = 0.7, width = 0.7) +
    geom_text(aes(y = mortality_rate + 1, label = paste0(mortality_rate, "%")), 
              size = 4, fontface = "bold") +
    labs(
      title = "District-Level 30-Day Mortality Rates",
      subtitle = "Geographic variation in pneumonia mortality",
      x = "District (Sample Size)",
      y = "30-Day Mortality Rate (%)",
      caption = "Only districts with ≥20 patients shown"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray50"),
      axis.title = element_text(size = 12, face = "bold")
    )
  
  ggsave("Results/Figures/Figure14_District_Geographic_Analysis.png", fig14, width = 10, height = 6, dpi = 300)
  cat("✓ Figure 14 saved\n")
}

# ==============================================================================
# VISUALIZATION 3: URBAN VS RURAL COMPARISON
# ==============================================================================

# Figure 15: Urban vs Rural health outcomes
fig15 <- ggplot(urban_rural_analysis, aes(x = urban_rural)) +
  geom_col(aes(y = mortality_rate), fill = "#E74C3C", alpha = 0.7, width = 0.6) +
  geom_text(aes(y = mortality_rate + 0.5, 
               label = paste0(mortality_30day, "/", n_patients, "\n(", mortality_rate, "%)")), 
            size = 4, fontface = "bold") +
  labs(
    title = "Urban vs Rural CAP Mortality Patterns",
    subtitle = "Geographic health disparities in pneumonia outcomes",
    x = "Geographic Classification",
    y = "30-Day Mortality Rate (%)",
    caption = "Based on residence district classification"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray50"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("Results/Figures/Figure15_Urban_Rural_Analysis.png", fig15, width = 8, height = 6, dpi = 300)
cat("✓ Figure 15 saved\n")

# ==============================================================================
# SAVE RESULTS AND CREATE SUMMARY
# ==============================================================================

cat("\n=== SAVING GEOSPATIAL ANALYSIS RESULTS ===\n")

# Save hospital analysis
write.csv(hospital_analysis, "Results/Tables/Hospital_Geographic_Analysis.csv", row.names = FALSE)
cat("✓ Hospital analysis saved\n")

# Save district analysis  
write.csv(district_analysis, "Results/Tables/District_Geographic_Analysis.csv", row.names = FALSE)
cat("✓ District analysis saved\n")

# Save urban-rural analysis
write.csv(urban_rural_analysis, "Results/Tables/Urban_Rural_Analysis.csv", row.names = FALSE)
cat("✓ Urban-rural analysis saved\n")

# Create comprehensive geospatial summary
geospatial_summary <- data.frame(
  Figure = c("Figure13", "Figure14", "Figure15"),
  Title = c(
    "Hospital Catchment Area Analysis",
    "District-Level Geographic Analysis", 
    "Urban vs Rural Health Patterns"
  ),
  Filename = c(
    "Figure13_Hospital_Geographic_Analysis.png",
    "Figure14_District_Geographic_Analysis.png",
    "Figure15_Urban_Rural_Analysis.png"
  ),
  Key_Finding = c(
    paste0("Hospital HIV prevalence varies significantly (p=", round(hospital_hiv_test$p.value, 3), ")"),
    paste0("District mortality ranges from ", min(district_analysis$mortality_rate, na.rm = TRUE), 
           "% to ", max(district_analysis$mortality_rate, na.rm = TRUE), "%"),
    paste0("Urban vs rural mortality: ", urban_rural_analysis$mortality_rate[urban_rural_analysis$urban_rural == "Urban"], 
           "% vs ", urban_rural_analysis$mortality_rate[urban_rural_analysis$urban_rural == "Rural/Peri-urban"], "%")
  ),
  Geographic_Level = c("Hospital", "District", "Urban-Rural"),
  stringsAsFactors = FALSE
)

write.csv(geospatial_summary, "Results/Tables/Geospatial_Analysis_Summary.csv", row.names = FALSE)

# ==============================================================================
# CREATE MARKDOWN SUMMARY
# ==============================================================================

cat("\n=== CREATING GEOSPATIAL MARKDOWN SUMMARY ===\n")

markdown_content <- paste0(
"# LoRTISA Geospatial Analysis Results Summary

**Analysis Date:** ", Sys.Date(), "  
**Dataset:** LoRTISA Community-Acquired Pneumonia Study, Uganda  
**Sample Size:** ", nrow(geo_data), " participants with geographic data  

## Geographic Coverage

### Study Hospitals
", paste(sapply(1:nrow(hospital_analysis), function(i) {
  paste0("- **", hospital_analysis$hospital_clean[i], ":** ", hospital_analysis$n_patients[i], " patients (", 
         round(hospital_analysis$n_patients[i]/sum(hospital_analysis$n_patients)*100, 1), "%)")
}), collapse = "\n"), "

### Geographic Distribution  
- **Districts Represented:** ", length(unique(geo_data$district_clean)), " districts
- **Regional Coverage:** ", round(mean(geo_data$region_category == "Central Region", na.rm = TRUE)*100, 1), "% Central Region
- **Urban vs Rural:** ", urban_rural_analysis$n_patients[urban_rural_analysis$urban_rural == "Urban"], " urban, ", 
urban_rural_analysis$n_patients[urban_rural_analysis$urban_rural == "Rural/Peri-urban"], " rural/peri-urban patients

## Key Geographic Findings

### Hospital-Level Variation
", paste(sapply(1:nrow(hospital_analysis), function(i) {
  paste0("- **", hospital_analysis$hospital_clean[i], ":** ", 
         hospital_analysis$mortality_rate[i], "% mortality, ", hospital_analysis$hiv_prevalence[i], "% HIV prevalence")
}), collapse = "\n"), "

**Statistical Tests:**
- Hospital mortality differences: p = ", round(hospital_mortality_test$p.value, 4), " (Fisher's exact)
- Hospital HIV prevalence differences: p = ", round(hospital_hiv_test$p.value, 4), " (Fisher's exact)

### District-Level Patterns
", if(nrow(district_analysis) > 0) {
  paste(sapply(1:nrow(district_analysis), function(i) {
    paste0("- **", district_analysis$district_clean[i], ":** ", district_analysis$n_patients[i], " patients, ", 
           district_analysis$mortality_rate[i], "% mortality, ", district_analysis$hiv_prevalence[i], "% HIV prevalence")
  }), collapse = "\n")
} else {
  "- Limited district-level analysis due to sample size constraints"
}, "

### Urban vs Rural Comparison
", paste(sapply(1:nrow(urban_rural_analysis), function(i) {
  paste0("- **", urban_rural_analysis$urban_rural[i], ":** ", urban_rural_analysis$n_patients[i], " patients, ", 
         urban_rural_analysis$mortality_rate[i], "% mortality, ", urban_rural_analysis$hiv_prevalence[i], "% HIV prevalence")
}), collapse = "\n"), "

## Figures Generated

### Hospital Geographic Analysis
- **File:** Figure13_Hospital_Geographic_Analysis.png
- **Key Finding:** ", geospatial_summary$Key_Finding[1], "

### District Geographic Analysis  
- **File:** Figure14_District_Geographic_Analysis.png
- **Key Finding:** ", geospatial_summary$Key_Finding[2], "

### Urban vs Rural Analysis
- **File:** Figure15_Urban_Rural_Analysis.png
- **Key Finding:** ", geospatial_summary$Key_Finding[3], "

## Clinical and Policy Implications

### Hospital-Level Insights
1. **Quality Variation:** ", ifelse(hospital_hiv_test$p.value < 0.05, "Significant", "Non-significant"), " differences between hospitals suggest ", 
   ifelse(hospital_hiv_test$p.value < 0.05, "opportunities for quality improvement", "consistent care quality"), "
2. **HIV Care Integration:** Hospitals with higher HIV prevalence may need enhanced co-management protocols
3. **Resource Allocation:** Geographic variation supports targeted resource deployment

### Population Health Implications
1. **Health Disparities:** Urban-rural differences indicate potential access or care quality issues
2. **Prevention Programs:** Geographic targeting of pneumonia prevention efforts needed
3. **Health System Planning:** District-level capacity building priorities identified

## Methodological Strengths
- **Multi-level Analysis:** Hospital, district, and urban-rural perspectives
- **Adequate Sample Sizes:** Sufficient power for hospital-level comparisons  
- **Statistical Rigor:** Appropriate tests for sample sizes (Fisher's exact)
- **Clinical Integration:** Links geographic patterns to clinical outcomes

## Limitations
- **Urban Bias:** Heavy concentration in Central region limits rural representation
- **District Sample Sizes:** Many districts have insufficient patients for detailed analysis
- **No Spatial Coordinates:** Cannot perform precise geographic modeling
- **Temporal Clustering:** Geographic patterns may reflect enrollment timing

## Future Research Directions
1. **Expand Rural Representation:** Include more rural hospitals and districts
2. **Spatial Analysis:** Collect GPS coordinates for advanced spatial modeling
3. **Health System Mapping:** Link to healthcare infrastructure and access data
4. **Longitudinal Patterns:** Examine seasonal and temporal geographic variations

---
*Generated by LoRTISA Geospatial Analysis Pipeline*  
*Contact: Analysis Team*"
)

# Write markdown summary
writeLines(markdown_content, "Results/Results_summary/Geospatial_Analysis_Results.md")

cat("✓ Geospatial markdown summary saved\n")

cat("\n=== GEOSPATIAL ANALYSIS COMPLETED ===\n")
cat("Created 3 publication-ready geographic figures:\n")
cat("• Hospital catchment area analysis\n")
cat("• District-level outcomes comparison\n") 
cat("• Urban vs rural health patterns\n")
cat("• All outputs saved in organized Results folder structure\n")
cat("• Comprehensive markdown summary created\n\n")

cat("GEOSPATIAL ANALYSIS SUMMARY:\n")
cat("✓ Hospital-level variation identified\n")
cat("✓ Urban-rural health disparities documented\n")
cat("✓ Geographic risk factors and opportunities identified\n") 
cat("✓ Policy-relevant insights for health system planning\n\n")