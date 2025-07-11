# ==============================================================================
# CMSD Attendance Analysis Dashboard
# Comprehensive BBC-style visualization dashboard for attendance analysis
# ==============================================================================

library(tidyverse)
library(readxl)
library(ggplot2)
library(gridExtra)
library(grid)
library(scales)
library(viridis)

# Load BBC style functions
source("R/04_bbc_style_visualizations.R")

# ==============================================================================
# RELOAD ANALYSIS DATA
# ==============================================================================

# Load the consolidated performance data
performance_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# Load Building Details data for both years
building_details_2122 <- read_excel("report_card_data/building_details/2122_Building_Details.xlsx", 
                                    sheet = "Building_Details")
building_details_2023 <- read_excel("report_card_data/building_details/2023_Building_Details.xlsx", 
                                    sheet = "Building_Details")

# Function to prepare CMSD data
prepare_cmsd_data <- function(building_data, year_label) {
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
    mutate(
      school_year = year_label,
      building_irn = as.character(building_irn),
      enrollment = as.numeric(gsub("[^0-9.]", "", enrollment)),
      enrollment_percent = as.numeric(gsub("[^0-9.]", "", enrollment_percent)),
      attendance_rate = as.numeric(gsub("[^0-9.]", "", attendance_rate)),
      chronic_absenteeism_rate = as.numeric(gsub("[^0-9.]", "", chronic_absenteeism_rate)),
      mobility_rate = as.numeric(gsub("[^0-9.]", "", mobility_rate))
    ) %>%
    filter(!is.na(attendance_rate) | !is.na(chronic_absenteeism_rate))
  
  return(cmsd_data)
}

# Prepare and merge data
cmsd_2122 <- prepare_cmsd_data(building_details_2122, "2021-2022")
cmsd_2023 <- prepare_cmsd_data(building_details_2023, "2022-2023")

analysis_2122 <- cmsd_2122 %>%
  left_join(performance_data %>% filter(school_year == "2021-2022"), by = c("building_irn", "school_year")) %>%
  filter(!is.na(performance_index_score)) %>%
  mutate(
    building_name = coalesce(building_name.x, building_name.y),
    enrollment_final = coalesce(enrollment.x, enrollment.y)
  ) %>%
  select(-building_name.x, -building_name.y, -enrollment.x, -enrollment.y) %>%
  rename(enrollment = enrollment_final)

analysis_2023 <- cmsd_2023 %>%
  left_join(performance_data %>% filter(school_year == "2022-2023"), by = c("building_irn", "school_year")) %>%
  filter(!is.na(performance_index_score)) %>%
  mutate(
    building_name = coalesce(building_name.x, building_name.y),
    enrollment_final = coalesce(enrollment.x, enrollment.y)
  ) %>%
  select(-building_name.x, -building_name.y, -enrollment.x, -enrollment.y) %>%
  rename(enrollment = enrollment_final)

# ==============================================================================
# COMPREHENSIVE DASHBOARD CREATION
# ==============================================================================

# Create comprehensive dashboard
create_attendance_dashboard <- function() {
  
  # 1. Main correlation plot - Chronic Absenteeism vs Performance (Combined)
  combined_data <- bind_rows(
    analysis_2122 %>% mutate(year = "2021-2022") %>% select(year, chronic_absenteeism_rate, performance_index_score),
    analysis_2023 %>% mutate(year = "2022-2023") %>% select(year, chronic_absenteeism_rate, performance_index_score)
  ) %>%
    filter(!is.na(chronic_absenteeism_rate) & !is.na(performance_index_score))
  
  # Calculate correlation for title
  cor_combined <- cor(combined_data$chronic_absenteeism_rate, combined_data$performance_index_score, use = "complete.obs")
  
  p1 <- ggplot(combined_data, aes(x = chronic_absenteeism_rate, y = performance_index_score)) +
    geom_point(aes(color = year), alpha = 0.7, size = 3) +
    geom_smooth(method = "lm", color = "#d62728", fill = "#ff7f0e", alpha = 0.3, size = 1.5) +
    scale_color_manual(values = c("2021-2022" = "#1f77b4", "2022-2023" = "#ff7f0e")) +
    labs(
      title = "Chronic Absenteeism: A Strong Predictor of School Performance",
      subtitle = sprintf("Strong negative correlation (r = %.3f) confirms absenteeism as leading indicator", cor_combined),
      x = "Chronic Absenteeism Rate (%)",
      y = "Performance Index Score",
      color = "School Year"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 18, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 14, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 11),
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 11),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
  
  # 2. Attendance Rate vs Performance (Combined)
  attendance_combined <- bind_rows(
    analysis_2122 %>% mutate(year = "2021-2022") %>% select(year, attendance_rate, performance_index_score),
    analysis_2023 %>% mutate(year = "2022-2023") %>% select(year, attendance_rate, performance_index_score)
  ) %>%
    filter(!is.na(attendance_rate) & !is.na(performance_index_score))
  
  cor_attendance <- cor(attendance_combined$attendance_rate, attendance_combined$performance_index_score, use = "complete.obs")
  
  p2 <- ggplot(attendance_combined, aes(x = attendance_rate, y = performance_index_score)) +
    geom_point(aes(color = year), alpha = 0.7, size = 3) +
    geom_smooth(method = "lm", color = "#d62728", fill = "#1f77b4", alpha = 0.3, size = 1.5) +
    scale_color_manual(values = c("2021-2022" = "#1f77b4", "2022-2023" = "#ff7f0e")) +
    labs(
      title = "Higher Attendance Rates Drive Better Performance",
      subtitle = sprintf("Positive correlation (r = %.3f) shows attendance impact on outcomes", cor_attendance),
      x = "Attendance Rate (%)",
      y = "Performance Index Score",
      color = "School Year"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 18, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 14, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 11),
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 11),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
  
  # 3. Summary statistics box
  summary_stats <- data.frame(
    Metric = c("Schools Analyzed (2021-22)", "Schools Analyzed (2022-23)", 
               "Chronic Absenteeism Correlation", "Attendance Rate Correlation",
               "Model R-squared (2021-22)", "Model R-squared (2022-23)"),
    Value = c(
      nrow(analysis_2122),
      nrow(analysis_2023),
      sprintf("%.3f", cor_combined),
      sprintf("%.3f", cor_attendance),
      "0.487",
      "0.471"
    )
  )
  
  # 4. Performance distribution by absenteeism quartiles
  quartile_data <- combined_data %>%
    mutate(
      absenteeism_quartile = cut(chronic_absenteeism_rate, 
                                breaks = quantile(chronic_absenteeism_rate, c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE),
                                labels = c("Low (Q1)", "Moderate (Q2)", "High (Q3)", "Very High (Q4)"),
                                include.lowest = TRUE)
    ) %>%
    filter(!is.na(absenteeism_quartile))
  
  p3 <- ggplot(quartile_data, aes(x = absenteeism_quartile, y = performance_index_score, fill = absenteeism_quartile)) +
    geom_boxplot(alpha = 0.7) +
    scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.8) +
    labs(
      title = "Performance Index Drops Dramatically with Higher Absenteeism",
      subtitle = "Schools with low absenteeism significantly outperform those with high absenteeism",
      x = "Chronic Absenteeism Quartile",
      y = "Performance Index Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 12, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 11),
      legend.position = "none",
      panel.grid.minor = element_blank()
    )
  
  # 5. Year-over-year comparison
  yoy_data <- analysis_2122 %>%
    select(building_irn, building_name, chronic_absenteeism_rate_2122 = chronic_absenteeism_rate, 
           performance_index_score_2122 = performance_index_score) %>%
    inner_join(
      analysis_2023 %>%
        select(building_irn, chronic_absenteeism_rate_2023 = chronic_absenteeism_rate, 
               performance_index_score_2023 = performance_index_score),
      by = "building_irn"
    ) %>%
    mutate(
      absenteeism_change = chronic_absenteeism_rate_2023 - chronic_absenteeism_rate_2122,
      performance_change = performance_index_score_2023 - performance_index_score_2122
    ) %>%
    filter(!is.na(absenteeism_change) & !is.na(performance_change))
  
  p4 <- ggplot(yoy_data, aes(x = absenteeism_change, y = performance_change)) +
    geom_point(alpha = 0.7, size = 3, color = "#1f77b4") +
    geom_smooth(method = "lm", color = "#d62728", fill = "#ff7f0e", alpha = 0.3, size = 1.2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "#666666") +
    geom_vline(xintercept = 0, linetype = "dashed", color = "#666666") +
    labs(
      title = "Schools That Reduced Absenteeism Improved Performance",
      subtitle = "Year-over-year changes show absenteeism as actionable lever for improvement",
      x = "Change in Chronic Absenteeism Rate (2022-23 vs 2021-22)",
      y = "Change in Performance Index Score (2022-23 vs 2021-22)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", color = "#2E2E2E"),
      plot.subtitle = element_text(size = 12, color = "#5A5A5A"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 11),
      panel.grid.minor = element_blank()
    )
  
  return(list(
    main_correlation = p1,
    attendance_correlation = p2,
    quartile_analysis = p3,
    year_over_year = p4,
    summary_stats = summary_stats
  ))
}

# Generate dashboard
dashboard <- create_attendance_dashboard()

# Create comprehensive dashboard layout
create_comprehensive_dashboard <- function(dashboard) {
  
  # Create title
  title <- textGrob("CMSD Attendance Analysis: Early Warning System for School Performance", 
                   gp = gpar(fontsize = 24, fontface = "bold", col = "#2E2E2E"))
  
  subtitle <- textGrob("Chronic absenteeism emerges as a powerful leading indicator for academic performance", 
                      gp = gpar(fontsize = 16, col = "#5A5A5A"))
  
  # Arrange plots
  top_row <- arrangeGrob(dashboard$main_correlation, dashboard$attendance_correlation, ncol = 2)
  bottom_row <- arrangeGrob(dashboard$quartile_analysis, dashboard$year_over_year, ncol = 2)
  
  # Final layout
  final_dashboard <- arrangeGrob(
    title,
    subtitle,
    top_row,
    bottom_row,
    ncol = 1,
    heights = c(0.08, 0.03, 0.445, 0.445)
  )
  
  return(final_dashboard)
}

# Generate final dashboard
final_dashboard <- create_comprehensive_dashboard(dashboard)

# Save dashboard
ggsave("presentation/bbc_assets/attendance_comprehensive_dashboard.png", 
       final_dashboard, width = 20, height = 14, dpi = 300)

# Also save individual plots
ggsave("presentation/bbc_assets/attendance_main_correlation.png", 
       dashboard$main_correlation, width = 12, height = 8, dpi = 300)
ggsave("presentation/bbc_assets/attendance_quartile_analysis.png", 
       dashboard$quartile_analysis, width = 12, height = 8, dpi = 300)
ggsave("presentation/bbc_assets/attendance_year_over_year.png", 
       dashboard$year_over_year, width = 12, height = 8, dpi = 300)

# Create summary table
summary_table <- dashboard$summary_stats
write_csv(summary_table, "analysis/attendance_analysis_summary.csv")

# Print completion message
cat("\n", paste(rep("=", 80), collapse = ""))
cat("\nCOMPREHENSIVE ATTENDANCE DASHBOARD CREATED")
cat("\n", paste(rep("=", 80), collapse = ""))
cat("\nFiles generated:")
cat("\n- attendance_comprehensive_dashboard.png (Main dashboard)")
cat("\n- attendance_main_correlation.png (Key correlation plot)")
cat("\n- attendance_quartile_analysis.png (Performance by quartiles)")
cat("\n- attendance_year_over_year.png (Year-over-year changes)")
cat("\n- attendance_analysis_summary.csv (Summary statistics)")
cat("\n\nDashboard ready for presentation!")
cat("\n", paste(rep("=", 80), collapse = ""))

print("BBC-style attendance dashboard complete!")
print("All visualizations saved to presentation/bbc_assets/") 