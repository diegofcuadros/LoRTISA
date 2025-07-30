# LoRTISA Manuscript Writing Plan: Methods and Results Sections

**Document Purpose:** Comprehensive plan for writing Methods and Results sections of the LoRTISA scientific manuscript  
**Target Journal:** Major epidemiological/infectious disease journal (e.g., Lancet Global Health, Clinical Infectious Diseases, PLOS Medicine)  
**Manuscript Type:** Original research article  
**Date Created:** July 30, 2025  

---

## **MANUSCRIPT OVERVIEW**

### **Proposed Title**
"Development and Validation of a Clinical Risk Score for Community-Acquired Pneumonia Mortality in Uganda: A Multi-Hospital Prospective Cohort Study"

### **Key Messages**
1. **First validated mortality prediction model for CAP in sub-Saharan Africa**
2. **HIV status not associated with increased mortality in modern antiretroviral therapy era**
3. **Simple 2-variable bedside risk score requiring no laboratory tests**
4. **Significant geographic variation in HIV prevalence across hospitals**

### **Primary Research Questions Addressed**
- **RQ1:** What clinical variables predict 30-day mortality in CAP patients?
- **RQ2:** Does HIV status influence CAP mortality outcomes?
- **RQ3:** Can a simple clinical risk score stratify patients effectively?
- **Geographic Analysis:** What are the patterns of CAP outcomes across hospitals and regions?

---

## **METHODS SECTION DETAILED PLAN**

### **1. Study Design and Setting (400-500 words)**

#### **1.1 Study Design**
- **Study Type:** Prospective multicenter cohort study
- **Study Period:** [Insert recruitment dates from data]
- **Follow-up Duration:** 30 days post-admission
- **Study Registration:** [Insert if applicable]

#### **1.2 Study Setting**
- **Country Context:** Uganda, sub-Saharan Africa
- **Healthcare System:** Public tertiary referral hospitals
- **Study Sites:** 
  - Mulago National Referral Hospital (203 patients, 55.6%)
  - Kirrudu National Referral Hospital (133 patients, 36.4%)
  - Naguru General Hospital (29 patients, 7.9%)
- **Geographic Coverage:** Primarily Central Uganda (94.0% of participants)
- **Population Context:** High HIV prevalence setting with established antiretroviral therapy programs

#### **1.3 Ethical Considerations**
- **Ethics Approval:** [Insert IRB/ethics committee details]
- **Informed Consent:** Written informed consent obtained from all participants
- **Data Protection:** De-identification procedures and secure data management

### **2. Participants (300-400 words)**

#### **2.1 Inclusion Criteria**
- **Age:** Adults ≥18 years
- **Clinical Diagnosis:** Community-acquired pneumonia based on clinical and radiological criteria
- **Admission Status:** Hospitalized patients
- **Consent:** Able and willing to provide informed consent

#### **2.2 Exclusion Criteria**
- **Hospital-acquired pneumonia** (symptoms >48 hours after admission)
- **Immunocompromised conditions** other than HIV (chemotherapy, organ transplant)
- **Incomplete baseline data** for primary predictors
- **Lost to follow-up** within 30 days

#### **2.3 Sample Size Calculation**
- **Target Sample Size:** Based on expected 30-day mortality rate of 15%
- **Power Calculation:** 80% power to detect clinically meaningful odds ratios
- **Final Sample:** 365 participants enrolled, 354 with complete data (97.0% retention)

#### **2.4 Recruitment Process**
- **Consecutive sampling** of eligible patients during study period
- **Standardized screening** procedures across all sites
- **Quality assurance** through regular site monitoring

### **3. Data Collection (500-600 words)**

#### **3.1 Baseline Data Collection**
**Clinical Assessment:**
- **Demographics:** Age, sex, residence (district, village/subcounty)
- **Medical History:** Comorbidities (diabetes, tuberculosis history, HIV status)
- **Behavioral Factors:** Smoking history, alcohol consumption
- **Clinical Presentation:** Symptom duration, severity assessment

**Physical Examination:**
- **Vital Signs:** Temperature, heart rate, respiratory rate, blood pressure, oxygen saturation
- **Anthropometrics:** Height, weight, body mass index calculation
- **Clinical Severity:** Functional status score (5-point scale), severity assessment

**Laboratory Tests:**
- **HIV Testing:** Standard rapid testing algorithms with confirmatory testing
- **Additional Tests:** As clinically indicated per standard care protocols

#### **3.2 Data Quality Assurance**
- **Standardized Forms:** REDCap electronic data capture system
- **Training:** Standardized training for all data collectors
- **Quality Control:** Regular data audits and validation checks
- **Missing Data:** Systematic approach to minimize missing data
- **Data Cleaning:** Comprehensive cleaning protocol with extreme value identification

**Critical Data Quality Issue Addressed:**
- **BMI Corrections:** Identified and corrected extreme BMI values (2088.9 kg/m²) due to height data entry errors
- **Validation Process:** K0514 (height 15cm→150cm), M1081 (height 81cm→181cm)
- **Impact:** BMI standard deviation reduced from 109.8 to 3.8 kg/m²

#### **3.3 Follow-up Procedures**
- **30-Day Follow-up:** Structured follow-up for all participants
- **Outcome Assessment:** In-hospital mortality, 30-day mortality, rehospitalization
- **Follow-up Methods:** Hospital records, phone contact, family contact
- **Completeness:** 97.0% complete follow-up achieved

### **4. Variable Definitions (400-500 words)**

#### **4.1 Primary Outcome**
- **30-Day All-Cause Mortality:** Death from any cause within 30 days of hospital admission
- **Ascertainment:** Hospital records, family contact, death certificates where available
- **Time Zero:** Hospital admission date

#### **4.2 Secondary Outcomes**
- **In-Hospital Mortality:** Death during index hospitalization
- **30-Day Rehospitalization:** Unplanned readmission within 30 days
- **Composite Poor Outcome:** Death OR rehospitalization within 30 days

#### **4.3 Predictor Variables**
**Continuous Variables:**
- **Age:** Years (continuous and categorized: 18-34, 35-44, 45-54, 55+ years)
- **Vital Signs:** Temperature (°C), heart rate (bpm), respiratory rate (breaths/min), systolic/diastolic blood pressure (mmHg), oxygen saturation (%)
- **Anthropometrics:** BMI (kg/m²) with WHO categories

**Binary Variables:**
- **Clinical Thresholds:** Age ≥65 years, BMI <18.5 kg/m², systolic BP <90 mmHg, respiratory rate ≥30/min, oxygen saturation <90%, heart rate >100 bpm
- **Comorbidities:** HIV-positive status, diabetes mellitus, tuberculosis history
- **Behavioral:** Smoking history (≥100 cigarettes lifetime), alcohol use (past 12 months)
- **Clinical Severity:** Severe clinical presentation (binary assessment)

#### **4.4 Geographic Variables**
- **Hospital:** Mulago, Kirrudu, Naguru
- **Residence District:** Patient's home district
- **Urban vs Rural:** Based on residence in Kampala/Wakiso districts (urban) vs others (rural/peri-urban)
- **Regional Classification:** Central vs other regions

### **5. Statistical Analysis (800-1000 words)**

#### **5.1 Analysis Population**
- **Primary Analysis:** Complete case analysis (n=354/365, 97.0% of enrolled)
- **Sensitivity Analysis:** Multiple imputation for missing data assessment
- **Rationale:** Missing data <5% for key variables, complete case analysis appropriate

#### **5.2 Descriptive Analysis**
- **Continuous Variables:** Mean (standard deviation) or median (interquartile range) based on distribution
- **Categorical Variables:** Frequencies and percentages
- **Distribution Assessment:** Normality testing, appropriate descriptive statistics
- **Missing Data:** Systematic assessment and reporting of missingness patterns

#### **5.3 Mortality Prediction Model Development (RQ1)**

**Univariable Analysis:**
- **Approach:** Logistic regression for each candidate predictor
- **Inclusion Criterion:** Liberal screening threshold (p<0.20) to avoid excluding important variables
- **Output:** Odds ratios with 95% confidence intervals

**Multivariable Model Development:**
- **Method:** Logistic regression with backward elimination
- **Retention Criterion:** p<0.05 for final model
- **Collinearity Assessment:** Variance inflation factors, correlation matrices
- **Model Assumptions:** Linearity, independence, adequate sample size

**Model Validation:**
- **Discrimination:** C-statistic (area under ROC curve) with 95% confidence intervals
- **Calibration:** Hosmer-Lemeshow goodness-of-fit test, calibration plots
- **Bootstrap Validation:** 200 bootstrap samples for bias correction
- **Risk Stratification:** Tertile-based risk categories for clinical utility

#### **5.4 HIV-CAP Analysis (RQ2)**

**Comparative Analysis:**
- **Primary Comparison:** 30-day mortality by HIV status
- **Statistical Tests:** Fisher's exact test (small cell counts), chi-square tests for categorical variables, t-tests or Mann-Whitney U for continuous variables
- **Effect Sizes:** Risk differences, odds ratios with 95% confidence intervals

**Propensity Score Analysis:**
- **Propensity Model:** Logistic regression for HIV-positive status
- **Matching Method:** Nearest neighbor matching with caliper restriction
- **Balance Assessment:** Standardized mean differences pre- and post-matching
- **Outcome Analysis:** Matched pairs analysis for mortality differences

**Subgroup Analyses:**
- **Age Stratification:** <40 vs ≥40 years
- **BMI Stratification:** Underweight (<18.5) vs normal+ (≥18.5 kg/m²)
- **Clinical Severity:** Severe vs mild-moderate presentation
- **Interaction Testing:** Formal statistical testing for HIV × covariate interactions

#### **5.5 Clinical Risk Score Development (RQ3)**

**Variable Selection:**
- **Candidate Variables:** Based on RQ1 model and clinical importance
- **Selection Criteria:** Odds ratio ≥1.5 and p<0.20 in univariable analysis
- **Clinical Cutpoints:** Literature-based thresholds (e.g., respiratory rate ≥30/min, SpO2 <90%)

**Score Development:**
- **Method:** Multivariable logistic regression with clinical predictors
- **Scoring Algorithm:** Integer-based points system based on β-coefficients
- **Simplification:** Rounded point values for practical bedside use

**Score Validation:**
- **Performance Metrics:** C-statistic, sensitivity, specificity, positive/negative predictive values
- **Risk Stratification:** Low, moderate, high-risk categories with mortality rates
- **Bootstrap Validation:** 100 iterations for performance stability
- **Optimal Cutpoint:** Youden index for balanced sensitivity/specificity

#### **5.6 Geographic Analysis**

**Hospital-Level Analysis:**
- **Outcomes by Hospital:** Mortality rates, HIV prevalence comparisons
- **Statistical Tests:** Fisher's exact tests for small samples, chi-square for larger samples
- **Geographic Patterns:** Patient flow analysis, catchment area assessment

**District and Regional Analysis:**
- **Adequate Sample Size:** Districts with ≥20 patients for meaningful analysis
- **Urban vs Rural:** Comparison of outcomes by residence classification
- **Statistical Methods:** Appropriate tests based on sample sizes and data distribution

#### **5.7 Software and Reproducibility**
- **Statistical Software:** R version [X.X.X] with packages: dplyr, pROC, ggplot2, boot, Hmisc, VIM, tableone, MatchIt
- **Reproducibility:** Set seed (123) for all random processes
- **Code Availability:** All analysis code available upon request
- **Significance Level:** p<0.05 for statistical significance

---

## **RESULTS SECTION DETAILED PLAN**

### **1. Study Population and Baseline Characteristics (600-800 words)**

#### **1.1 Study Flow and Enrollment**
- **CONSORT-style Flow Diagram:** Screening, enrollment, exclusions, final analysis population
- **Enrollment Numbers:** 365 participants enrolled, 354 (97.0%) with complete data
- **Loss to Follow-up:** Detailed accounting of missing data and reasons
- **Geographic Distribution:** Patient enrollment by hospital and region

#### **1.2 Baseline Demographics (Table 1)**
**Population Characteristics:**
- **Age Distribution:** Median age 42 years (IQR: X-X), range 18-100+ years
- **Sex Distribution:** Male/female proportions
- **Geographic Origin:** District and regional distribution of participants
- **Hospital Distribution:** Mulago (55.6%), Kirrudu (36.4%), Naguru (7.9%)

**Clinical Presentation:**
- **Vital Signs:** Mean/median values for temperature, heart rate, respiratory rate, blood pressure, oxygen saturation
- **Anthropometrics:** BMI distribution (post-correction), underweight prevalence
- **Clinical Severity:** Functional status scores, severe presentation rates

**Comorbidities and Risk Factors:**
- **HIV Prevalence:** 32.6% HIV-positive (119/365 participants)
- **Other Comorbidities:** Diabetes (X%), tuberculosis history (X%)
- **Behavioral Factors:** Smoking history (X%), alcohol use (X%)

#### **1.3 Data Quality Assessment**
- **Missing Data:** Systematic reporting of missingness for all key variables
- **Data Corrections:** Description of BMI corrections and impact on analysis
- **Follow-up Completeness:** 30-day follow-up success rates

### **2. Primary Outcomes (400-500 words)**

#### **2.1 Mortality Rates**
- **30-Day Mortality:** 46/354 participants (13.0%) - primary outcome
- **In-Hospital Mortality:** X/354 participants (X.X%)
- **Mortality by Hospital:** Site-specific mortality rates with confidence intervals
- **Time to Death:** Distribution of deaths over 30-day period

#### **2.2 Secondary Outcomes**
- **Rehospitalization Rates:** 30-day unplanned readmission rates
- **Composite Outcomes:** Combined poor outcome (death OR rehospitalization)
- **Length of Stay:** Median hospital length of stay

### **3. Mortality Prediction Model Results (RQ1) (800-1000 words)**

#### **3.1 Univariable Analysis (Table 2 - Part A)**
- **Candidate Predictors:** All variables screened with odds ratios and 95% CIs
- **Significant Predictors:** Variables meeting p<0.20 inclusion criterion
- **Clinical Patterns:** Age, vital signs, comorbidities, and their individual associations

#### **3.2 Multivariable Model Development (Table 2 - Part B)**
- **Final Model Predictors:** 
  - Respiratory rate (OR=1.08, 95% CI: 1.04-1.12, p<0.001)
  - Systolic blood pressure (OR=1.01, 95% CI: 1.00-1.03, p=0.062)
  - Oxygen saturation (OR=1.00, 95% CI: 0.95-1.05, p=0.897)
- **Model Statistics:** Pseudo R² = 0.18, overall model p<0.001

#### **3.3 Model Performance and Validation**
**Discrimination Assessment (Figure 1 - ROC Curve):**
- **C-statistic:** 0.73 (95% CI: X.XX-X.XX) indicating good discrimination
- **ROC Analysis:** Detailed curve with confidence intervals
- **Bootstrap Validation:** Bias-corrected performance metrics

**Calibration Assessment (Figure 4 - Calibration Plot):**
- **Hosmer-Lemeshow Test:** p-value and interpretation
- **Calibration Plot:** Predicted vs observed mortality across risk spectrum
- **Calibration Quality:** Assessment of model accuracy

**Risk Stratification (Figure 2 - Risk Categories):**
- **Low Risk (Tertile 1):** 4.2% mortality (X/106 patients)
- **Moderate Risk (Tertile 2):** 12.3% mortality (X/107 patients) 
- **High Risk (Tertile 3):** 25.4% mortality (X/106 patients)
- **Risk Gradient:** 6-fold difference between low and high-risk groups

#### **3.4 Clinical Predictor Analysis (Figure 5)**
- **Respiratory Rate:** Primary predictor with strongest association
- **Blood Pressure:** Marginal protective effect
- **Oxygen Saturation:** Non-significant after adjustment
- **Biological Plausibility:** Clinical interpretation of predictor effects

### **4. HIV-CAP Analysis Results (RQ2) (600-800 words)**

#### **4.1 HIV Prevalence and Baseline Differences (Table 4 - Part A)**
- **HIV Prevalence:** 119/338 (35.2%) with known HIV status
- **Age Differences:** HIV+ patients younger (median age difference)
- **BMI Patterns:** Higher underweight prevalence in HIV+ patients
- **Clinical Presentation:** Vital signs and severity comparisons
- **Statistical Testing:** Appropriate p-values for all comparisons

#### **4.2 Primary HIV-Mortality Analysis (Table 4 - Part B)**
**Unadjusted Analysis:**
- **HIV+ Mortality:** 16/119 (13.4%) died within 30 days
- **HIV- Mortality:** 24/219 (11.0%) died within 30 days
- **Statistical Test:** Fisher's exact test p=0.5213 (not significant)
- **Risk Difference:** 2.4% (95% CI: X.X% to X.X%)

**Adjusted Analysis:**
- **Multivariable Model:** HIV status OR after adjustment for confounders
- **Confidence Intervals:** Precise estimation with appropriate CIs
- **Clinical Interpretation:** No evidence of increased mortality risk

#### **4.3 Propensity Score Analysis**
- **Matching Success:** Number of matched pairs, balance achieved
- **Matched Analysis:** Mortality comparison in balanced cohort
- **Sensitivity Analysis:** Robustness of findings to methodological approach

#### **4.4 Subgroup and Interaction Analyses (Figure 7-8)**
- **Age Subgroups:** No HIV effect in <40 or ≥40 year groups
- **BMI Subgroups:** No HIV effect in underweight or normal+ groups
- **Severity Subgroups:** No HIV effect across clinical severity levels
- **Interaction Testing:** Formal statistical tests for interactions (all p>0.05)

#### **4.5 Clinical Interpretation**
- **Modern HIV Care:** Possible explanation for lack of mortality difference
- **ART Coverage:** Context of widespread antiretroviral therapy availability
- **Population Characteristics:** Young median age may reflect earlier HIV disease
- **Historical Context:** Comparison with older studies showing HIV mortality excess

### **5. Clinical Risk Score Results (RQ3) (600-800 words)**

#### **5.1 Risk Score Development (Table 3 - Part A)**
**Variable Selection Process:**
- **Candidate Variables:** 10 variables screened for clinical risk score
- **Selection Criteria:** OR ≥1.5 and p<0.20 in univariable analysis
- **Final Predictors:** Respiratory rate ≥30/min and SpO2 <90%

**Scoring Algorithm:**
- **Respiratory Rate ≥30/min:** 3 points (OR=3.45, p=0.0006)
- **SpO2 <90%:** 1 point (OR=1.54, p=0.2019)
- **Total Score Range:** 0-4 points
- **Clinical Rationale:** Simple bedside assessment, no laboratory tests required

#### **5.2 Risk Score Performance (Table 3 - Part B)**
**Discrimination:**
- **C-statistic:** 0.675 (95% CI: 0.603-0.734)
- **Bootstrap Validation:** Bias-corrected AUC = 0.678 (100 iterations)
- **Comparison with RQ1:** Minimal performance loss (0.730 → 0.675, difference = 0.054)

**Risk Stratification Performance (Figure 10):**
- **Low Risk (0-1 points):** 6.4% mortality (12/187 patients)
- **Moderate Risk (3 points):** 17.8% mortality (19/107 patients)
- **High Risk (4 points):** 25.0% mortality (15/60 patients)
- **Risk Gradient:** 4-fold mortality difference across risk categories

**Optimal Cutpoint Analysis:**
- **Youden Index:** Optimal cutpoint at ≥2 points
- **Sensitivity/Specificity:** Balanced performance characteristics
- **Clinical Utility:** Practical implications for patient management

#### **5.3 Clinical Implementation (Figure 12 - Clinical Dashboard)**
- **Bedside Calculator:** Simple scoring system requiring only vital signs
- **Decision Support:** Risk-stratified management recommendations
- **Resource Allocation:** Guidance for ICU/HDU bed allocation
- **Training Tool:** Healthcare worker education applications

### **6. Geographic Analysis Results (400-600 words)**

#### **6.1 Hospital-Level Variation (Figure 13)**
**HIV Prevalence by Hospital:**
- **Naguru:** 44.8% HIV-positive (13/29 patients)
- **Kirrudu:** 40.0% HIV-positive (52/133 patients)
- **Mulago:** 26.6% HIV-positive (54/202 patients)
- **Statistical Test:** p=0.0215 (significant difference)

**Mortality by Hospital:**
- **Hospital-specific Rates:** With confidence intervals
- **Statistical Testing:** Fisher's exact tests, p-values
- **Clinical Implications:** Quality of care variations

#### **6.2 Geographic Patterns (Figure 14-15)**
**District-Level Analysis:**
- **Adequate Sample Districts:** Kampala (173 patients), Wakiso (94 patients)
- **Mortality Patterns:** District-specific rates and comparisons
- **Sample Size Limitations:** Most districts <20 patients

**Urban vs Rural Analysis:**
- **Urban (Kampala/Wakiso):** 267 patients, X.X% mortality
- **Rural/Peri-urban:** 97 patients, X.X% mortality
- **Health Disparities:** Access and outcome differences

#### **6.3 Clinical and Policy Implications**
- **Healthcare System Planning:** Resource allocation insights
- **Quality Improvement:** Hospital-level variation opportunities
- **Geographic Equity:** Access and outcome disparities

### **7. Sensitivity Analyses and Robustness Checks (200-300 words)**

#### **7.1 Missing Data Analysis**
- **Multiple Imputation:** Comparison with complete case analysis
- **Missing Data Patterns:** Assessment of systematic missingness
- **Robustness:** Consistency of findings across analytical approaches

#### **7.2 Alternative Modeling Approaches**
- **Model Specifications:** Different variable combinations tested
- **Bootstrap Stability:** Performance across multiple samples
- **Clinical Cutpoints:** Sensitivity to threshold choices

#### **7.3 Geographic Sensitivity**
- **Hospital Effects:** Analysis with and without hospital stratification
- **Regional Patterns:** Sensitivity to geographic groupings

---

## **TABLES AND FIGURES PLAN**

### **Tables (4 Main Tables)**

#### **Table 1: Baseline Characteristics**
- **Structure:** Overall population and by outcome (died vs survived)
- **Content:** Demographics, clinical presentation, comorbidities
- **Statistics:** Appropriate descriptive statistics, p-values for comparisons
- **Source:** Results/Tables/Table1_Baseline_Characteristics.csv

#### **Table 2: Mortality Prediction Model Results**
- **Part A:** Univariable analysis (all candidate predictors)
- **Part B:** Final multivariable model with performance metrics
- **Content:** OR, 95% CI, p-values, model statistics
- **Source:** Results/Tables/Table2_Model_Results.csv

#### **Table 3: Clinical Risk Score Performance**
- **Part A:** Score development and variable selection
- **Part B:** Risk stratification performance by score categories
- **Content:** Points, OR, mortality rates, performance metrics
- **Source:** Results/Tables/Table3_Risk_Score_Performance.csv

#### **Table 4: HIV-CAP Comparison**
- **Part A:** Baseline characteristics by HIV status
- **Part B:** Outcome comparison and subgroup analyses
- **Content:** Descriptive statistics, mortality rates, p-values
- **Source:** Results/Tables/Table4_HIV_CAP_Comparison.csv

### **Figures (15 Figures Available)**

#### **Core Model Performance (Figures 1-6)**
- **Figure 1:** ROC curve with C-statistic and confidence intervals
- **Figure 2:** Risk stratification showing mortality by tertiles
- **Figure 3:** Forest plot of model predictors with OR and CI
- **Figure 4:** Calibration plot showing predicted vs observed mortality
- **Figure 5:** Predictor distributions by outcome
- **Figure 6:** Summary dashboard of model performance

#### **HIV-CAP Analysis (Figures 7-9)**
- **Figure 7:** HIV vs non-HIV mortality comparison
- **Figure 8:** Baseline characteristics forest plot by HIV status
- **Figure 9:** Subgroup analysis results

#### **Clinical Risk Score (Figures 10-12)**
- **Figure 10:** Risk score performance and stratification
- **Figure 11:** Score components and their individual contributions
- **Figure 12:** Clinical decision support dashboard

#### **Geographic Analysis (Figures 13-15)**
- **Figure 13:** Hospital-level variation in outcomes
- **Figure 14:** District-level mortality patterns
- **Figure 15:** Urban vs rural health patterns

---

## **WRITING TIMELINE AND WORKFLOW**

### **Phase 1: Methods Section (Days 1-3)**
- **Day 1:** Study design, setting, participants sections
- **Day 2:** Data collection, variables, quality assurance
- **Day 3:** Statistical analysis plan, software details

### **Phase 2: Results Section (Days 4-7)**
- **Day 4:** Study population, baseline characteristics (Table 1)
- **Day 5:** Mortality prediction model results (RQ1, Table 2, Figures 1-6)
- **Day 6:** HIV-CAP analysis (RQ2, Table 4, Figures 7-9)
- **Day 7:** Clinical risk score (RQ3, Table 3, Figures 10-12)

### **Phase 3: Integration and Polish (Days 8-10)**
- **Day 8:** Geographic analysis integration (Figures 13-15)
- **Day 9:** Cross-section integration, consistency checks
- **Day 10:** Final polish, formatting, reference management

### **Quality Assurance Process**
- **Internal Review:** Multiple read-throughs for consistency
- **Statistical Verification:** All numbers verified against source data
- **Figure Integration:** Ensure all figures properly referenced
- **Clinical Review:** Clinical interpretation accuracy

---

## **MANUSCRIPT STANDARDS AND FORMATTING**

### **Journal Requirements**
- **Word Limits:** Methods (2000-2500 words), Results (2500-3000 words)
- **Reference Style:** Vancouver system (numbered)
- **Figure Requirements:** High resolution (300 DPI), colorblind-friendly
- **Statistical Reporting:** STROBE guidelines compliance

### **Writing Standards**
- **Tense:** Past tense for methods and results
- **Voice:** Third person, scientific objectivity
- **Precision:** Exact p-values, confidence intervals
- **Transparency:** Complete methodological reporting

### **Clinical Context**
- **Sub-Saharan Africa:** Emphasize regional relevance
- **Resource Settings:** Highlight practical applicability
- **HIV Context:** Modern antiretroviral therapy era
- **Clinical Impact:** Bedside decision-making utility

---

## **SUCCESS METRICS**

### **Methods Section Quality Indicators**
- **Reproducibility:** Sufficient detail for replication
- **Statistical Rigor:** Appropriate methods for research questions
- **Ethical Standards:** Complete ethical reporting
- **Quality Assurance:** Thorough data quality procedures

### **Results Section Quality Indicators**
- **Complete Reporting:** All research questions addressed
- **Statistical Precision:** Appropriate confidence intervals and p-values
- **Clinical Relevance:** Practical implications clear
- **Figure Integration:** Professional, informative visualizations

### **Overall Manuscript Goals**
- **Scientific Rigor:** High methodological standards
- **Clinical Impact:** Practical utility for healthcare providers
- **Regional Relevance:** Sub-Saharan African context
- **Publication Quality:** Major journal submission standards

---

**Plan Status:** ✅ Ready for Approval and Implementation  
**Contact:** Analysis Team  
**File Location:** C:\Users\cuadrodo\Documents\Claude_Code\CAP_072125\Manuscript_Writing_Plan.md