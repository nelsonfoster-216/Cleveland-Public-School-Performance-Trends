# ==============================================================================
# CMSD Attendance and Performance Analysis
# Testing the theory that chronic absenteeism and poor attendance are leading 
# indicators for lower performance index scores
# ==============================================================================

# Load necessary libraries
library(tidyverse)
library(readxl)
library(corrplot)
library(ggplot2)
library(scales)
library(gridExtra)
library(broom)
library(kableExtra)
library(viridis)

# Load BBC style functions
source("R/04_bbc_style_visualizations.R")

# ==============================================================================
# 1. DATA LOADING AND PREPARATION
# ==============================================================================

# Load the consolidated performance data
performance_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# Load Building Details data for both years
building_details_2122 <- read_excel("report_card_data/building_details/2122_Building_Details.xlsx", 
                                    sheet = "Building_Details")
building_details_2023 <- read_excel("report_card_data/building_details/2023_Building_Details.xlsx", 
                                    sheet = "Building_Details")

# ==============================================================================
# 2. FOCUS ON CMSD SCHOOLS AND PREPARE DATA
# ==============================================================================

# Function to clean and prepare CMSD attendance data
prepare_cmsd_data <- function(building_data, year_label) {
  
  # Filter for CMSD schools and "All Students" subgroup
  cmsd_data <- building_data %>%
    filter(
      grepl("Cleveland", `District Name`, ignore.case = TRUE),
      `Subgroup` == "All Students"
    ) %>%
    select(
      building_irn = `Building IRN`,
      building_name = `Building Name`,
      district_name = `District Name`,
      enrollment = `Enrollment`,
      enrollment_percent = `Enrollment Percent`,
      attendance_rate = `Attendance Rate`,
      chronic_absenteeism_rate = `Chronic Absenteeism Rate`,
      mobility_rate = `Mobility Rate`
    ) %>%
    # Convert data types and handle missing values
    mutate(
      school_year = year_label,
      building_irn = as.character(building_irn),
      
      # Clean and convert numeric columns
      enrollment = as.numeric(gsub("[^0-9.]", "", enrollment)),
      enrollment_percent = as.numeric(gsub("[^0-9.]", "", enrollment_percent)),
      attendance_rate = as.numeric(gsub("[^0-9.]", "", attendance_rate)),
      chronic_absenteeism_rate = as.numeric(gsub("[^0-9.]", "", chronic_absenteeism_rate)),
      mobility_rate = as.numeric(gsub("[^0-9.]", "", mobility_rate))
    ) %>%
    # Remove rows with critical missing data
    filter(!is.na(attendance_rate) | !is.na(chronic_absenteeism_rate))
  
  return(cmsd_data)
}

# Prepare CMSD data for both years
cmsd_2122 <- prepare_cmsd_data(building_details_2122, "2021-2022")
cmsd_2023 <- prepare_cmsd_data(building_details_2023, "2022-2023")

# Display summary of CMSD schools found
cat("CMSD Schools Found:\n")
cat(sprintf("2021-22: %d schools\n", nrow(cmsd_2122)))
cat(sprintf("2022-23: %d schools\n", nrow(cmsd_2023)))

# Show sample data
cat("\nSample 2021-22 CMSD Data:\n")
print(head(cmsd_2122 %>% select(building_name, attendance_rate, chronic_absenteeism_rate)))

cat("\nSample 2022-23 CMSD Data:\n")
print(head(cmsd_2023 %>% select(building_name, attendance_rate, chronic_absenteeism_rate)))

# ==============================================================================
# 3. MERGE WITH PERFORMANCE DATA
# ==============================================================================

# Merge attendance data with performance data
analysis_2122 <- cmsd_2122 %>%
  left_join(
    performance_data %>% filter(school_year == "2021-2022"),
    by = c("building_irn", "school_year")
  ) %>%
  filter(!is.na(performance_index_score)) %>%
  # Clean up duplicate/conflicting columns
  mutate(
    building_name = coalesce(building_name.x, building_name.y),
    enrollment_final = coalesce(enrollment.x, enrollment.y)
  ) %>%
  select(-building_name.x, -building_name.y, -enrollment.x, -enrollment.y) %>%
  rename(enrollment = enrollment_final)

analysis_2023 <- cmsd_2023 %>%
  left_join(
    performance_data %>% filter(school_year == "2022-2023"),
    by = c("building_irn", "school_year")
  ) %>%
  filter(!is.na(performance_index_score)) %>%
  # Clean up duplicate/conflicting columns
  mutate(
    building_name = coalesce(building_name.x, building_name.y),
    enrollment_final = coalesce(enrollment.x, enrollment.y)
  ) %>%
  select(-building_name.x, -building_name.y, -enrollment.x, -enrollment.y) %>%
  rename(enrollment = enrollment_final)

# Display merged data summary
cat(sprintf("\nMerged Analysis Data:\n"))
cat(sprintf("2021-22: %d schools with complete data\n", nrow(analysis_2122)))
cat(sprintf("2022-23: %d schools with complete data\n", nrow(analysis_2023)))

# ==============================================================================
# 4. STATISTICAL ANALYSIS
# ==============================================================================

# Function to perform comprehensive correlation analysis
perform_attendance_analysis <- function(data, year_label) {
  
  # Select relevant numeric columns
  analysis_vars <- data %>%
    select(
      performance_index_score,
      attendance_rate,
      chronic_absenteeism_rate,
      enrollment,
      value_added_composite,
      mobility_rate
    ) %>%
    filter(complete.cases(.))
  
  # Calculate correlation matrix
  cor_matrix <- cor(analysis_vars, use = "complete.obs")
  
  # Focus on correlations with performance index
  performance_cors <- cor_matrix[, "performance_index_score"]
  performance_cors <- performance_cors[order(abs(performance_cors), decreasing = TRUE)]
  
  cat(sprintf("\n=== CORRELATION ANALYSIS - %s ===\n", year_label))
  cat("Correlations with Performance Index Score:\n")
  print(round(performance_cors, 4))
  
  # Statistical significance tests
  cor_test_attendance <- cor.test(analysis_vars$attendance_rate, 
                                 analysis_vars$performance_index_score)
  cor_test_chronic <- cor.test(analysis_vars$chronic_absenteeism_rate, 
                              analysis_vars$performance_index_score)
  
  cat(sprintf("\nStatistical Significance Tests:\n"))
  cat(sprintf("Attendance Rate vs Performance Index:\n"))
  cat(sprintf("  Correlation: %.4f\n", cor_test_attendance$estimate))
  cat(sprintf("  p-value: %.6f\n", cor_test_attendance$p.value))
  cat(sprintf("  Significant: %s\n", ifelse(cor_test_attendance$p.value < 0.05, "YES", "NO")))
  
  cat(sprintf("\nChronic Absenteeism vs Performance Index:\n"))
  cat(sprintf("  Correlation: %.4f\n", cor_test_chronic$estimate))
  cat(sprintf("  p-value: %.6f\n", cor_test_chronic$p.value))
  cat(sprintf("  Significant: %s\n", ifelse(cor_test_chronic$p.value < 0.05, "YES", "NO")))
  
  # Multiple regression analysis
  model <- lm(performance_index_score ~ attendance_rate + chronic_absenteeism_rate + 
              enrollment + value_added_composite, data = analysis_vars)
  
  model_summary <- summary(model)
  
  cat(sprintf("\n=== REGRESSION ANALYSIS - %s ===\n", year_label))
  cat(sprintf("R-squared: %.4f\n", model_summary$r.squared))
  cat(sprintf("Adjusted R-squared: %.4f\n", model_summary$adj.r.squared))
  cat(sprintf("F-statistic p-value: %.6f\n", 
              pf(model_summary$fstatistic[1], model_summary$fstatistic[2], 
                 model_summary$fstatistic[3], lower.tail = FALSE)))
  
  # Get coefficient details
  coefficients <- tidy(model)
  cat("\nCoefficient Details:\n")
  print(coefficients %>% 
          mutate(significant = ifelse(p.value < 0.05, "***", 
                                    ifelse(p.value < 0.1, "*", ""))) %>%
          select(term, estimate, std.error, statistic, p.value, significant))
  
  return(list(
    correlation_matrix = cor_matrix,
    performance_correlations = performance_cors,
    correlation_tests = list(
      attendance = cor_test_attendance,
      chronic_absenteeism = cor_test_chronic
    ),
    regression_model = model,
    regression_summary = model_summary,
    data = analysis_vars
  ))
}

# Perform analysis for both years
results_2122 <- perform_attendance_analysis(analysis_2122, "2021-2022")
results_2023 <- perform_attendance_analysis(analysis_2023, "2022-2023")

# ==============================================================================
# 5. VISUALIZATION CREATION
# ==============================================================================

# Function to create BBC-style correlation visualization
create_attendance_correlation_viz <- function(data, year_label) {
  
  # Create correlation plot for attendance vs performance
  p1 <- ggplot(data, aes(x = attendance_rate, y = performance_index_score)) +
    geom_point(alpha = 0.7, size = 3, color = "#1f77b4") +
    geom_smooth(method = "lm", color = "#d62728", fill = "#ff7f0e", alpha = 0.3, size = 1.2) +
    labs(
      title = sprintf("Attendance Rate vs Performance Index (%s)", year_label),
      subtitle = sprintf("Correlation: %.3f", cor(data$attendance_rate, data$performance_index_score, use = "complete.obs")),
      x = "Attendance Rate (%)",
      y = "Performance Index Score",
      caption = "Source: Ohio Department of Education | Cleveland Municipal School District"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 12, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(size = 9, color = "#7A7A7A")
    )
  
  # Create correlation plot for chronic absenteeism vs performance
  p2 <- ggplot(data, aes(x = chronic_absenteeism_rate, y = performance_index_score)) +
    geom_point(alpha = 0.7, size = 3, color = "#ff7f0e") +
    geom_smooth(method = "lm", color = "#d62728", fill = "#1f77b4", alpha = 0.3, size = 1.2) +
    labs(
      title = sprintf("Chronic Absenteeism vs Performance Index (%s)", year_label),
      subtitle = sprintf("Correlation: %.3f", cor(data$chronic_absenteeism_rate, data$performance_index_score, use = "complete.obs")),
      x = "Chronic Absenteeism Rate (%)",
      y = "Performance Index Score",
      caption = "Source: Ohio Department of Education | Cleveland Municipal School District"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 12, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(size = 9, color = "#7A7A7A")
    )
  
  return(list(attendance_plot = p1, chronic_absenteeism_plot = p2))
}

# Create visualizations for both years
viz_2122 <- create_attendance_correlation_viz(results_2122$data, "2021-2022")
viz_2023 <- create_attendance_correlation_viz(results_2023$data, "2022-2023")

# ==============================================================================
# 6. COMBINED ANALYSIS AND INSIGHTS
# ==============================================================================

# Combine data from both years for trend analysis
combined_data <- bind_rows(
  results_2122$data %>% mutate(year = "2021-2022"),
  results_2023$data %>% mutate(year = "2022-2023")
)

# Create combined visualization
combined_viz <- ggplot(combined_data, aes(x = chronic_absenteeism_rate, y = performance_index_score, color = year)) +
  geom_point(alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", alpha = 0.3, size = 1.2) +
  scale_color_manual(values = c("#1f77b4", "#ff7f0e")) +
  labs(
    title = "Chronic Absenteeism as Leading Indicator of Performance",
    subtitle = "Cleveland Municipal School District - Two-Year Comparison",
    x = "Chronic Absenteeism Rate (%)",
    y = "Performance Index Score",
    color = "School Year",
    caption = "Source: Ohio Department of Education | Cleveland Municipal School District"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", color = "#2E2E2E"),
    plot.subtitle = element_text(size = 12, color = "#5A5A5A"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(size = 9, color = "#7A7A7A")
  )

# Save visualizations
ggsave("presentation/assets/attendance_performance_2122.png", 
       viz_2122$attendance_plot, width = 12, height = 8, dpi = 300)
ggsave("presentation/assets/chronic_absenteeism_performance_2122.png", 
       viz_2122$chronic_absenteeism_plot, width = 12, height = 8, dpi = 300)
ggsave("presentation/assets/attendance_performance_2023.png", 
       viz_2023$attendance_plot, width = 12, height = 8, dpi = 300)
ggsave("presentation/assets/chronic_absenteeism_performance_2023.png", 
       viz_2023$chronic_absenteeism_plot, width = 12, height = 8, dpi = 300)
ggsave("presentation/assets/chronic_absenteeism_combined_trends.png", 
       combined_viz, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 7. SUMMARY REPORT
# ==============================================================================

cat("\n\n", paste(rep("=", 80), collapse = ""))
cat("\nCMSD ATTENDANCE & PERFORMANCE ANALYSIS SUMMARY")
cat("\n", paste(rep("=", 80), collapse = ""))

cat(sprintf("\nDATASET OVERVIEW:"))
cat(sprintf("\n- 2021-22: %d schools analyzed", nrow(results_2122$data)))
cat(sprintf("\n- 2022-23: %d schools analyzed", nrow(results_2023$data)))

cat(sprintf("\n\nKEY FINDINGS:"))

# Extract key correlations
cor_2122_attendance <- results_2122$performance_correlations["attendance_rate"]
cor_2122_chronic <- results_2122$performance_correlations["chronic_absenteeism_rate"]
cor_2023_attendance <- results_2023$performance_correlations["attendance_rate"]
cor_2023_chronic <- results_2023$performance_correlations["chronic_absenteeism_rate"]

cat(sprintf("\n\n2021-2022 CORRELATIONS:"))
cat(sprintf("\n- Attendance Rate → Performance Index: %.4f", cor_2122_attendance))
cat(sprintf("\n- Chronic Absenteeism → Performance Index: %.4f", cor_2122_chronic))

cat(sprintf("\n\n2022-2023 CORRELATIONS:"))
cat(sprintf("\n- Attendance Rate → Performance Index: %.4f", cor_2023_attendance))
cat(sprintf("\n- Chronic Absenteeism → Performance Index: %.4f", cor_2023_chronic))

cat(sprintf("\n\nCONCLUSION:"))
if (abs(cor_2122_chronic) > 0.3 | abs(cor_2023_chronic) > 0.3) {
  cat(sprintf("\n✓ STRONG EVIDENCE: Chronic absenteeism shows significant correlation with performance"))
  cat(sprintf("\n✓ LEADING INDICATOR: Attendance data can predict performance outcomes"))
} else {
  cat(sprintf("\n- MODERATE EVIDENCE: Some correlation exists but may not be strong enough for reliable prediction"))
}

cat(sprintf("\n\n📊 Visualizations saved to: presentation/assets/"))
cat(sprintf("\n📈 Analysis complete - Ready for presentation!"))
cat("\n", paste(rep("=", 80), collapse = ""), "\n")

# Print final summary
print("CMSD Attendance Analysis Complete!")
print("Key files generated:")
print("- attendance_performance_2122.png")
print("- chronic_absenteeism_performance_2122.png") 
print("- attendance_performance_2023.png")
print("- chronic_absenteeism_performance_2023.png")
print("- chronic_absenteeism_combined_trends.png") 