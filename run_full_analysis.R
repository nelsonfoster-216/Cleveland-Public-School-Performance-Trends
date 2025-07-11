# CMSD Complete Analysis Pipeline
# Run all analysis scripts in sequence

cat("===== CMSD COMPLETE ANALYSIS PIPELINE =====\n")
cat("Running full analysis from data processing to visualization...\n\n")

# Check if required packages are installed
required_packages <- c("tidyverse", "readxl", "writexl", "janitor", "corrplot", 
                      "scales", "patchwork", "RColorBrewer", "ggtext")

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("ERROR: Missing required packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("Please run: source('setup_dependencies.R') first\n")
  stop("Missing dependencies")
}

# Set working directory to project root
if (!file.exists("R/01_data_processing.R")) {
  cat("ERROR: Cannot find R scripts. Please ensure you're in the project root directory.\n")
  stop("Script files not found")
}

# Step 1: Data Processing
cat("===== STEP 1: DATA PROCESSING =====\n")
tryCatch({
  source("R/01_data_processing.R")
  cat("✓ Data processing completed successfully\n\n")
}, error = function(e) {
  cat("❌ Error in data processing:", e$message, "\n")
  stop("Data processing failed")
})

# Step 2: Analysis
cat("===== STEP 2: STATISTICAL ANALYSIS =====\n")
tryCatch({
  source("R/02_analysis.R")
  cat("✓ Analysis completed successfully\n\n")
}, error = function(e) {
  cat("❌ Error in analysis:", e$message, "\n")
  stop("Analysis failed")
})

# Step 3: Visualizations
cat("===== STEP 3: VISUALIZATIONS =====\n")
tryCatch({
  source("R/03_visualizations.R")
  cat("✓ Visualizations completed successfully\n\n")
}, error = function(e) {
  cat("❌ Error in visualizations:", e$message, "\n")
  stop("Visualization failed")
})

# Step 4: Generate Report
cat("===== STEP 4: GENERATING R MARKDOWN REPORT =====\n")
if (file.exists("CMSD_Analysis_Report.Rmd")) {
  cat("R Markdown report is ready to knit!\n")
  cat("To generate the report, run:\n")
  cat("  rmarkdown::render('CMSD_Analysis_Report.Rmd')\n")
} else {
  cat("❌ R Markdown report file not found\n")
}

cat("\n===== ANALYSIS PIPELINE COMPLETE =====\n")
cat("All components completed successfully!\n")
cat("\nOutput files created:\n")
cat("📊 Data: data/processed/\n")
cat("📈 Analysis: analysis/\n")
cat("📉 Visualizations: presentation/assets/\n")
cat("📄 Report: CMSD_Analysis_Report.Rmd\n")

# Print summary of outputs
cat("\n===== OUTPUT SUMMARY =====\n")
if (dir.exists("data/processed")) {
  processed_files <- list.files("data/processed", pattern = "*.csv|*.xlsx")
  cat("Data files (", length(processed_files), "):", paste(processed_files, collapse = ", "), "\n")
}

if (dir.exists("analysis")) {
  analysis_files <- list.files("analysis", pattern = "*.csv|*.txt")
  cat("Analysis files (", length(analysis_files), "):", paste(analysis_files, collapse = ", "), "\n")
}

if (dir.exists("presentation/assets")) {
  viz_files <- list.files("presentation/assets", pattern = "*.png")
  cat("Visualization files (", length(viz_files), "):", paste(viz_files, collapse = ", "), "\n")
}

cat("\n🎉 Ready for presentation and further customization!\n") 