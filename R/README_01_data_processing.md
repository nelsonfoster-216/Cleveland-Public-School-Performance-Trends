# Data Processing Script Documentation

## 01_data_processing.R - CMSD Data Consolidation Pipeline

### Overview
This script is the **primary data processing component** of the CMSD Data Strategist Assessment, responsible for transforming raw Ohio Department of Education data into the consolidated dataset required for analysis.

### Purpose
Create a consolidated dataset that meets the exact specifications outlined in the CMSD Data Strategist Assessment:
- **Cleveland Municipal School District only** (District IRN 043786)
- **Three school years**: 2020-2021, 2021-2022, 2022-2023
- **Required columns**: building_name, building_irn, school_year, enrollment, value_added_composite, performance_index_score
- **Numeric formatting** for all quantitative variables
- **Output formats**: CSV and Excel

### Input Data Sources
The script processes **10 Excel files** from the `report_card_data/` directory:

#### Building Overview Files (Enrollment Data)
- `BUILDING_HIGH_LEVEL_2021.xlsx` - 2020-2021 enrollment
- `BUILDING_HIGH_LEVEL_2122.xlsx` - 2021-2022 enrollment  
- `BUILDING_HIGH_LEVEL_2223.xlsx` - 2022-2023 enrollment

#### Value-Added Files (Academic Growth Data)
- `2021_VA_ORG_DETAILS.xlsx` - 2020-2021 value-added scores
- `2122_VA_ORG_DETAILS.xlsx` - 2021-2022 value-added scores
- `2223_VA_ORG_DETAILS.xlsx` - 2022-2023 value-added scores

#### Achievement Files (Performance Index Data)
- `20-21_Achievement_Building.xlsx` - 2020-2021 performance index
- `21-22_Achievement_Building.xlsx` - 2021-2022 performance index
- `22-23_Achievement_Building.xlsx` - 2022-2023 performance index

### Core Functions

#### `process_building_overview(file_path, school_year)`
- **Purpose**: Extract enrollment data from BUILDING_HIGH_LEVEL files
- **Process**: Filters for CMSD schools, standardizes enrollment column
- **Output**: Building name, IRN, school year, enrollment

#### `process_value_added(file_path, school_year)`
- **Purpose**: Extract value-added composite scores from VA_ORG_DETAILS files
- **Process**: Handles different sheet names across years, extracts overall composite
- **Output**: Building IRN, school year, value-added composite

#### `process_achievement(file_path, school_year)`
- **Purpose**: Extract Performance Index scores from Achievement_Building files
- **Process**: Dynamically identifies correct performance index column by year
- **Output**: Building IRN, school year, performance index score

### Data Processing Pipeline

1. **Data Acquisition**: Reads Excel files using specialized functions
2. **Standardization**: Applies consistent column naming and data types
3. **Filtering**: Restricts to CMSD schools only (District IRN 043786)
4. **Integration**: Merges enrollment, value-added, and achievement data
5. **Validation**: Ensures numeric formatting and data quality
6. **Export**: Creates final consolidated dataset in multiple formats

### Output Files

#### Primary Deliverables
- **`data/processed/cmsd_consolidated_final.csv`** - Main dataset (330 records)
- **`data/processed/cmsd_consolidated_final.xlsx`** - Excel format for stakeholders

#### Supporting Files
- **`data/processed/cmsd_summary_stats.csv`** - Summary statistics by year

### Dataset Specifications

**Final Dataset Structure:**
```
Columns: 6
Rows: 330 (school-year combinations)
Schools: 112 unique CMSD schools
Years: 2020-2021, 2021-2022, 2022-2023
```

**Required Columns (per assignment):**
- `building_name` (character)
- `building_irn` (character) 
- `school_year` (character)
- `enrollment` (numeric)
- `value_added_composite` (numeric)
- `performance_index_score` (numeric)

### Data Quality Assurance

**Completeness:**
- Enrollment: 100% complete (330/330 records)
- Performance Index: 99.4% complete (328/330 records)
- Value-Added: 65.8% complete (217/330 records)*
  - *Note: 2020-2021 limited due to COVID-19 impact

**Validation Checks:**
- District IRN verification (043786 only)
- Numeric formatting enforcement
- Data range validation
- Missing data documentation

### Usage Instructions

#### Prerequisites
```r
# Required packages
library(tidyverse)
library(readxl)
library(janitor)
library(writexl)
```

#### Execution
```r
# Run the complete processing pipeline
source("R/01_data_processing.R")

# Verify outputs
list.files("data/processed/")
```

#### Expected Console Output
The script provides detailed logging:
- File processing status
- Record counts by data source
- Quality check results
- Export confirmation

### Error Handling
- **Missing files**: Graceful error handling with informative messages
- **Sheet name variations**: Automatic detection of correct Excel sheets
- **Column name changes**: Dynamic identification of target columns
- **Data type issues**: Automatic numeric conversion with validation

### Technical Notes

**Memory Usage**: Optimized for large datasets with efficient data processing
**File Formats**: Handles Excel files with multiple sheets and varying structures
**Cross-Year Compatibility**: Accommodates Ohio DOE format changes across years
**Reproducibility**: Fully documented with consistent output validation

### Assignment Compliance

This script ensures 100% compliance with the CMSD Data Strategist Assessment requirements:
- ✅ Cleveland Municipal School District only
- ✅ Three specified school years
- ✅ All required columns present
- ✅ Numeric formatting applied
- ✅ CSV and Excel export formats
- ✅ Comprehensive data validation

### Troubleshooting

**Common Issues:**
1. **Missing Excel files**: Verify `report_card_data/` directory structure
2. **Permission errors**: Check file access permissions
3. **Memory issues**: Ensure sufficient RAM for large Excel files
4. **Package errors**: Install required packages using `source("setup_dependencies.R")`

**Verification:**
```r
# Check final output
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")
nrow(cmsd_data)  # Should be 330
ncol(cmsd_data)  # Should be 6
```

---

**Script Author**: Nelson Foster  
**Purpose**: CMSD Data Strategist Assessment  
**Date**: January 2025  
**Status**: Production-ready data processing pipeline 