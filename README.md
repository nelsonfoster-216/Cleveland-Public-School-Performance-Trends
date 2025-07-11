# CMSD Data Strategist Assessment

## Cleveland Municipal School District Performance Analysis (2020-2021 to 2022-2023)

**Author**: Nelson Foster  
**Date**: January 2025  
**Purpose**: Complete data analysis and presentation for CMSD Data Strategist Position

---

## Project Overview

This project analyzes Cleveland Municipal School District (CMSD) performance across three school years (2020-2021, 2021-2022, 2022-2023) to identify trends, strengths, weaknesses, and strategic recommendations. The analysis reveals a remarkable district transformation with a 15.5-point Performance Index improvement and 96 schools showing growth.

### Key Findings
- **District Transformation**: +15.5 point Performance Index improvement (39% increase)
- **Widespread Success**: 96 schools improved vs only 4 declined
- **Excellence Examples**: 21 schools consistently perform above 60 PI
- **Strategic Opportunities**: 13 schools below 40 PI need targeted support
- **Enrollment Stability**: ~40,000 students consistently served
- **Attendance Correlation**: Strong -0.62 correlation between chronic absenteeism and performance
- **Digital Redlining Analysis**: Original draft analysis examining the relationship between digital infrastructure access and academic performance in CMSD (sampled in presentation)

---

## Assignment Requirements Compliance

### REQUIREMENT 1: Consolidated Dataset
**Status**: Complete and fully compliant

- **File Formats**: `cmsd_consolidated_final.csv` and `cmsd_consolidated_final.xlsx`
- **Required Columns**: 
  - `building_name` ✅
  - `building_irn` ✅
  - `school_year` ✅
  - `enrollment` (numeric) ✅
  - `value_added_composite` (numeric) ✅
  - `performance_index_score` (numeric) ✅
- **Scope**: Cleveland Municipal School District only (IRN 043786) ✅
- **Time Period**: 2020-2021, 2021-2022, 2022-2023 school years ✅
- **Records**: 330 school-year combinations across 112 unique schools ✅

### REQUIREMENT 2: Analysis & Presentation
**Status**: Complete with comprehensive insights

- **Performance Trends**: District-wide improvement analysis ✅
- **Areas of Strength**: Top performers and improvement leaders identified ✅
- **Areas of Weakness**: Schools needing support and intervention priorities ✅
- **Presentation**: 10-15 minute slide deck with professional visualizations ✅
- **Audience**: Accessible to both technical and non-technical stakeholders ✅
- **Supporting Data**: Complete analysis files and code documentation ✅

### REQUIREMENT 3: Code & Documentation
**Status**: Fully reproducible analysis pipeline

- **R Scripts**: Complete data processing and analysis pipeline ✅
- **Documentation**: Comprehensive README and code comments ✅
- **Reproducibility**: All steps documented and automated ✅
- **Quality Assurance**: Multi-stage validation and error handling ✅

---

## Prerequisites & Dependencies

### System Requirements
- **R**: Version 4.0+ (tested with R 4.3.0)
- **RStudio**: Recommended for development
- **Git**: For version control (optional)
- **Pandoc**: For R Markdown rendering (usually included with RStudio)

### Required R Packages
```r
# Data manipulation and processing
tidyverse, readxl, writexl, janitor

# Analysis and statistics  
corrplot, scales

# Visualization
ggplot2, patchwork, RColorBrewer, ggtext, plotly

# R Markdown and reporting
rmarkdown, knitr, kableExtra, DT

# Additional utilities
here
```

### Installation
```r
# Method 1: Automated Installation
source("setup_dependencies.R")

# Method 2: Manual Installation
install.packages(c("tidyverse", "readxl", "writexl", "janitor", "corrplot", 
                  "scales", "patchwork", "RColorBrewer", "ggtext", "plotly",
                  "rmarkdown", "knitr", "kableExtra", "DT", "here"))
```

---

## Complete Project Structure

```
CMSD_Data_Skills_Assessment/
├── README.md                             # This comprehensive documentation
├── README_Analysis.md                    # R Markdown specific documentation  
├── cmsd_mcp_refined-2.md                # Project planning document
├── setup_dependencies.R                 # Package installation script
├── run_full_analysis.R                  # Complete analysis pipeline
│
├── report_card_data/                    # Raw Ohio DOE data files
│   ├── building_overview/               # Enrollment data (4 files)
│   │   ├── BUILDING_HIGH_LEVEL_2021.xlsx
│   │   ├── BUILDING_HIGH_LEVEL_2122.xlsx
│   │   ├── BUILDING_HIGH_LEVEL_2223.xlsx
│   │   └── BUILDING_HIGH_LEVEL_2324.xlsx
│   ├── building_details/                # School details (3 files)
│   │   ├── 2023_Building_Details.xlsx
│   │   ├── 2024_Building_Details.xlsx
│   │   └── 2122_Building_Details.xlsx
│   ├── building_achievement_ratings/    # Performance Index data (3 files)
│   │   ├── 20-21_Achievement_Building.xlsx
│   │   ├── 21-22_Achievement_Building.xlsx
│   │   └── 22-23_Achievement_Building.xlsx
│   └── building_value_added_data/       # Value-added scores (3 files)
│       ├── 2021_VA_ORG_DETAILS.xlsx
│       ├── 2122_VA_ORG_DETAILS.xlsx
│       └── 2223_VA_ORG_DETAILS.xlsx
│
├── R/                                   # Analysis scripts (11 files)
│   ├── 01_data_processing.R             # Data consolidation and cleaning
│   ├── 02_analysis.R                    # Statistical analysis and insights
│   ├── 03_visualizations.R              # Standard visualizations
│   ├── 04_bbc_style_visualizations.R    # BBC-style advanced visualizations
│   ├── 05_bbc_dashboard.R               # Comprehensive dashboards
│   ├── 06_top_performers_visualization.R # Top performers analysis
│   ├── 07_transformation_infographic.R  # District transformation charts
│   ├── 08_slope_chart_standalone.R      # Slope chart for before/after
│   ├── 09_attendance_performance_analysis.R # Attendance correlation analysis
│   ├── 10_cmsd_attendance_analysis.R    # Comprehensive attendance study
│   └── 11_attendance_dashboard.R        # Attendance dashboards
│
├── data/                                # Processed datasets
│   ├── processed/                       # Final analysis-ready data
│   │   ├── cmsd_consolidated_final.csv  # MAIN DELIVERABLE (CSV)
│   │   ├── cmsd_consolidated_final.xlsx # MAIN DELIVERABLE (Excel)
│   │   └── cmsd_summary_stats.csv       # Summary statistics
│   └── validation/                      # Data quality checks
│
├── analysis/                           # Analysis outputs (11 files)
│   ├── district_performance_trends.csv  # District-level trends
│   ├── top_performers_2023.csv          # Highest performing schools
│   ├── most_improved_schools.csv        # Schools with greatest improvement
│   ├── struggling_schools_2023.csv      # Schools requiring support
│   ├── consistent_high_performers.csv   # Consistently excellent schools
│   ├── consistently_low_performers.csv  # Schools needing intensive support
│   ├── declining_schools.csv            # Schools with declining performance
│   ├── value_added_analysis.csv         # Value-added performance analysis
│   ├── school_size_analysis.csv         # Performance by school size
│   ├── attendance_analysis_summary.csv  # Attendance correlation summary
│   └── key_insights_summary.txt         # Executive summary of findings
│
├── presentation/                        # Presentation materials
│   ├── cmsd_performance_analysis.qmd    # Quarto presentation
│   ├── cmsd_performance_analysis.html   # HTML presentation
│   ├── BBC_Visualizations_Guide.md     # Visualization methodology
│   ├── assets/                         # Standard visualizations (17 files)
│   │   ├── 01_district_performance_trends.png
│   │   ├── 02_enrollment_trends.png
│   │   ├── 03_top_performers.png
│   │   ├── 04_most_improved.png
│   │   ├── 05_struggling_schools.png
│   │   ├── 06_performance_distribution.png
│   │   ├── 07_value_added_relationship.png
│   │   ├── 08_size_performance.png
│   │   ├── 09_key_metrics.png
│   │   ├── 09_key_metrics_corrected.png
│   │   ├── 10_strengths_weaknesses.png
│   │   ├── 11_trends_overview.png
│   │   ├── attendance_performance_2023.png
│   │   ├── attendance_performance_2122.png
│   │   ├── chronic_absenteeism_performance_2023.png
│   │   ├── chronic_absenteeism_performance_2122.png
│   │   └── chronic_absenteeism_combined_trends.png
│   └── bbc_assets/                     # BBC-style visualizations (23 files)
│       ├── 00_comprehensive_dashboard.png
│       ├── 00_presentation_dashboard.png
│       ├── 01_district_transformation.png
│       ├── 02_value_added_success.png
│       ├── 03_schools_of_excellence.png
│       ├── 04_improvement_champions.png
│       ├── 05_enrollment_stability.png
│       ├── 06_schools_requiring_support.png
│       ├── 07_middle_performers_improvement.png
│       ├── attendance_comprehensive_dashboard.png
│       ├── attendance_main_correlation.png
│       ├── attendance_quartile_analysis.png
│       ├── attendance_year_over_year.png
│       └── [10+ additional specialized charts]
│
├── digital_redlining_sample/           # Original draft analysis sample
│   └── digital_redlining_eda_consolidated.html # Digital redlining and academic performance analysis
│
├── CMSD_Analysis_Report.Rmd            # MAIN DELIVERABLE - Comprehensive R Markdown Report
├── CMSD_Analysis_Report.html           # HTML Report Output
└── Rplots.pdf                         # Default R plots output
```

---

## How to Reproduce This Analysis

### Quick Start (Recommended)
```bash
# 1. Clone or download the project
cd CMSD_Data_Skills_Assessment

# 2. Install dependencies
Rscript setup_dependencies.R

# 3. Run complete analysis pipeline
Rscript run_full_analysis.R

# 4. Generate comprehensive report
Rscript -e "rmarkdown::render('CMSD_Analysis_Report.Rmd')"
```

### Step-by-Step Execution
```bash
# 1. Install packages
source("setup_dependencies.R")

# 2. Run analysis components individually
source("R/01_data_processing.R")    # Creates consolidated dataset
source("R/02_analysis.R")           # Generates insights
source("R/03_visualizations.R")     # Creates standard charts

# 3. Optional: Generate additional visualizations
source("R/04_bbc_style_visualizations.R")  # BBC-style charts
source("R/05_bbc_dashboard.R")             # Comprehensive dashboards
source("R/10_cmsd_attendance_analysis.R")  # Attendance analysis

# 4. Generate R Markdown report
rmarkdown::render("CMSD_Analysis_Report.Rmd")
```

### Advanced Options
```r
# Generate specific visualization sets
source("R/06_top_performers_visualization.R")    # Top performers deep dive
source("R/07_transformation_infographic.R")      # District transformation
source("R/08_slope_chart_standalone.R")          # Before/after comparison
source("R/11_attendance_dashboard.R")            # Attendance dashboards
```

---

## Key Analysis Components

### 1. Data Processing (`R/01_data_processing.R`)
**Purpose**: Consolidates raw Ohio DOE data into analysis-ready format
- Loads 10 Excel files from 4 data sources
- Standardizes column names and data types
- Filters for CMSD schools only (IRN 043786)
- Creates comprehensive dataset with 330 school-year records
- Validates data quality and completeness
- Exports final datasets in CSV and Excel formats

### 2. Statistical Analysis (`R/02_analysis.R`)
**Purpose**: Generates comprehensive performance insights
- Calculates district-wide trends and improvements
- Identifies top performers and struggling schools
- Analyzes improvement patterns and success factors
- Conducts value-added analysis for academic growth
- Examines school size and performance relationships
- Creates detailed comparison tables and summaries

### 3. Visualization Suite (`R/03_visualizations.R`)
**Purpose**: Creates standard professional visualizations
- District performance trends over time
- Enrollment stability analysis
- Top performers and most improved schools
- Performance distribution and correlations
- Value-added relationships and school size analysis
- Saves high-resolution PNG files for presentations

### 4. BBC-Style Visualizations (`R/04_bbc_style_visualizations.R`)
**Purpose**: Advanced data journalism visualizations
- Uses BBC design principles for clear storytelling
- Creates sophisticated multi-metric dashboards
- Implements consistent color schemes and typography
- Generates publication-quality graphics
- Focuses on accessibility and readability

### 5. Attendance Analysis (`R/10_cmsd_attendance_analysis.R`)
**Purpose**: Breakthrough analysis of attendance as leading indicator
- Tests chronic absenteeism correlation with performance (-0.62)
- Develops predictive models for early intervention
- Creates attendance monitoring dashboards
- Provides 6-12 month advance warning system
- Validates attendance-focused intervention strategies

### 6. Comprehensive Dashboards (`R/05_bbc_dashboard.R`, `R/11_attendance_dashboard.R`)
**Purpose**: Executive-level summary visualizations
- Multi-metric performance overviews
- Attendance correlation dashboards
- School comparison matrices
- Strategic intervention targets
- Action plan support visualizations

---

## Key Deliverables & Outputs

### Primary Deliverables
1. **`cmsd_consolidated_final.csv`** - Main dataset (330 records, 8 columns)
2. **`cmsd_consolidated_final.xlsx`** - Excel format for stakeholder access
3. **`CMSD_Analysis_Report.Rmd`** - Comprehensive R Markdown report
4. **`CMSD_Analysis_Report.html`** - Interactive HTML report

### Analysis Outputs (11 files)
- **District Performance Trends** - Year-over-year improvement analysis
- **Top Performers** - Excellence examples and success models
- **Most Improved Schools** - Turnaround success stories
- **Struggling Schools** - Priority intervention targets
- **Value-Added Analysis** - Academic growth beyond expectations
- **School Size Analysis** - Performance optimization insights
- **Attendance Correlation** - Leading indicator analysis

### Visualization Gallery (40+ files)
- **17 Standard Charts** - Core analysis visualizations
- **23 BBC-Style Charts** - Advanced data journalism graphics
- **Attendance Dashboards** - Early warning system visuals
- **Comprehensive Overviews** - Executive summary charts

---

## Data Quality & Validation

### Completeness Assessment
- **Enrollment Data**: 100% complete (330/330 records)
- **Performance Index**: 99.4% complete (328/330 records)
- **Value Added**: 65.8% complete (217/330 records)*
  - *Note: 2020-2021 limited due to COVID-19 impact
- **Attendance Data**: 100% complete for correlation analysis

### Accuracy Verification
- All schools verified as CMSD (IRN 043786)
- School years confirmed as 2020-2021, 2021-2022, 2022-2023
- Numeric formatting validated for all metrics
- Data ranges confirmed within expected bounds
- Cross-referenced with official Ohio DOE publications

### Statistical Reliability
- Correlation analysis significant at p < 0.001 level
- Attendance models explain 47-49% of performance variance
- Sample sizes sufficient for meaningful conclusions
- Outlier detection and validation procedures implemented

---

## Strategic Insights & Recommendations

### Immediate Impact Opportunities
1. **Early Warning System**: Implement chronic absenteeism monitoring (-0.62 correlation)
2. **Targeted Support**: Focus on 13 schools below 40 PI
3. **Success Replication**: Scale Village Preparatory turnaround model
4. **Data-Driven Decisions**: Monthly performance tracking implementation

### Medium-Term Transformation Goals
1. **District PI Target**: Reach 65+ for national competitiveness
2. **Equity Goal**: Eliminate all schools below 40 PI
3. **Recognition Goal**: Establish CMSD as turnaround model
4. **Sustainability Goal**: Build permanent improvement systems

### Long-Term Vision
1. **All Schools Proficient**: 100% schools above 40 PI
2. **Excellence Standard**: 50+ schools above 60 PI
3. **National Model**: Recognized urban district transformation
4. **Sustainable Success**: Embedded improvement culture

---

## Advanced Analysis Features

### Attendance as Leading Indicator
**Breakthrough Finding**: Chronic absenteeism provides 6-12 month advance warning
- **Correlation Strength**: -0.62 to -0.63 across years
- **Predictive Power**: Models explain 47-49% of performance variance
- **Implementation Ready**: Monthly monitoring system designed
- **Intervention Triggers**: Automated alerts for >30% chronic absenteeism

### School Type Stratification
**Future Enhancement**: Separate analysis by school type
- **Elementary Schools**: K-3 literacy focus and age-appropriate metrics
- **Middle Schools**: Transition support and academic preparation
- **High Schools**: Graduation rates and college/career readiness
- **Specialized Schools**: Unique program-specific indicators

### Multi-Metric Dashboards
**Comprehensive Monitoring**: Integration of multiple data sources
- **Performance Index**: Annual accountability measure
- **Value-Added**: Academic growth beyond expectations
- **Attendance**: Leading indicator for early intervention
- **Enrollment**: Stability and capacity planning
- **Demographics**: Equity and resource allocation

### Digital Redlining Analysis Sample
**Original Research Draft**: Exploratory analysis of digital equity and academic performance
- **Location**: `digital_redlining_sample/digital_redlining_eda_consolidated.html`
- **Purpose**: Investigates relationship between digital infrastructure access and CMSD school performance
- **Research Question**: How does digital divide impact educational outcomes in urban districts?
- **Methodology**: Combines broadband access data with school performance metrics
- **Status**: Draft analysis sampled in presentation deck to demonstrate research capabilities
- **Application**: Informs digital equity initiatives and technology resource allocation

---

## Technical Support & Contact

### Getting Help
- **Documentation**: Comprehensive README files and inline code comments
- **Error Messages**: Check R console for specific error details
- **Missing Files**: Verify all data files are in correct directories
- **Package Issues**: Run `setup_dependencies.R` for automated installation

### Common Troubleshooting
```r
# Package installation issues
install.packages("tidyverse", dependencies = TRUE)

# Data file not found
# Ensure you're in the project root directory
getwd()  # Should end with "CMSD_Data_Skills_Assessment"

# R Markdown won't knit
# Check for missing packages and file paths
rmarkdown::render("CMSD_Analysis_Report.Rmd")
```

### Project Verification
```r
# Verify all components are working
source("run_full_analysis.R")

# Check output files
list.files("data/processed/")
list.files("analysis/")  
list.files("presentation/assets/")
```

---

## Business Value Demonstration

### Analytical Excellence
- **Comprehensive Analysis**: 11 R scripts covering every aspect of performance
- **Statistical Rigor**: Correlation analysis, predictive modeling, validation
- **Reproducible Pipeline**: Fully automated from raw data to final report
- **Quality Assurance**: Multi-stage validation and error handling

### Strategic Innovation
- **Early Warning System**: Attendance-based predictive analytics
- **Data Journalism**: BBC-style visualizations for compelling storytelling
- **Actionable Insights**: Specific recommendations with measurable outcomes
- **Scalable Solutions**: Framework applicable to other districts

### Technical Leadership
- **Modern Analytics**: Advanced R programming and statistical methods
- **Visualization Mastery**: 40+ professional charts and dashboards
- **Documentation Standards**: Comprehensive, maintainable code
- **Collaborative Design**: Accessible to both technical and non-technical stakeholders

---

## License & Data Usage

### Data Sources
- **Ohio Department of Education**: School Report Cards (Public Records)
- **Data Period**: 2020-2021, 2021-2022, 2022-2023 school years
- **Scope**: Cleveland Municipal School District (IRN 043786)
- **Usage**: Educational research and policy analysis

### Code License
- **Purpose**: CMSD Data Strategist Assessment
- **Availability**: Educational and research use
- **Attribution**: Nelson Foster, January 2025
- **Contact**: Available for questions and collaboration

### Reproducibility Commitment
- **Complete Pipeline**: All code and data processing steps documented
- **Version Control**: Git-ready for collaborative development
- **Quality Assurance**: Tested and validated analysis procedures
- **Future Updates**: Designed for ongoing monitoring and improvement

---

**Analysis Period**: January 2025  
**Last Updated**: `r Sys.Date()`  
**Total Files**: 100+ analysis components  
**Total Visualizations**: 40+ professional charts  
**Ready for**: Implementation, monitoring, and continuous improvement

*This analysis demonstrates advanced data science capabilities, strategic thinking, and commitment to educational excellence through evidence-based decision making.* 