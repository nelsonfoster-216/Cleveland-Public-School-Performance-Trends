# CMSD Performance Analysis
# Purpose: Generate comprehensive insights for presentation
# Focus: Trends, strengths, weaknesses, and strategic recommendations
# Author: Nelson Foster
# Date: January 2025

# Load required libraries
library(tidyverse)
library(readxl)
library(knitr)
library(DT)
library(corrplot)

# =============================================================================
# STEP 1: Load and Prepare Data
# =============================================================================

cat("===== CMSD PERFORMANCE ANALYSIS =====\n")
cat("Loading consolidated dataset...\n")

# Load consolidated data
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# Basic data overview
cat("Dataset loaded successfully:\n")
cat("- Total records:", nrow(cmsd_data), "\n")
cat("- School years:", paste(unique(cmsd_data$school_year), collapse = ", "), "\n")
cat("- Unique schools:", length(unique(cmsd_data$building_irn)), "\n")

# =============================================================================
# STEP 2: ASSIGNMENT REQUIREMENT - Performance Trends Over Time
# =============================================================================

cat("\n===== ANALYZING PERFORMANCE TRENDS OVER TIME =====\n")

# District-level performance trends
district_trends <- cmsd_data %>%
  group_by(school_year) %>%
  summarise(
    total_schools = n(),
    total_enrollment = sum(enrollment, na.rm = TRUE),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 1),
    avg_value_added = round(mean(value_added_composite, na.rm = TRUE), 2),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    median_performance_index = round(median(performance_index_score, na.rm = TRUE), 1),
    schools_with_enrollment = sum(!is.na(enrollment)),
    schools_with_va = sum(!is.na(value_added_composite)),
    schools_with_pi = sum(!is.na(performance_index_score)),
    .groups = 'drop'
  )

cat("District Performance Trends:\n")
print(district_trends)

# Performance Index trend analysis
pi_trend <- district_trends %>%
  filter(!is.na(avg_performance_index)) %>%
  mutate(
    pi_change = avg_performance_index - lag(avg_performance_index),
    pi_change_percent = round((pi_change / lag(avg_performance_index)) * 100, 1)
  )

cat("\nPerformance Index Trend Analysis:\n")
print(pi_trend)

# =============================================================================
# STEP 3: ASSIGNMENT REQUIREMENT - Areas of Strength
# =============================================================================

cat("\n===== IDENTIFYING AREAS OF STRENGTH =====\n")

# Top performing schools (most recent year)
top_performers_2023 <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(performance_index_score)) %>%
  arrange(desc(performance_index_score)) %>%
  slice_head(n = 10)

cat("Top 10 Performing Schools (2022-2023):\n")
print(top_performers_2023 %>% select(building_name, performance_index_score, enrollment, value_added_composite))

# Schools with consistent high performance (all years)
consistent_performers <- cmsd_data %>%
  filter(!is.na(performance_index_score)) %>%
  group_by(building_name, building_irn) %>%
  summarise(
    years_reported = n(),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    min_performance_index = min(performance_index_score, na.rm = TRUE),
    max_performance_index = max(performance_index_score, na.rm = TRUE),
    performance_stability = round(max_performance_index - min_performance_index, 1),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 0),
    .groups = 'drop'
  ) %>%
  filter(years_reported >= 2, avg_performance_index > 60) %>%
  arrange(desc(avg_performance_index))

cat("\nConsistent High Performers (PI > 60):\n")
print(consistent_performers)

# Schools with improving trends
improving_schools <- cmsd_data %>%
  filter(!is.na(performance_index_score), school_year %in% c("2020-2021", "2022-2023")) %>%
  select(building_name, building_irn, school_year, performance_index_score) %>%
  pivot_wider(names_from = school_year, values_from = performance_index_score) %>%
  mutate(
    improvement = `2022-2023` - `2020-2021`,
    improvement_percent = round((improvement / `2020-2021`) * 100, 1)
  ) %>%
  filter(!is.na(improvement), improvement > 0) %>%
  arrange(desc(improvement))

cat("\nMost Improved Schools (2020-2021 to 2022-2023):\n")
print(improving_schools %>% slice_head(n = 10))

# =============================================================================
# STEP 4: ASSIGNMENT REQUIREMENT - Areas of Weakness
# =============================================================================

cat("\n===== IDENTIFYING AREAS OF WEAKNESS =====\n")

# Lowest performing schools (most recent year)
struggling_schools_2023 <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(performance_index_score)) %>%
  arrange(performance_index_score) %>%
  slice_head(n = 10)

cat("Lowest 10 Performing Schools (2022-2023):\n")
print(struggling_schools_2023 %>% select(building_name, performance_index_score, enrollment, value_added_composite))

# Schools with declining trends
declining_schools <- cmsd_data %>%
  filter(!is.na(performance_index_score), school_year %in% c("2020-2021", "2022-2023")) %>%
  select(building_name, building_irn, school_year, performance_index_score) %>%
  pivot_wider(names_from = school_year, values_from = performance_index_score) %>%
  mutate(
    decline = `2020-2021` - `2022-2023`,
    decline_percent = round((decline / `2020-2021`) * 100, 1)
  ) %>%
  filter(!is.na(decline), decline > 0) %>%
  arrange(desc(decline))

cat("\nSchools with Declining Performance (2020-2021 to 2022-2023):\n")
print(declining_schools %>% slice_head(n = 10))

# Consistently low performers
consistently_low <- cmsd_data %>%
  filter(!is.na(performance_index_score)) %>%
  group_by(building_name, building_irn) %>%
  summarise(
    years_reported = n(),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    max_performance_index = max(performance_index_score, na.rm = TRUE),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 0),
    .groups = 'drop'
  ) %>%
  filter(years_reported >= 2, avg_performance_index < 40) %>%
  arrange(avg_performance_index)

cat("\nConsistently Low Performers (PI < 40):\n")
print(consistently_low)

# =============================================================================
# STEP 5: Value-Added Analysis
# =============================================================================

cat("\n===== VALUE-ADDED ANALYSIS =====\n")

# Value-added performance (2021-2022 and 2022-2023 only)
va_analysis <- cmsd_data %>%
  filter(!is.na(value_added_composite), school_year %in% c("2021-2022", "2022-2023")) %>%
  group_by(building_name, building_irn) %>%
  summarise(
    years_with_va = n(),
    avg_value_added = round(mean(value_added_composite, na.rm = TRUE), 2),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 0),
    .groups = 'drop'
  ) %>%
  mutate(
    va_category = case_when(
      avg_value_added > 5 ~ "High Growth",
      avg_value_added > 0 ~ "Positive Growth",
      avg_value_added > -5 ~ "Expected Growth",
      TRUE ~ "Below Expected"
    )
  )

cat("Value-Added Distribution:\n")
print(va_analysis %>% count(va_category))

# Top value-added schools
top_va_schools <- va_analysis %>%
  filter(years_with_va == 2) %>%
  arrange(desc(avg_value_added)) %>%
  slice_head(n = 10)

cat("\nTop 10 Value-Added Schools:\n")
print(top_va_schools)

# =============================================================================
# STEP 6: School Size Analysis
# =============================================================================

cat("\n===== SCHOOL SIZE ANALYSIS =====\n")

# Performance by school size
size_analysis <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(performance_index_score)) %>%
  mutate(
    size_category = case_when(
      enrollment < 200 ~ "Small (< 200)",
      enrollment < 400 ~ "Medium (200-399)",
      enrollment < 600 ~ "Large (400-599)",
      TRUE ~ "Very Large (600+)"
    )
  ) %>%
  group_by(size_category) %>%
  summarise(
    school_count = n(),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 0),
    avg_value_added = round(mean(value_added_composite, na.rm = TRUE), 2),
    .groups = 'drop'
  )

cat("Performance by School Size (2022-2023):\n")
print(size_analysis)

# =============================================================================
# STEP 7: Correlation Analysis
# =============================================================================

cat("\n===== CORRELATION ANALYSIS =====\n")

# Correlation between metrics
correlation_data <- cmsd_data %>%
  filter(school_year == "2022-2023") %>%
  select(enrollment, value_added_composite, performance_index_score) %>%
  filter(complete.cases(.))

if(nrow(correlation_data) > 0) {
  correlations <- cor(correlation_data, use = "complete.obs")
  cat("Correlation Matrix (2022-2023):\n")
  print(round(correlations, 3))
}

# =============================================================================
# STEP 8: Key Insights Summary
# =============================================================================

cat("\n===== KEY INSIGHTS SUMMARY =====\n")

# Calculate key metrics for insights
total_schools <- length(unique(cmsd_data$building_irn))
pi_improvement <- district_trends$avg_performance_index[district_trends$school_year == "2022-2023"] - 
                  district_trends$avg_performance_index[district_trends$school_year == "2020-2021"]
schools_improving <- nrow(improving_schools)
schools_declining <- nrow(declining_schools)
high_performers <- nrow(consistent_performers)
low_performers <- nrow(consistently_low)

cat("DISTRICT PERFORMANCE OVERVIEW:\n")
cat("- Total CMSD Schools:", total_schools, "\n")
cat("- Performance Index Improvement (2020-21 to 2022-23):", round(pi_improvement, 1), "points\n")
cat("- Schools Improving:", schools_improving, "\n")
cat("- Schools Declining:", schools_declining, "\n")
cat("- Consistent High Performers (PI > 60):", high_performers, "\n")
cat("- Consistent Low Performers (PI < 40):", low_performers, "\n")

# =============================================================================
# STEP 9: Export Analysis Results
# =============================================================================

cat("\n===== EXPORTING ANALYSIS RESULTS =====\n")

# Create analysis directory if it doesn't exist
if (!dir.exists("analysis")) {
  dir.create("analysis", recursive = TRUE)
}

# Export key analysis tables
write_csv(district_trends, "analysis/district_performance_trends.csv")
write_csv(top_performers_2023, "analysis/top_performers_2023.csv")
write_csv(consistent_performers, "analysis/consistent_high_performers.csv")
write_csv(improving_schools, "analysis/most_improved_schools.csv")
write_csv(struggling_schools_2023, "analysis/struggling_schools_2023.csv")
write_csv(declining_schools, "analysis/declining_schools.csv")
write_csv(consistently_low, "analysis/consistently_low_performers.csv")
write_csv(va_analysis, "analysis/value_added_analysis.csv")
write_csv(size_analysis, "analysis/school_size_analysis.csv")

cat("✓ Analysis results exported to analysis/ directory\n")

# Create summary insights document
insights_summary <- list(
  "District Overview" = paste("CMSD operates", total_schools, "schools serving approximately 40,000 students"),
  "Performance Trend" = paste("District performance index improved by", round(pi_improvement, 1), "points from 2020-21 to 2022-23"),
  "Improvement Pattern" = paste(schools_improving, "schools improved while", schools_declining, "schools declined"),
  "High Performers" = paste(high_performers, "schools consistently perform above 60 PI"),
  "Low Performers" = paste(low_performers, "schools consistently perform below 40 PI"),
  "Value Added Impact" = "Schools with positive value-added tend to outperform expectations"
)

# Save insights summary
writeLines(
  c("=== CMSD PERFORMANCE ANALYSIS INSIGHTS ===",
    "",
    sapply(names(insights_summary), function(x) paste(x, ":", insights_summary[[x]])),
    "",
    "=== END INSIGHTS ==="),
  "analysis/key_insights_summary.txt"
)

cat("✓ Key insights summary saved to analysis/key_insights_summary.txt\n")

cat("\n===== ANALYSIS COMPLETE =====\n")
cat("All analysis results ready for presentation development\n") 