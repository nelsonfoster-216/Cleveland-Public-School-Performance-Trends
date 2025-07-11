# ==============================================================================
# CMSD Attendance and Performance Analysis
# Examining the relationship between chronic absenteeism, attendance rates, 
# and performance index scores
# ==============================================================================

# Load necessary libraries
library(tidyverse)
library(readxl)
library(corrplot)
library(ggplot2)
library(scales)
library(gridExtra)
library(RColorBrewer)
library(viridis)
library(broom)
library(GGally)
library(plotly)
library(kableExtra)

# Load BBC style functions
source("R/04_bbc_style_visualizations.R")

# ==============================================================================
# 1. DATA LOADING AND PREPARATION
# ==============================================================================

# Load the consolidated performance data
performance_data <- read_csv("data/processed/cmsd_consolidated_final.csv")

# Load Building Details data for both years
building_details_2122 <- read_excel("report_card_data/building_details/2122_Building_Details.xlsx", sheet = "Building_Details")
building_details_2023 <- read_excel("report_card_data/building_details/2023_Building_Details.xlsx", sheet = "Building_Details")

# Print column names to understand structure
cat("2021-22 Building Details columns:\n")
print(names(building_details_2122))

cat("\n2022-23 Building Details columns:\n")
print(names(building_details_2023))

# Examine the first few rows
cat("\nFirst few rows of 2021-22 data:\n")
print(head(building_details_2122))

cat("\nFirst few rows of 2022-23 data:\n")
print(head(building_details_2023))

# ==============================================================================
# 2. DATA CLEANING AND MATCHING
# ==============================================================================

# Function to clean and prepare attendance data
prepare_attendance_data <- function(building_data, year_label) {
  # Look for attendance-related columns
  attendance_cols <- names(building_data)[grepl("(?i)(attendance|absent|chronic)", names(building_data))]
  enrollment_cols <- names(building_data)[grepl("(?i)(enrollment|enroll)", names(building_data))]
  
  cat(sprintf("\nAttendance-related columns in %s:\n", year_label))
  print(attendance_cols)
  cat(sprintf("\nEnrollment-related columns in %s:\n", year_label))
  print(enrollment_cols)
  
  # Create a cleaned dataset
  cleaned_data <- building_data %>%
    select(
      building_irn = `Building IRN`,
      building_name = `Building Name`,
      any_of(attendance_cols),
      any_of(enrollment_cols)
    ) %>%
    mutate(
      school_year = year_label,
      building_irn = as.character(building_irn)
    )
  
  return(cleaned_data)
}

# Prepare data for both years
attendance_2122 <- prepare_attendance_data(building_details_2122, "2021-2022")
attendance_2023 <- prepare_attendance_data(building_details_2023, "2022-2023")

# ==============================================================================
# 3. MERGE WITH PERFORMANCE DATA
# ==============================================================================

# Function to merge attendance and performance data
merge_attendance_performance <- function(attendance_data, performance_data, year) {
  merged_data <- attendance_data %>%
    left_join(
      performance_data %>% filter(school_year == year),
      by = c("building_irn", "school_year")
    ) %>%
    filter(!is.na(performance_index_score))
  
  return(merged_data)
}

# Merge data for both years
analysis_2122 <- merge_attendance_performance(attendance_2122, performance_data, "2021-2022")
analysis_2023 <- merge_attendance_performance(attendance_2023, performance_data, "2022-2023")

# ==============================================================================
# 4. IDENTIFY RELEVANT COLUMNS AND CLEAN DATA
# ==============================================================================

# Function to identify and clean relevant columns
clean_analysis_data <- function(data, year_label) {
  # Find columns that contain numeric attendance/absenteeism data
  numeric_cols <- data %>%
    select_if(is.numeric) %>%
    names()
  
  # Look for key indicators
  chronic_absent_col <- names(data)[grepl("(?i)(chronic.*absent|absent.*chronic)", names(data))]
  attendance_rate_col <- names(data)[grepl("(?i)(attendance.*rate|rate.*attendance)", names(data))]
  enrollment_percent_col <- names(data)[grepl("(?i)(enrollment.*percent|percent.*enrollment)", names(data))]
  
  cat(sprintf("\nPotential chronic absenteeism columns in %s:\n", year_label))
  print(chronic_absent_col)
  cat(sprintf("\nPotential attendance rate columns in %s:\n", year_label))
  print(attendance_rate_col)
  cat(sprintf("\nPotential enrollment percent columns in %s:\n", year_label))
  print(enrollment_percent_col)
  
  # Create a summary of all numeric columns
  numeric_summary <- data %>%
    select_if(is.numeric) %>%
    summarise_all(list(
      ~sum(!is.na(.)),
      ~mean(., na.rm = TRUE),
      ~sd(., na.rm = TRUE)
    ))
  
  cat(sprintf("\nNumeric columns summary for %s:\n", year_label))
  print(numeric_summary)
  
  return(data)
}

# Clean and examine both datasets
analysis_2122_clean <- clean_analysis_data(analysis_2122, "2021-2022")
analysis_2023_clean <- clean_analysis_data(analysis_2023, "2022-2023")

# ==============================================================================
# 5. STATISTICAL ANALYSIS FUNCTIONS
# ==============================================================================

# Function to perform correlation analysis
perform_correlation_analysis <- function(data, year_label) {
  # Select numeric columns for correlation
  numeric_data <- data %>%
    select_if(is.numeric) %>%
    select(-contains("irn")) %>%
    filter(complete.cases(.))
  
  # Calculate correlation matrix
  cor_matrix <- cor(numeric_data, use = "complete.obs")
  
  # Focus on correlations with performance_index_score
  performance_cors <- cor_matrix[, "performance_index_score", drop = FALSE]
  performance_cors <- performance_cors[order(abs(performance_cors), decreasing = TRUE), , drop = FALSE]
  
  cat(sprintf("\nCorrelations with Performance Index Score (%s):\n", year_label))
  print(performance_cors)
  
  return(list(
    correlation_matrix = cor_matrix,
    performance_correlations = performance_cors,
    data = numeric_data
  ))
}

# Function to perform regression analysis
perform_regression_analysis <- function(data, predictors, outcome = "performance_index_score") {
  # Create formula
  formula_str <- paste(outcome, "~", paste(predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit regression model
  model <- lm(model_formula, data = data)
  
  # Get model summary
  model_summary <- summary(model)
  
  # Get tidy results
  tidy_results <- tidy(model)
  glance_results <- glance(model)
  
  return(list(
    model = model,
    summary = model_summary,
    tidy = tidy_results,
    fit_stats = glance_results,
    formula = formula_str
  ))
}

# ==============================================================================
# 6. VISUALIZATION FUNCTIONS
# ==============================================================================

# Function to create correlation heatmap
create_correlation_heatmap <- function(cor_matrix, title) {
  # Convert correlation matrix to long format
  cor_long <- cor_matrix %>%
    as.data.frame() %>%
    rownames_to_column("var1") %>%
    pivot_longer(-var1, names_to = "var2", values_to = "correlation")
  
  # Create heatmap
  p <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "#1f77b4", mid = "white", high = "#d62728", 
                         midpoint = 0, limit = c(-1, 1), space = "Lab", 
                         name = "Correlation") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
      axis.text.y = element_text(hjust = 1),
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
    ) +
    labs(
      title = title,
      x = "",
      y = ""
    ) +
    coord_fixed()
  
  return(p)
}

# Function to create scatter plot with regression line
create_scatter_regression <- function(data, x_var, y_var, title) {
  p <- ggplot(data, aes_string(x = x_var, y = y_var)) +
    geom_point(alpha = 0.7, color = "#1f77b4") +
    geom_smooth(method = "lm", color = "#d62728", fill = "#ff7f0e", alpha = 0.3) +
    labs(
      title = title,
      x = str_to_title(str_replace_all(x_var, "_", " ")),
      y = "Performance Index Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  return(p)
}

# Function to create residual plots
create_residual_plots <- function(model, title) {
  # Create residual data
  residual_data <- data.frame(
    fitted = fitted(model),
    residuals = residuals(model),
    standardized_residuals = rstandard(model)
  )
  
  # Residuals vs Fitted
  p1 <- ggplot(residual_data, aes(x = fitted, y = residuals)) +
    geom_point(alpha = 0.7, color = "#1f77b4") +
    geom_hline(yintercept = 0, color = "#d62728", linetype = "dashed") +
    geom_smooth(method = "loess", color = "#ff7f0e", se = FALSE) +
    labs(
      title = paste("Residuals vs Fitted -", title),
      x = "Fitted Values",
      y = "Residuals"
    ) +
    theme_minimal()
  
  # Q-Q plot
  p2 <- ggplot(residual_data, aes(sample = standardized_residuals)) +
    stat_qq(color = "#1f77b4", alpha = 0.7) +
    stat_qq_line(color = "#d62728") +
    labs(
      title = paste("Q-Q Plot -", title),
      x = "Theoretical Quantiles",
      y = "Standardized Residuals"
    ) +
    theme_minimal()
  
  return(list(residuals_fitted = p1, qq_plot = p2))
}

# ==============================================================================
# 7. MAIN ANALYSIS EXECUTION
# ==============================================================================

# Perform correlation analysis for both years
cat("Performing correlation analysis...\n")
cor_analysis_2122 <- perform_correlation_analysis(analysis_2122_clean, "2021-2022")
cor_analysis_2023 <- perform_correlation_analysis(analysis_2023_clean, "2022-2023")

# Save the analysis results
cat("Analysis complete. Results saved to correlation analysis objects.\n")

# Print summary
cat("\n==============================================================================\n")
cat("ANALYSIS SUMMARY\n")
cat("==============================================================================\n")
cat(sprintf("2021-22 Schools analyzed: %d\n", nrow(analysis_2122_clean)))
cat(sprintf("2022-23 Schools analyzed: %d\n", nrow(analysis_2023_clean)))
cat("\nKey findings will be generated in the next steps...\n") 