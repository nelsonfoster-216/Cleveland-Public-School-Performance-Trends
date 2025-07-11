# CMSD Analysis Setup Script
# Install all required packages for the analysis

cat("===== CMSD ANALYSIS SETUP =====\n")
cat("Installing required R packages...\n\n")

# Define required packages
required_packages <- c(
  # Data manipulation and processing
  "tidyverse",
  "readxl", 
  "writexl",
  "janitor",
  
  # Analysis and statistics
  "corrplot",
  "scales",
  
  # Visualization
  "ggplot2",
  "patchwork",
  "RColorBrewer",
  "ggtext",
  "plotly",
  
  # R Markdown and reporting
  "rmarkdown",
  "knitr",
  "kableExtra",
  "DT",
  
  # Additional utilities
  "here"
)

# Function to install packages if not already installed
install_if_missing <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat("Installing", package_name, "...\n")
    install.packages(package_name, dependencies = TRUE)
  } else {
    cat("✓", package_name, "already installed\n")
  }
}

# Install all required packages
for (package in required_packages) {
  install_if_missing(package)
}

cat("\n===== SETUP COMPLETE =====\n")
cat("All required packages installed successfully!\n")
cat("You can now run the analysis scripts and R Markdown document.\n")
cat("\nNext steps:\n")
cat("1. Run: source('R/01_data_processing.R')\n")
cat("2. Run: source('R/02_analysis.R')\n")
cat("3. Run: source('R/03_visualizations.R')\n")
cat("4. Knit: 'CMSD_Analysis_Report.Rmd'\n") 