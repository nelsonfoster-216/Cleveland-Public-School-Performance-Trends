# CMSD Visualization Suite
# Purpose: Create professional charts for presentation
# Focus: Performance trends, strengths, weaknesses, and strategic insights
# Author: Nelson Foster
# Date: January 2025

# Load required libraries
library(tidyverse)
library(scales)
library(patchwork)
library(RColorBrewer)
library(ggtext)

# Set theme for consistent styling
theme_cmsd <- function() {
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 10, color = "gray60"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )
}

# CMSD color palette
cmsd_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b")

# =============================================================================
# STEP 1: Load Data and Analysis Results
# =============================================================================

cat("===== CMSD VISUALIZATION SUITE =====\n")
cat("Loading data and analysis results...\n")

# Load consolidated data
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# Load analysis results
district_trends <- read_csv("analysis/district_performance_trends.csv")
top_performers <- read_csv("analysis/top_performers_2023.csv")
improving_schools <- read_csv("analysis/most_improved_schools.csv")
struggling_schools <- read_csv("analysis/struggling_schools_2023.csv")

cat("Data loaded successfully. Creating visualizations...\n")

# =============================================================================
# STEP 2: ASSIGNMENT REQUIREMENT - District Performance Trends
# =============================================================================

cat("\n===== CREATING DISTRICT PERFORMANCE TRENDS VISUALIZATION =====\n")

# District Performance Index Trend
p1_district_trends <- district_trends %>%
  ggplot(aes(x = school_year, y = avg_performance_index, group = 1)) +
  geom_line(color = cmsd_colors[1], size = 2) +
  geom_point(color = cmsd_colors[1], size = 4) +
  geom_text(aes(label = round(avg_performance_index, 1)), 
            vjust = -0.8, size = 5, fontface = "bold") +
  scale_y_continuous(limits = c(30, 60), breaks = seq(30, 60, 10)) +
  labs(
    title = "CMSD District Performance Index Improvement",
    subtitle = "Remarkable 15.5-point improvement over three years",
    x = "School Year",
    y = "Average Performance Index Score",
    caption = "Source: Ohio Department of Education School Report Cards"
  ) +
  theme_cmsd() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Enrollment stability
p2_enrollment_trends <- district_trends %>%
  ggplot(aes(x = school_year, y = total_enrollment, group = 1)) +
  geom_line(color = cmsd_colors[2], size = 2) +
  geom_point(color = cmsd_colors[2], size = 4) +
  geom_text(aes(label = scales::comma(total_enrollment)), 
            vjust = -0.8, size = 4, fontface = "bold") +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "CMSD Total Enrollment Stability",
    subtitle = "Consistent ~40,000 students served across three years",
    x = "School Year",
    y = "Total District Enrollment",
    caption = "Source: Ohio Department of Education School Report Cards"
  ) +
  theme_cmsd() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# =============================================================================
# STEP 3: ASSIGNMENT REQUIREMENT - Areas of Strength
# =============================================================================

cat("\n===== CREATING AREAS OF STRENGTH VISUALIZATIONS =====\n")

# Top 10 performing schools
p3_top_performers <- top_performers %>%
  slice_head(n = 10) %>%
  mutate(building_name = str_wrap(building_name, 25)) %>%
  ggplot(aes(x = reorder(building_name, performance_index_score), 
             y = performance_index_score)) +
  geom_col(fill = cmsd_colors[3], alpha = 0.8) +
  geom_text(aes(label = round(performance_index_score, 1)), 
            hjust = -0.1, size = 3.5, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Top 10 Performing CMSD Schools (2022-2023)",
    subtitle = "Excellence in academic achievement",
    x = "School Name",
    y = "Performance Index Score",
    caption = "Leading schools demonstrate what's possible across CMSD"
  ) +
  theme_cmsd() +
  theme(axis.text.y = element_text(size = 9))

# Most improved schools
p4_most_improved <- improving_schools %>%
  slice_head(n = 10) %>%
  mutate(building_name = str_wrap(building_name, 25)) %>%
  ggplot(aes(x = reorder(building_name, improvement), 
             y = improvement)) +
  geom_col(fill = cmsd_colors[1], alpha = 0.8) +
  geom_text(aes(label = paste0("+", round(improvement, 1))), 
            hjust = -0.1, size = 3.5, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Most Improved CMSD Schools (2020-2021 to 2022-2023)",
    subtitle = "Dramatic performance gains demonstrate district transformation",
    x = "School Name",
    y = "Performance Index Improvement (Points)",
    caption = "Village Preparatory Schools lead remarkable turnaround"
  ) +
  theme_cmsd() +
  theme(axis.text.y = element_text(size = 9))

# =============================================================================
# STEP 4: ASSIGNMENT REQUIREMENT - Areas of Weakness
# =============================================================================

cat("\n===== CREATING AREAS OF WEAKNESS VISUALIZATIONS =====\n")

# Bottom performing schools
p5_struggling_schools <- struggling_schools %>%
  slice_head(n = 10) %>%
  mutate(building_name = str_wrap(building_name, 25)) %>%
  ggplot(aes(x = reorder(building_name, performance_index_score), 
             y = performance_index_score)) +
  geom_col(fill = cmsd_colors[4], alpha = 0.8) +
  geom_text(aes(label = round(performance_index_score, 1)), 
            hjust = -0.1, size = 3.5, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Schools Requiring Additional Support (2022-2023)",
    subtitle = "Priority schools for targeted intervention",
    x = "School Name",
    y = "Performance Index Score",
    caption = "Focus resources on these schools for maximum district impact"
  ) +
  theme_cmsd() +
  theme(axis.text.y = element_text(size = 9))

# Performance distribution
p6_performance_distribution <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(performance_index_score)) %>%
  ggplot(aes(x = performance_index_score)) +
  geom_histogram(bins = 20, fill = cmsd_colors[5], alpha = 0.7, color = "white") +
  geom_vline(aes(xintercept = mean(performance_index_score, na.rm = TRUE)),
             color = cmsd_colors[4], linetype = "dashed", size = 1) +
  geom_text(aes(x = mean(performance_index_score, na.rm = TRUE), y = 8, 
                label = paste("District Avg:", round(mean(performance_index_score, na.rm = TRUE), 1))),
            hjust = -0.1, color = cmsd_colors[4], fontface = "bold") +
  labs(
    title = "CMSD School Performance Distribution (2022-2023)",
    subtitle = "Most schools cluster around district average",
    x = "Performance Index Score",
    y = "Number of Schools",
    caption = "Distribution shows opportunities for improvement"
  ) +
  theme_cmsd()

# =============================================================================
# STEP 5: Value-Added Analysis Visualization
# =============================================================================

cat("\n===== CREATING VALUE-ADDED ANALYSIS VISUALIZATIONS =====\n")

# Value-added vs Performance Index scatter plot
p7_va_relationship <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(value_added_composite), !is.na(performance_index_score)) %>%
  ggplot(aes(x = value_added_composite, y = performance_index_score, size = enrollment)) +
  geom_point(alpha = 0.6, color = cmsd_colors[1]) +
  geom_smooth(method = "lm", se = FALSE, color = cmsd_colors[4], linetype = "dashed") +
  geom_hline(yintercept = 0, color = "gray50", linetype = "dotted") +
  geom_vline(xintercept = 0, color = "gray50", linetype = "dotted") +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  labs(
    title = "Value-Added vs Performance Index Relationship",
    subtitle = "Schools with positive value-added tend to perform better",
    x = "Value-Added Composite Score",
    y = "Performance Index Score",
    caption = "Bubble size = enrollment; Strong positive correlation (r = 0.493)"
  ) +
  theme_cmsd()

# =============================================================================
# STEP 6: School Size Analysis
# =============================================================================

cat("\n===== CREATING SCHOOL SIZE ANALYSIS VISUALIZATIONS =====\n")

# Performance by school size
size_analysis <- cmsd_data %>%
  filter(school_year == "2022-2023", !is.na(performance_index_score)) %>%
  mutate(
    size_category = case_when(
      enrollment < 200 ~ "Small\n(< 200)",
      enrollment < 400 ~ "Medium\n(200-399)",
      enrollment < 600 ~ "Large\n(400-599)",
      TRUE ~ "Very Large\n(600+)"
    )
  ) %>%
  group_by(size_category) %>%
  summarise(
    school_count = n(),
    avg_performance_index = mean(performance_index_score, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(size_category = factor(size_category, levels = c("Small\n(< 200)", "Medium\n(200-399)", 
                                                         "Large\n(400-599)", "Very Large\n(600+)")))

p8_size_performance <- size_analysis %>%
  ggplot(aes(x = size_category, y = avg_performance_index, fill = size_category)) +
  geom_col(alpha = 0.8) +
  geom_text(aes(label = round(avg_performance_index, 1)), 
            vjust = -0.5, size = 4, fontface = "bold") +
  scale_fill_manual(values = cmsd_colors[1:4], guide = "none") +
  labs(
    title = "Performance by School Size (2022-2023)",
    subtitle = "Small schools slightly outperform larger schools",
    x = "School Size Category",
    y = "Average Performance Index Score",
    caption = "Optimal school size appears to be under 200 students"
  ) +
  theme_cmsd()

# =============================================================================
# STEP 7: Summary Dashboard
# =============================================================================

cat("\n===== CREATING SUMMARY DASHBOARD =====\n")

# Key metrics summary
key_metrics <- tribble(
  ~metric, ~value, ~description,
  "Total Schools", "112", "CMSD Schools",
  "Total Students", "~40,000", "District Enrollment",
  "Performance Gain", "+15.5", "Points (2020-23)",
  "Schools Improved", "96", "vs 4 Declined",
  "High Performers", "21", "Schools Above 60 PI",
  "Need Support", "27", "Schools Below 40 PI"
)

# Create text-based summary
p9_key_metrics <- key_metrics %>%
  mutate(
    x = rep(c(1, 2, 3), each = 2),
    y = rep(c(2, 1), times = 3),
    label = paste0(value, "\n", description)
  ) %>%
  ggplot(aes(x = x, y = y)) +
  geom_text(aes(label = label), size = 6, fontface = "bold", hjust = 0.5, vjust = 0.5) +
  scale_x_continuous(limits = c(0.5, 3.5)) +
  scale_y_continuous(limits = c(0.5, 2.5)) +
  labs(
    title = "CMSD Performance Overview: Key Metrics",
    subtitle = "Three-year transformation summary"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "gray40")
  )

# =============================================================================
# STEP 8: Save All Visualizations
# =============================================================================

cat("\n===== SAVING VISUALIZATIONS =====\n")

# Create assets directory if it doesn't exist
if (!dir.exists("presentation/assets")) {
  dir.create("presentation/assets", recursive = TRUE)
}

# Save all plots
ggsave("presentation/assets/01_district_performance_trends.png", p1_district_trends, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: District Performance Trends\n")

ggsave("presentation/assets/02_enrollment_trends.png", p2_enrollment_trends, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: Enrollment Trends\n")

ggsave("presentation/assets/03_top_performers.png", p3_top_performers, 
       width = 12, height = 10, dpi = 300, bg = "white")
cat("✓ Saved: Top Performing Schools\n")

ggsave("presentation/assets/04_most_improved.png", p4_most_improved, 
       width = 12, height = 10, dpi = 300, bg = "white")
cat("✓ Saved: Most Improved Schools\n")

ggsave("presentation/assets/05_struggling_schools.png", p5_struggling_schools, 
       width = 12, height = 10, dpi = 300, bg = "white")
cat("✓ Saved: Struggling Schools\n")

ggsave("presentation/assets/06_performance_distribution.png", p6_performance_distribution, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: Performance Distribution\n")

ggsave("presentation/assets/07_value_added_relationship.png", p7_va_relationship, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: Value-Added Relationship\n")

ggsave("presentation/assets/08_size_performance.png", p8_size_performance, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: School Size Performance\n")

ggsave("presentation/assets/09_key_metrics.png", p9_key_metrics, 
       width = 12, height = 8, dpi = 300, bg = "white")
cat("✓ Saved: Key Metrics Summary\n")

# =============================================================================
# STEP 9: Create Combined Visualizations
# =============================================================================

cat("\n===== CREATING COMBINED VISUALIZATIONS =====\n")

# Strengths vs Weaknesses comparison
p10_strengths_weaknesses <- (p3_top_performers | p5_struggling_schools) +
  plot_annotation(
    title = "CMSD Performance Spectrum: Excellence and Opportunity",
    subtitle = "Clear distinction between high-performing and struggling schools",
    theme = theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
  )

ggsave("presentation/assets/10_strengths_weaknesses.png", p10_strengths_weaknesses, 
       width = 20, height = 10, dpi = 300, bg = "white")
cat("✓ Saved: Strengths vs Weaknesses Comparison\n")

# Trends overview
p11_trends_overview <- (p1_district_trends / p2_enrollment_trends) +
  plot_annotation(
    title = "CMSD District Overview: Performance and Enrollment Trends",
    subtitle = "Steady enrollment with dramatic performance improvement",
    theme = theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
  )

ggsave("presentation/assets/11_trends_overview.png", p11_trends_overview, 
       width = 12, height = 12, dpi = 300, bg = "white")
cat("✓ Saved: Trends Overview\n")

cat("\n===== VISUALIZATION SUITE COMPLETE =====\n")
cat("All visualizations saved to presentation/assets/\n")
cat("Ready for presentation development\n") 