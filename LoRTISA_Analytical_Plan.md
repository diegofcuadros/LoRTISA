# LoRTISA Study: Comprehensive Analytical Plan
## Community-Acquired Pneumonia in Uganda: Risk Factors, HIV Impact, and Clinical Decision Tools

---

## **EXECUTIVE SUMMARY**

This analytical plan outlines three high-impact research questions using the LoRTISA dataset (N=319) to address critical gaps in community-acquired pneumonia (CAP) management in sub-Saharan Africa. The analyses will produce clinically actionable tools and evidence-based recommendations for resource-limited healthcare settings.

---

## **RESEARCH QUESTION 1: MORTALITY RISK PREDICTION MODEL**
### *"What predicts death in young adults with CAP in Uganda?"*

### **Scientific Rationale & Public Health Significance**
- **Epidemiological Context**: 30-day mortality of 10.7% in young adults (median age 42) represents a substantial burden compared to high-income countries (2-5%)
- **Clinical Gap**: Existing pneumonia severity scores (PSI, CURB-65) developed in Western populations may not perform well in HIV-endemic, malnutrition-prevalent settings
- **Public Health Impact**: Early identification of high-risk patients can optimize resource allocation and reduce preventable deaths

### **Primary Objective**
Develop and validate a mortality risk prediction model using readily available clinical variables at hospital admission.

### **Methodology**

#### **Study Design**
- Prospective cohort analysis with 30-day mortality as primary endpoint
- Split-sample approach: 70% derivation, 30% validation

#### **Outcome Definition**
- **Primary**: All-cause mortality at 30 days (composite of in-hospital + post-discharge deaths)
- **Secondary**: In-hospital mortality, time to death

#### **Candidate Predictors (Evidence-Based Selection)**
1. **Demographics**: Age (continuous), sex
2. **Vital Signs**: 
   - Systolic BP (<90 mmHg - shock indicator)
   - Respiratory rate (>24/min - respiratory distress)
   - SpO2 (<90% - severe hypoxemia)
   - Heart rate (>100 bpm - physiologic stress)
   - Temperature (hypothermia vs fever)
3. **Functional Status**: Clinical score (5-level scale)
4. **Nutritional Status**: BMI categories (<18.5 kg/m²)
5. **Comorbidities**: HIV status, diabetes, TB history
6. **Disease Severity Markers**: Mental status alteration

#### **Statistical Analysis Plan**

##### **Phase 1: Exploratory Data Analysis**
```r
# Missing data assessment
- Multiple imputation for missing values (MICE algorithm)
- Sensitivity analysis comparing complete case vs imputed data

# Univariable screening
- Chi-square/Fisher's exact for categorical variables
- t-test/Mann-Whitney U for continuous variables
- P<0.20 threshold for multivariable inclusion
```

##### **Phase 2: Model Development**
```r
# Multivariable logistic regression
- Backward elimination (p<0.05 retention)
- Interaction testing (HIV×Age, BMI×HIV)
- Linearity assessment for continuous variables (restricted cubic splines)
- Collinearity evaluation (VIF <5)
```

##### **Phase 3: Model Performance & Validation**
```r
# Discrimination
- C-statistic (AUC) with 95% CI
- Integrated Discrimination Improvement (IDI)

# Calibration
- Hosmer-Lemeshow test
- Calibration plots (observed vs predicted)

# Clinical Utility
- Decision curve analysis
- Net reclassification improvement
```

#### **Innovation & Robustness Features**
1. **Bootstrapping**: 1000 bootstrap samples for internal validation
2. **Cross-validation**: 10-fold CV for model stability assessment
3. **Threshold Optimization**: Youden index for optimal probability cutpoint
4. **Subgroup Analysis**: Performance across HIV status, age groups, hospitals

#### **Expected Deliverables**
- Risk prediction equation with regression coefficients
- Nomogram for clinical use
- Performance metrics (sensitivity, specificity, PPV, NPV)
- Risk stratification categories (low/moderate/high risk)

---

## **RESEARCH QUESTION 2: HIV-ASSOCIATED PNEUMONIA OUTCOMES**
### *"How does HIV modify CAP outcomes and what are the implications?"*

### **Scientific Rationale & Public Health Significance**
- **Epidemiological Context**: HIV prevalence of 33.9% in CAP patients vs ~6% in general Ugandan population
- **Knowledge Gap**: Limited data on HIV-specific CAP phenotypes and outcomes in modern ART era
- **Public Health Impact**: Inform HIV-specific CAP management guidelines and resource planning

### **Primary Objectives**
1. Compare clinical presentation, severity, and outcomes between HIV+ and HIV- CAP patients
2. Identify HIV-specific risk factors for poor outcomes
3. Assess effect modification of traditional risk factors by HIV status

### **Methodology**

#### **Study Design**
- Comparative cohort analysis with HIV status as primary exposure
- Propensity score methods to address confounding

#### **Exposure Definition**
- **HIV+**: Documented positive HIV test result
- **HIV-**: Documented negative HIV test result
- **HIV Unknown**: Excluded from primary analysis, included in sensitivity analysis

#### **Outcome Definitions**
- **Primary**: 30-day mortality
- **Secondary**: 
  - In-hospital mortality
  - Length of stay (>7 days)
  - Rehospitalization at 30 days
  - Composite poor outcome (death + rehospitalization)

#### **Comparative Analysis Framework**

##### **Phase 1: Descriptive Comparison**
```r
# Baseline characteristics by HIV status
- Demographics, comorbidities, clinical presentation
- Standardized mean differences (SMD >0.1 meaningful)

# Clinical presentation patterns
- Symptom duration and severity
- Vital sign abnormalities
- Radiological findings (if available)
```

##### **Phase 2: Propensity Score Analysis**
```r
# Propensity score development
- Logistic regression predicting HIV+ status
- Variables: age, sex, BMI, residence, hospital, comorbidities
- C-statistic >0.7 for adequate prediction

# Matching strategy
- 1:1 nearest neighbor matching (caliper = 0.1 SD)
- Covariate balance assessment post-matching
```

##### **Phase 3: Outcome Analysis**
```r
# Crude associations
- Chi-square tests, t-tests for group comparisons
- Kaplan-Meier curves for time-to-event outcomes

# Adjusted analyses
- Multivariable logistic regression
- Propensity score weighted analysis
- Inverse probability weighting (IPW)
```

#### **Effect Modification Analysis**
Test interactions between HIV status and:
- Age (<40 vs ≥40 years)
- Nutritional status (BMI <18.5 vs ≥18.5)
- Clinical severity score
- TB co-infection

#### **Subgroup Analyses**
1. **ART Status** (if data available): ART-naive vs experienced
2. **CD4 Count** (if available): <200 vs ≥200 cells/μL
3. **Co-infections**: TB co-infection analysis

#### **Innovation Features**
1. **Multiple Methods**: Traditional regression + propensity score methods
2. **Causal Inference**: Directed Acyclic Graph (DAG) for confounder identification
3. **Sensitivity Analysis**: E-value calculation for unmeasured confounding

---

## **RESEARCH QUESTION 3: CLINICAL RISK SCORE DEVELOPMENT**
### *"Can we develop a simple risk score for CAP mortality in resource-limited settings?"*

### **Scientific Rationale & Public Health Significance**
- **Clinical Need**: Existing scores (CURB-65, PSI) require laboratory tests often unavailable in resource-limited settings
- **Innovation**: Develop bedside score using only clinical variables
- **Implementation**: Simple integer-based score for frontline healthcare workers

### **Primary Objective**
Develop and validate a simplified clinical risk score using only bedside-available variables to predict 30-day mortality.

### **Methodology**

#### **Score Development Strategy**
Based on successful precedents (CURB-65, qSOFA) using clinical-only variables

#### **Candidate Variables (Bedside Available)**
1. **Age**: ≥65 years (1 point) - but may need Uganda-specific cutoff
2. **Clinical Score**: Severely affected (≥50% bedbound) (1 point)
3. **Vital Signs**:
   - Respiratory rate ≥30/min (1 point)
   - Systolic BP <90 mmHg (1 point)
   - SpO2 <90% (1 point)
4. **HIV Status**: Known HIV+ (1 point)
5. **Nutritional Status**: BMI <16 kg/m² (severe malnutrition) (1 point)

#### **Score Development Process**

##### **Phase 1: Variable Selection**
```r
# Univariable screening
- Select variables with OR ≥2.0 for mortality
- Clinical relevance and availability assessment

# Optimal cutpoints
- Youden index for continuous variables
- Clinical meaningfulness consideration
```

##### **Phase 2: Integer Score Creation**
```r
# Beta coefficient-based scoring
- Divide regression coefficients by smallest coefficient
- Round to nearest integer
- Maximum parsimony (≤7 points total)

# Alternative: Machine learning approach
- Random forest variable importance
- Bootstrap aggregation for stability
```

##### **Phase 3: Score Validation**
```r
# Performance assessment
- C-statistic across score categories
- Risk stratification: Low (0-1), Moderate (2-3), High (4+ points)

# Clinical utility
- Sensitivity/specificity at different cutpoints
- Number needed to evaluate (NNE)
```

#### **Score Validation Framework**

##### **Internal Validation**
- Bootstrap validation (bias-corrected C-statistic)
- Cross-validation performance
- Calibration assessment

##### **Clinical Interpretation**
Risk categories with management implications:
- **Low Risk (0-1 points)**: Outpatient management consideration
- **Moderate Risk (2-3 points)**: Standard inpatient care
- **High Risk (4+ points)**: Intensive monitoring/HDU consideration

#### **Innovation Features**
1. **Context-Specific**: Developed specifically for sub-Saharan African population
2. **Resource-Appropriate**: No laboratory tests required
3. **Implementation Ready**: Simple integer scoring system
4. **Multi-Hospital**: Validated across different hospital settings

---

## **INTEGRATED ANALYTICAL FRAMEWORK**

### **Cross-Cutting Methodological Strengths**

#### **1. Missing Data Strategy**
- Multiple imputation by chained equations (MICE)
- Sensitivity analysis with complete case analysis
- Missing data pattern analysis and reporting

#### **2. Statistical Power Considerations**
```r
# Sample size adequacy
- Events per variable (EPV) ≥10 for logistic regression
- Power calculations for group comparisons
- Effect size estimation and precision
```

#### **3. Bias Minimization**
- Selection bias: Consecutive enrollment assessment
- Information bias: Standardized data collection protocols
- Confounding: Multiple analytical approaches

#### **4. Reproducibility Framework**
- Complete R code documentation
- Transparent reporting following STROBE guidelines
- Data availability statement (de-identified data)

### **Expected Timeline & Deliverables**

#### **Phase 1 (Weeks 1-2): Data Preparation & EDA**
- Complete data cleaning and validation
- Descriptive analysis and missing data assessment
- Preliminary univariable analyses

#### **Phase 2 (Weeks 3-4): Primary Analyses**
- Mortality prediction model development
- HIV-CAP comparative analysis
- Risk score development and validation

#### **Phase 3 (Weeks 5-6): Validation & Interpretation**
- Model validation and performance assessment
- Clinical utility analysis
- Subgroup and sensitivity analyses

#### **Phase 4 (Weeks 7-8): Dissemination Products**
- Manuscript preparation
- Clinical decision tools (nomograms, risk calculators)
- Policy brief for health systems

---

## **PUBLIC HEALTH IMPACT & TRANSLATION**

### **Immediate Impact**
1. **Clinical Decision Support**: Risk stratification tools for frontline providers
2. **Resource Optimization**: Triage protocols for limited ICU/HDU beds
3. **Quality Improvement**: Benchmark mortality rates and risk factors

### **Long-term Impact**
1. **Guideline Development**: Evidence for national CAP management protocols
2. **Training Programs**: Risk assessment tools for healthcare worker education
3. **Research Platform**: Framework for future pneumonia research in Africa

### **Policy Relevance**
1. **Health System Strengthening**: Inform resource allocation and capacity planning
2. **HIV Program Integration**: Optimize HIV-CAP co-management strategies
3. **Global Health**: Contribute to WHO pneumonia management guidelines for LMICs

---

## **CONCLUSION**

This comprehensive analytical plan addresses critical knowledge gaps in CAP management in sub-Saharan Africa through robust, innovative methodologies. The three research questions are designed to produce immediately actionable clinical tools while advancing scientific understanding of pneumonia in HIV-endemic, resource-limited settings. The integration of modern statistical methods with pragmatic clinical considerations ensures both methodological rigor and real-world applicability.

The expected outputs will directly inform clinical practice, health policy, and future research priorities, ultimately contributing to improved pneumonia outcomes in one of the world's most affected regions.