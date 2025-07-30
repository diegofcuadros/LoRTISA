# Claude Code Session Rules for Data Analysis

## Overview
These rules should be reviewed at the beginning of each Claude Code session to ensure optimal workflow for data analysis, particularly for epidemiological and statistical analyses.

---

## 1. Session Initialization
- Load all required libraries at the start
- Set random seed (set.seed(123)) for reproducibility
- Create organized folder structure: `/data`, `/results`, `/figures`
- Display session info for documentation
- **Create `analysis_log.md` file immediately after initialization**

## 2. Data First Principles
- Inspect data immediately upon import (structure, dimensions, types)
- Never modify raw data - create processed copies
- Document all transformations with clear variable names
- Check for and report missing values before any analysis

## 3. Analysis Workflow
- State the objective before writing code
- Break complex tasks into small, testable chunks
- Verify assumptions before applying statistical methods
- Save intermediate results with descriptive names

## 4. Code Standards
- Use consistent, descriptive naming (snake_case for variables)
- Comment the "why", not the "what"
- Create functions for repeated operations
- Include error handling and informative messages

## 5. Visualization Rules
- Always label axes, titles, and legends clearly
- Use colorblind-friendly palettes
- Save plots in both interactive and static formats
- Include sample size and key statistics in plot captions

## 6. Output and Documentation
- Generate summary reports of key findings
- Export results in multiple formats (CSV, RDS, HTML)
- Create a README with session purpose and outcomes
- Flag any warnings or limitations in the analysis

## 7. Best Practices
- Test code on data subsets before full runs
- Ask for clarification rather than making assumptions
- Highlight unexpected results or potential issues
- End sessions with a summary of what was accomplished

## 8. Continuous Narrative Documentation (analysis_log.md)

Maintain a narrative document throughout the session containing:

### Required Sections:

**Header**
- Date and time of analysis
- Session objective
- Initial data sources

**Data Description**
- Detailed description of variables, their meanings, and relationships
- Data types and expected ranges
- Sample size and any exclusion criteria

**File Tracking**
- Input files: names, locations, formats, and content description
- Generated files: purpose, naming convention, and relationships
- Data flow diagram: how files connect in the analysis pipeline

**Analysis Narrative**
- Step-by-step description of methods applied and rationale
- Statistical approaches used and why they were chosen
- Assumptions tested and their outcomes
- Key findings and their interpretation

**Results Summary**
- Main outcomes, effect sizes, and statistical significance
- Tables summarizing key metrics
- References to generated figures and their locations

**Modifications Log**
- Timestamp and rationale for any changes made
- Description of what was modified and why
- Impact on downstream analyses

**File Dependencies**
- Clear mapping of which analyses produced which outputs
- Relationships between intermediate and final results files
- Version tracking for iterative analyses

### Documentation Guidelines:
- Update after EVERY analytical step or file creation
- Write in clear prose suitable for someone reproducing the analysis
- Include cross-references between related files and analyses
- Use consistent terminology throughout
- Explain decisions and assumptions explicitly

---

## Implementation Notes

1. These rules prioritize reproducibility, clarity, and systematic documentation
2. The analysis_log.md serves as a comprehensive record for replication
3. All team members should follow these standards for consistency
4. Review and update these rules based on project needs

---

*Last updated: [Session Date]*