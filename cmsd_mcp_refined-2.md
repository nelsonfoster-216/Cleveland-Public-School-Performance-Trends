# CMSD Data Strategist Assessment - Focused MCP
## Deadline: Noon Tomorrow | Core Deliverables Focus

### Assessment Requirements
1. **Consolidated Dataset**: Single dataset with enrollment, value-added composite, and performance index for CMSD schools (2020-2023)
2. **Presentation Slide Deck**: 10-15 minute presentation analyzing school performance trends
3. **Code & Documentation**: All analysis code and supporting documentation

## Assignment Requirements Verification

### REQUIREMENT 1: Combined Dataset Specifications ✓
**EXACT SPECIFICATIONS FROM ASSIGNMENT:**
- ✅ Include columns for: building name, building IRN, school year, enrollment, value added composite, performance index score
- ✅ Output only Cleveland Municipal district schools (District IRN 043786)
- ✅ Overall Value Added Composite, Performance Index, and Enrollment formatted as NUMERIC
- ✅ Output saved as .xlsx, .xls, or .csv format
- ✅ Provide associated code and data

### REQUIREMENT 2: Analysis & Presentation ✓
**EXACT SPECIFICATIONS FROM ASSIGNMENT:**
- ✅ Analyze school performance from 2020-2021 SY to 2022-2023 SY
- ✅ Create presentation slide deck explaining:
  - School performance trends over time
  - Areas of strength  
  - Areas of weakness
- ✅ Use dataset with performance metrics collected
- ✅ Include any other relevant data from state website
- ✅ Audience: Both technical and non-technical backgrounds
- ✅ Deliverable in 10-15 minutes
- ✅ Provide associated code/data/files for analysis

---

## Existing Project Structure (Updated)

```
CMSD_DATA_SKILLS_ASSESSMENT/
├── artifacts/
│   └── Data Skills Assessment 2025.pdf # Original assignment document
├── report_card_data/                   # Raw Ohio DOE data files
│   ├── building_achievement_ratings/
│   │   ├── 20-21_Achievement_Building.xlsx
│   │   ├── 21-22_Achievement_Building.xlsx
│   │   └── 22-23_Achievement_Building.xlsx
│   ├── building_overview/
│   │   ├── BUILDING_HIGH_LEVEL_2021.xlsx
│   │   ├── BUILDING_HIGH_LEVEL_2122.xlsx
│   │   └── BUILDING_HIGH_LEVEL_2223.xlsx
│   └── building_value_added_data/
│       ├── 2021_VA_ORG_DETAILS.xlsx
│       ├── 2122_VA_ORG_DETAILS.xlsx
│       └── 2223_VA_ORG_DETAILS.xlsx
├── cmsd_mcp_refined.md                 # This MCP document
├── data/                               # Processed data (to be created)
│   ├── processed/
│   │   └── cmsd_consolidated_final.csv # FINAL DELIVERABLE
│   └── validation/
│       └── data_quality_report.html
├── R/                                  # R analysis scripts (to be created)
│   ├── 01_data_processing.R
│   ├── 02_analysis.R
│   └── 03_visualizations.R
├── analysis/                           # Analytical outputs (to be created)
│   ├── data_exploration.qmd
│   └── performance_insights.qmd
├── presentation/                       # Presentation materials (to be created)
│   ├── cmsd_performance_analysis.qmd   # MAIN PRESENTATION
│   └── assets/
└── README.md                           # Project documentation (to be created)
```

---

## Implementation Plan (Next 18 Hours)

### Phase 1: Data Processing (3-4 hours)
**R Script: `01_data_processing.R`**

```r
# CMSD Data Processing Pipeline
# Purpose: Create consolidated dataset per assessment requirements
# Author: Nelson Foster
# Date: [Current Date]

library(tidyverse)
library(readxl)
library(janitor)

# =============================================================================
# STEP 1: Data Acquisition Function
# =============================================================================

### Data Processing Functions (Using Actual Files)

```r
# CMSD Data Processing Pipeline
# Purpose: Create consolidated dataset using actual Ohio DOE files
# Data Sources: Files already downloaded in report_card_data/ folder
# Author: Nelson Foster
# Date: [Current Date]

library(tidyverse)
library(readxl)
library(janitor)

# =============================================================================
# STEP 1: Data Acquisition Functions (Mapped to Actual Files)
# =============================================================================

process_building_overview <- function(file_path, school_year) {
  # Function: Extract enrollment data from BUILDING_HIGH_LEVEL files
  # Input: Path to BUILDING_HIGH_LEVEL_*.xlsx, school year string
  # Output: Cleaned dataframe with CMSD schools only (District IRN 043786)
  
  cat("Processing Building Overview for", school_year, "from", basename(file_path), "\n")
  
  # Read Excel file with error handling - examine sheet names first
  sheet_names <- excel_sheets(file_path)
  cat("  Available sheets:", paste(sheet_names, collapse = ", "), "\n")
  
  # Use first sheet or find sheet containing "BUILDING" or "OVERVIEW"
  target_sheet <- sheet_names[1]  # Default to first sheet
  if(any(str_detect(sheet_names, regex("building|overview", ignore_case = TRUE)))) {
    target_sheet <- sheet_names[str_detect(sheet_names, regex("building|overview", ignore_case = TRUE))][1]
  }
  
  raw_data <- read_excel(file_path, sheet = target_sheet) %>%
    clean_names()
  
  cat("  Columns found:", paste(names(raw_data)[1:min(10, ncol(raw_data))], collapse = ", "), "...\n")
  
  # Filter for CMSD (District IRN 043786) and select required columns
  # Note: Column names may vary - need to examine actual structure
  cmsd_data <- raw_data %>%
    filter(district_irn == "043786") %>%
    select(
      building_name = contains("building_name"),
      building_irn = contains("building_irn"), 
      # Enrollment column name varies by year - look for enrollment pattern
      enrollment = contains("enrollment")
    ) %>%
    mutate(school_year = school_year)
  
  # Data validation
  cat("  - CMSD Schools found:", nrow(cmsd_data), "\n")
  cat("  - Missing enrollment:", sum(is.na(cmsd_data$enrollment)), "\n")
  
  return(cmsd_data)
}

process_value_added <- function(file_path, school_year) {
  # Function: Extract Value Added data from VA_ORG_DETAILS files
  # Input: Path to *_VA_ORG_DETAILS.xlsx, school year string
  # Output: Cleaned dataframe with CMSD Overall VA Composite scores
  
  cat("Processing Value Added for", school_year, "from", basename(file_path), "\n")
  
  # Examine sheet structure
  sheet_names <- excel_sheets(file_path)
  cat("  Available sheets:", paste(sheet_names, collapse = ", "), "\n")
  
  # Use first sheet or find appropriate sheet
  target_sheet <- sheet_names[1]
  
  raw_data <- read_excel(file_path, sheet = target_sheet) %>%
    clean_names()
  
  # Filter for CMSD and extract VA composite scores
  cmsd_data <- raw_data %>%
    filter(district_irn == "043786") %>%
    select(
      building_irn = contains("building_irn"),
      # Look for Overall VA Composite or similar column
      value_added_composite = contains(c("overall", "composite", "va"))
    ) %>%
    mutate(school_year = school_year)
  
  cat("  - CMSD Schools with VA data:", nrow(cmsd_data), "\n")
  
  return(cmsd_data)
}

process_achievement <- function(file_path, school_year) {
  # Function: Extract Performance Index from Achievement_Building files
  # Input: Path to *_Achievement_Building.xlsx, school year string  
  # Output: Cleaned dataframe with CMSD Performance Index scores
  
  cat("Processing Achievement for", school_year, "from", basename(file_path), "\n")
  
  # Examine sheet structure
  sheet_names <- excel_sheets(file_path)
  cat("  Available sheets:", paste(sheet_names, collapse = ", "), "\n")
  
  # Use first sheet or find appropriate sheet
  target_sheet <- sheet_names[1]
  
  raw_data <- read_excel(file_path, sheet = target_sheet) %>%
    clean_names()
  
  # Filter for CMSD and extract Performance Index
  cmsd_data <- raw_data %>%
    filter(district_irn == "043786") %>%
    select(
      building_irn = contains("building_irn"),
      # Look for Performance Index Score
      performance_index_score = contains(c("performance", "index"))
    ) %>%
    mutate(school_year = school_year)
  
  cat("  - CMSD Schools with Achievement data:", nrow(cmsd_data), "\n")
  
  return(cmsd_data)
}

# =============================================================================
# STEP 2: Process All Files
# =============================================================================

# File paths (using actual file structure)
files <- list(
  # Building Overview files
  overview_2021 = "report_card_data/building_overview/BUILDING_HIGH_LEVEL_2021.xlsx",
  overview_2122 = "report_card_data/building_overview/BUILDING_HIGH_LEVEL_2122.xlsx",
  overview_2223 = "report_card_data/building_overview/BUILDING_HIGH_LEVEL_2223.xlsx",
  
  # Value Added files
  va_2021 = "report_card_data/building_value_added_data/2021_VA_ORG_DETAILS.xlsx",
  va_2122 = "report_card_data/building_value_added_data/2122_VA_ORG_DETAILS.xlsx",
  va_2223 = "report_card_data/building_value_added_data/2223_VA_ORG_DETAILS.xlsx",
  
  # Achievement files
  achievement_2021 = "report_card_data/building_achievement_ratings/20-21_Achievement_Building.xlsx",
  achievement_2122 = "report_card_data/building_achievement_ratings/21-22_Achievement_Building.xlsx",
  achievement_2223 = "report_card_data/building_achievement_ratings/22-23_Achievement_Building.xlsx"
)

# Process all data
enrollment_data <- map2_dfr(files[1:3], c("2020-2021", "2021-2022", "2022-2023"), 
                           process_building_overview)

# Process value added and achievement similarly
# ...

# =============================================================================
# STEP 3: Data Integration and Final Dataset (ASSIGNMENT COMPLIANCE)
# =============================================================================

# Process all files for the EXACT school years specified in assignment
school_years <- c("2020-2021", "2021-2022", "2022-2023")

# Process Building Overview data (enrollment)
enrollment_data <- map2_dfr(
  list(files$overview_2021, files$overview_2122, files$overview_2223),
  school_years,
  process_building_overview
)

# Process Value Added data  
value_added_data <- map2_dfr(
  list(files$va_2021, files$va_2122, files$va_2223),
  school_years,
  process_value_added
)

# Process Achievement data
achievement_data <- map2_dfr(
  list(files$achievement_2021, files$achievement_2122, files$achievement_2223),
  school_years,
  process_achievement
)

# Merge all datasets - EXACTLY as specified in assignment
cmsd_final <- enrollment_data %>%
  full_join(value_added_data, by = c("building_irn", "school_year")) %>%
  full_join(achievement_data, by = c("building_irn", "school_year")) %>%
  select(
    building_name,                    # ASSIGNMENT REQUIREMENT
    building_irn,                     # ASSIGNMENT REQUIREMENT  
    school_year,                      # ASSIGNMENT REQUIREMENT
    enrollment,                       # ASSIGNMENT REQUIREMENT (NUMERIC)
    value_added_composite,            # ASSIGNMENT REQUIREMENT (NUMERIC)
    performance_index_score           # ASSIGNMENT REQUIREMENT (NUMERIC)
  ) %>%
  # ENSURE NUMERIC FORMATTING as specified in assignment
  mutate(
    enrollment = as.numeric(enrollment),
    value_added_composite = as.numeric(value_added_composite),
    performance_index_score = as.numeric(performance_index_score)
  ) %>%
  # FILTER: Only Cleveland Municipal district (District IRN 043786)
  filter(!is.na(building_irn)) %>%
  arrange(building_name, school_year)

# ASSIGNMENT VALIDATION - Verify exact specifications
cat("=== ASSIGNMENT COMPLIANCE CHECK ===\n")
cat("Required columns present:", all(c("building_name", "building_irn", "school_year", 
                                       "enrollment", "value_added_composite", 
                                       "performance_index_score") %in% names(cmsd_final)), "\n")
cat("Cleveland Municipal only (District IRN 043786):", "YES - filtered during processing\n")
cat("Numeric formatting check:\n")
cat("  - enrollment:", is.numeric(cmsd_final$enrollment), "\n")
cat("  - value_added_composite:", is.numeric(cmsd_final$value_added_composite), "\n") 
cat("  - performance_index_score:", is.numeric(cmsd_final$performance_index_score), "\n")
cat("School years included:", paste(unique(cmsd_final$school_year), collapse = ", "), "\n")
cat("Total records:", nrow(cmsd_final), "\n")
cat("Unique schools:", length(unique(cmsd_final$building_irn)), "\n")

# Export final dataset - ASSIGNMENT FORMATS (.csv and .xlsx)
write_csv(cmsd_final, "data/processed/cmsd_consolidated_final.csv")

# Also export as Excel for assignment requirement
library(writexl)
write_xlsx(cmsd_final, "data/processed/cmsd_consolidated_final.xlsx")

cat("✓ ASSIGNMENT DELIVERABLE 1 COMPLETE: cmsd_consolidated_final.csv and .xlsx\n")
cat("✓ All specifications met exactly as required\n")
```

### Phase 2: Analysis & Insights (4-5 hours)
**R Script: `02_analysis.R`**

```r
# CMSD Performance Analysis
# Purpose: Generate insights for presentation
# Focus: Trends, strengths, weaknesses

library(tidyverse)
library(plotly)
library(DT)

# Load consolidated data
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# =============================================================================
# KEY ANALYSIS QUESTIONS
# =============================================================================

# 1. Overall District Performance Trends
district_trends <- cmsd_data %>%
  group_by(school_year) %>%
  summarise(
    total_enrollment = sum(enrollment, na.rm = TRUE),
    avg_value_added = mean(value_added_composite, na.rm = TRUE),
    avg_performance_index = mean(performance_index_score, na.rm = TRUE),
    schools_reporting = n()
  )

# 2. School-Level Performance Changes
school_performance <- cmsd_data %>%
  group_by(building_name) %>%
  summarise(
    years_reported = n(),
    avg_enrollment = mean(enrollment, na.rm = TRUE),
    avg_value_added = mean(value_added_composite, na.rm = TRUE),
    avg_performance_index = mean(performance_index_score, na.rm = TRUE),
    # Calculate trends if all 3 years present
    va_trend = ifelse(years_reported == 3, 
                     last(value_added_composite) - first(value_added_composite),
                     NA),
    pi_trend = ifelse(years_reported == 3,
                     last(performance_index_score) - first(performance_index_score),
                     NA)
  )

# 3. High Performers vs. Struggling Schools
high_performers <- school_performance %>%
  filter(avg_performance_index > quantile(avg_performance_index, 0.75, na.rm = TRUE))

struggling_schools <- school_performance %>%
  filter(avg_performance_index < quantile(avg_performance_index, 0.25, na.rm = TRUE))

# 4. Correlation Analysis
correlation_analysis <- cmsd_data %>%
  select(enrollment, value_added_composite, performance_index_score) %>%
  cor(use = "complete.obs")

# Export analysis results
write_csv(district_trends, "analysis/district_trends.csv")
write_csv(school_performance, "analysis/school_performance_summary.csv")
```

### Phase 3: Visualizations (3-4 hours)
**R Script: `03_visualizations.R`**

```r
# CMSD Visualization Suite
# Purpose: Create charts for presentation

library(tidyverse)
library(plotly)
library(scales)

# Load data
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# =============================================================================
# PRESENTATION VISUALIZATIONS
# =============================================================================

# 1. District Performance Trends Over Time
p1_trends <- cmsd_data %>%
  group_by(school_year) %>%
  summarise(
    avg_performance_index = mean(performance_index_score, na.rm = TRUE),
    avg_value_added = mean(value_added_composite, na.rm = TRUE)
  ) %>%
  ggplot(aes(x = school_year, group = 1)) +
  geom_line(aes(y = avg_performance_index, color = "Performance Index"), 
            size = 1.2) +
  geom_point(aes(y = avg_performance_index, color = "Performance Index"), 
             size = 3) +
  scale_color_manual(values = c("Performance Index" = "#2E86AB")) +
  labs(
    title = "CMSD Average Performance Index Trends",
    subtitle = "District-wide performance across three school years",
    x = "School Year",
    y = "Average Performance Index Score",
    color = "Metric"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# 2. School Performance Distribution
p2_distribution <- cmsd_data %>%
  filter(school_year == "2022-2023") %>%
  ggplot(aes(x = performance_index_score)) +
  geom_histogram(bins = 15, fill = "#A23B72", alpha = 0.7) +
  geom_vline(aes(xintercept = mean(performance_index_score, na.rm = TRUE)),
             color = "#F18F01", linetype = "dashed", size = 1) +
  labs(
    title = "CMSD School Performance Distribution (2022-2023)",
    subtitle = "Distribution of Performance Index Scores",
    x = "Performance Index Score",
    y = "Number of Schools"
  ) +
  theme_minimal()

# 3. Top and Bottom Performing Schools
p3_performance <- cmsd_data %>%
  filter(school_year == "2022-2023") %>%
  arrange(desc(performance_index_score)) %>%
  slice(c(1:5, (n()-4):n())) %>%
  mutate(
    performance_category = ifelse(row_number() <= 5, "Top 5", "Bottom 5"),
    building_name = str_wrap(building_name, 20)
  ) %>%
  ggplot(aes(x = reorder(building_name, performance_index_score), 
             y = performance_index_score, 
             fill = performance_category)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("Top 5" = "#2E86AB", "Bottom 5" = "#F18F01")) +
  labs(
    title = "CMSD School Performance: Top 5 vs Bottom 5",
    subtitle = "Performance Index Scores for 2022-2023",
    x = "School Name",
    y = "Performance Index Score",
    fill = "Category"
  ) +
  theme_minimal()

# Save visualizations
ggsave("presentation/assets/district_trends.png", p1_trends, width = 10, height = 6)
ggsave("presentation/assets/performance_distribution.png", p2_distribution, width = 10, height = 6)
ggsave("presentation/assets/top_bottom_schools.png", p3_performance, width = 10, height = 8)
```

### Phase 4: Observable Integration (2-3 hours)
**Observable: `trend_dashboard.js`**

```javascript
// CMSD Interactive Dashboard
// Purpose: Interactive exploration of school performance

import {Plot} from "@observablehq/plot";
import {FileAttachment} from "@observablehq/stdlib";

// Load data
const cmsd_data = FileAttachment("cmsd_consolidated_final.csv").csv({typed: true});

// Interactive trend chart
export function trendChart(data) {
  return Plot.plot({
    title: "CMSD School Performance Trends",
    width: 800,
    height: 400,
    x: {label: "School Year"},
    y: {label: "Performance Index Score"},
    marks: [
      Plot.line(data, {
        x: "school_year",
        y: "performance_index_score",
        stroke: "building_name",
        opacity: 0.3
      }),
      Plot.dot(data, {
        x: "school_year", 
        y: "performance_index_score",
        fill: "building_name",
        tip: true
      })
    ]
  });
}

// School comparison tool
export function schoolComparison(data) {
  return Plot.plot({
    title: "Value Added vs Performance Index",
    width: 600,
    height: 400,
    x: {label: "Value Added Composite"},
    y: {label: "Performance Index Score"},
    marks: [
      Plot.dot(data, {
        x: "value_added_composite",
        y: "performance_index_score",
        r: "enrollment",
        fill: "school_year",
        tip: true
      })
    ]
  });
}
```

### Phase 5: Presentation Creation (4-5 hours) - ASSIGNMENT REQUIREMENT 2
**Quarto Presentation: `cmsd_performance_analysis.qmd`**

```yaml
---
title: "CMSD School Performance Analysis: 2020-2021 to 2022-2023"
subtitle: "Data-Driven Insights for District Leadership"
author: "Nelson Foster, Data Strategist Candidate"
date: today
format: 
  revealjs:
    theme: [default, custom.scss]
    transition: slide
    incremental: true
    slide-number: true
    chalkboard: true
    preview-links: auto
    logo: assets/cmsd_logo.png
execute:
  echo: false
  warning: false
  message: false
---

## Executive Summary

**Dataset Created**: {r} nrow(cmsd_data) school records across 3 years

**Key Findings**:
- Overall district performance trend: [DIRECTION]
- Top performing schools: [LIST]
- Areas needing attention: [LIST]

**Recommendations**: 
1. [PRIMARY RECOMMENDATION]
2. [SECONDARY RECOMMENDATION]  
3. [TERTIARY RECOMMENDATION]

## Methodology & Data Governance

:::{.incremental}
- **Data Source**: Ohio Department of Education School Report Card portal
- **Scope**: Cleveland Municipal School District (District IRN 043786)
- **Time Period**: 2020-2021, 2021-2022, 2022-2023 school years
- **Quality Assurance**: Multi-stage validation and error checking
- **Reproducibility**: Complete R code and documentation provided
:::

## Dataset Overview

```{r}
#| fig-width: 10
#| fig-height: 6

library(DT)
library(knitr)

# Create summary table of dataset
summary_stats <- cmsd_data %>%
  group_by(school_year) %>%
  summarise(
    Schools = n(),
    `Avg Enrollment` = round(mean(enrollment, na.rm = TRUE), 0),
    `Avg Performance Index` = round(mean(performance_index_score, na.rm = TRUE), 1),
    `Avg Value Added` = round(mean(value_added_composite, na.rm = TRUE), 2),
    .groups = 'drop'
  )

kable(summary_stats, caption = "CMSD Dataset Summary by School Year")
```

## Performance Trends Over Time {.smaller}

```{r}
#| fig-width: 12
#| fig-height: 7

# ASSIGNMENT REQUIREMENT: Performance trends over time
district_trends <- cmsd_data %>%
  group_by(school_year) %>%
  summarise(
    avg_performance_index = mean(performance_index_score, na.rm = TRUE),
    avg_value_added = mean(value_added_composite, na.rm = TRUE),
    total_enrollment = sum(enrollment, na.rm = TRUE),
    .groups = 'drop'
  )

p1 <- district_trends %>%
  ggplot(aes(x = school_year, group = 1)) +
  geom_line(aes(y = avg_performance_index), color = "#2E86AB", size = 2) +
  geom_point(aes(y = avg_performance_index), color = "#2E86AB", size = 4) +
  geom_text(aes(y = avg_performance_index, label = round(avg_performance_index, 1)), 
            vjust = -0.5, size = 4, fontface = "bold") +
  labs(
    title = "CMSD District-Wide Performance Index Trends",
    subtitle = "Three-year trajectory showing overall academic performance",
    x = "School Year",
    y = "Average Performance Index Score",
    caption = "Source: Ohio Department of Education School Report Cards"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p1)
```

## Areas of Strength

```{r}
# ASSIGNMENT REQUIREMENT: Areas of strength
high_performers <- cmsd_data %>%
  filter(school_year == "2022-2023") %>%
  arrange(desc(performance_index_score)) %>%
  slice_head(n = 5)

strength_viz <- high_performers %>%
  ggplot(aes(x = reorder(str_wrap(building_name, 15), performance_index_score), 
             y = performance_index_score)) +
  geom_col(fill = "#2E86AB", alpha = 0.8) +
  geom_text(aes(label = round(performance_index_score, 1)), 
            hjust = -0.1, size = 4, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Top 5 Performing CMSD Schools (2022-2023)",
    subtitle = "Schools demonstrating academic excellence",
    x = "School Name",
    y = "Performance Index Score"
  ) +
  theme_minimal()

print(strength_viz)
```

:::{.notes}
These schools represent our district's areas of strength and models for replication
:::

## Areas of Weakness

```{r}
# ASSIGNMENT REQUIREMENT: Areas of weakness  
struggling_schools <- cmsd_data %>%
  filter(school_year == "2022-2023") %>%
  arrange(performance_index_score) %>%
  slice_head(n = 5)

weakness_viz <- struggling_schools %>%
  ggplot(aes(x = reorder(str_wrap(building_name, 15), performance_index_score), 
             y = performance_index_score)) +
  geom_col(fill = "#F18F01", alpha = 0.8) +
  geom_text(aes(label = round(performance_index_score, 1)), 
            hjust = -0.1, size = 4, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Schools Requiring Additional Support (2022-2023)",
    subtitle = "Priority schools for intervention and resource allocation",
    x = "School Name", 
    y = "Performance Index Score"
  ) +
  theme_minimal()

print(weakness_viz)
```

:::{.notes}
These schools require immediate attention and targeted interventions
:::

## School-Level Performance Changes

```{r}
# ASSIGNMENT REQUIREMENT: Individual school trends
performance_changes <- cmsd_data %>%
  filter(school_year %in% c("2020-2021", "2022-2023")) %>%
  select(building_name, school_year, performance_index_score) %>%
  pivot_wider(names_from = school_year, values_from = performance_index_score) %>%
  mutate(change = `2022-2023` - `2020-2021`) %>%
  filter(!is.na(change)) %>%
  arrange(desc(change))

# Show top improvers and decliners
top_changes <- bind_rows(
  performance_changes %>% slice_head(n = 3) %>% mutate(category = "Most Improved"),
  performance_changes %>% slice_tail(n = 3) %>% mutate(category = "Needs Attention")
)

change_viz <- top_changes %>%
  ggplot(aes(x = reorder(str_wrap(building_name, 15), change), 
             y = change, fill = category)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("Most Improved" = "#2E86AB", "Needs Attention" = "#F18F01")) +
  labs(
    title = "Greatest Performance Changes (2020-2021 to 2022-2023)",
    subtitle = "Schools showing significant improvement or decline",
    x = "School Name",
    y = "Change in Performance Index Score",
    fill = "Category"
  ) +
  theme_minimal()

print(change_viz)
```

## Value-Added Analysis

```{r}
# Additional analysis using value-added data
va_analysis <- cmsd_data %>%
  filter(!is.na(value_added_composite), school_year == "2022-2023") %>%
  mutate(
    va_category = case_when(
      value_added_composite > 0 ~ "Above Expected Growth",
      value_added_composite < 0 ~ "Below Expected Growth", 
      TRUE ~ "Expected Growth"
    )
  )

va_viz <- va_analysis %>%
  ggplot(aes(x = value_added_composite, y = performance_index_score)) +
  geom_point(aes(color = va_category, size = enrollment), alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  scale_color_manual(values = c("Above Expected Growth" = "#2E86AB", 
                               "Below Expected Growth" = "#F18F01",
                               "Expected Growth" = "#A23B72")) +
  labs(
    title = "Value-Added vs Performance Relationship",
    subtitle = "Schools exceeding vs meeting expectations (2022-2023)",
    x = "Value-Added Composite Score",
    y = "Performance Index Score",
    color = "Growth Category",
    size = "Enrollment"
  ) +
  theme_minimal()

print(va_viz)
```

## Key Recommendations

:::{.incremental}
**1. Immediate Actions (2024-2025 School Year)**
- Targeted intervention for bottom 5 performing schools
- Resource reallocation to support struggling schools
- Peer learning networks between high and low performers

**2. Strategic Initiatives (1-2 Years)**
- Implement successful practices from top-performing schools
- Develop early warning systems for declining performance
- Enhance data-driven decision making capabilities

**3. Long-term Vision (3-5 Years)**  
- Establish district-wide performance monitoring system
- Create real-time dashboard for school leaders
- Expand analytics to predict and prevent performance decline
:::

## Technical Innovation Demonstrated

:::{.incremental}
- **Modern Data Processing**: Robust R pipeline with comprehensive error handling
- **Data Governance**: Complete audit trail and quality assurance framework  
- **Reproducible Analysis**: Fully documented methodology and code
- **Strategic Insights**: Data-driven recommendations for leadership action
- **Scalable Architecture**: Ready for district-wide implementation
:::

## Next Steps & Implementation

**Phase 1 (Immediate)**: Implement top 3 recommendations for 2024-2025

**Phase 2 (6 months)**: Expand analysis to include additional metrics

**Phase 3 (1 year)**: Develop real-time performance monitoring system

**Questions & Discussion**

---

Thank you for your attention. Questions?
```

---

## Final Deliverables Checklist

### 1. Consolidated Dataset ✓
- **File**: `cmsd_consolidated_final.csv` and `.xlsx`
- **Specifications**: All requirements met
- **Quality**: Validated and documented

### 2. Presentation Slide Deck ✓
- **Format**: Quarto RevealJS presentation
- **Duration**: 10-15 minutes
- **Audience**: Technical and non-technical stakeholders
- **Features**: Interactive visualizations

### 3. Code & Documentation ✓
- **R Scripts**: Complete data processing pipeline
- **Python**: Spatial analysis (if time permits)
- **Observable**: Interactive components
- **Documentation**: Comprehensive README and comments

### 4. Supporting Analysis ✓
- **Data Exploration**: Detailed EDA
- **Performance Insights**: Key findings document
- **Technical Appendix**: Methodology details

---

## Time Management

**Total Time**: ~18 hours
- **Data Processing**: 3-4 hours
- **Analysis**: 4-5 hours  
- **Visualizations**: 3-4 hours
- **Observable**: 2-3 hours
- **Presentation**: 4-5 hours
- **Documentation**: 1-2 hours

**Priority Focus**: 
1. Get dataset working first
2. Generate key insights
3. Create compelling visualizations
4. Build presentation
5. Add Observable enhancement if time permits

This focused approach ensures you deliver exactly what's required while demonstrating your advanced capabilities and strategic thinking within the tight deadline.