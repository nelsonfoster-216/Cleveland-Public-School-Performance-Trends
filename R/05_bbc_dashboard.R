# BBC-Style CMSD Dashboard - Comprehensive Data Story
# Purpose: Create a single, impactful dashboard for presentation
# Style: BBC Data Journalism - Professional, story-driven design
# Author: Nelson Foster
# Date: January 2025

# Load libraries
library(tidyverse)
library(patchwork)
library(scales)
library(ggtext)
library(showtext)

# Add professional fonts
font_add_google("Source Sans Pro", "source_sans_pro")
font_add_google("Merriweather", "merriweather")
font_add_google("Roboto Condensed", "roboto_condensed")
showtext_auto()

# BBC color palette
bbc_colors <- list(
  red = "#BB1919",
  orange = "#F56C42", 
  yellow = "#FCAB10",
  green = "#7CB342",
  blue = "#1E88E5",
  teal = "#26C6DA",
  purple = "#AB47BC",
  navy = "#003366",
  dark_gray = "#2E2E2E",
  medium_gray = "#767676",
  light_gray = "#E8E8E8"
)

# Enhanced BBC theme for dashboard
theme_bbc_dashboard <- function(base_size = 10) {
  theme_minimal(base_size = base_size) +
  theme(
    text = element_text(family = "source_sans_pro", color = bbc_colors$dark_gray),
    plot.title = element_text(
      family = "merriweather", 
      size = 14, 
      face = "bold", 
      color = bbc_colors$dark_gray,
      margin = margin(b = 10)
    ),
    plot.subtitle = element_text(
      size = 11, 
      color = bbc_colors$medium_gray,
      margin = margin(b = 15)
    ),
    plot.caption = element_text(
      size = 8, 
      color = bbc_colors$medium_gray,
      margin = margin(t = 10)
    ),
    axis.title = element_text(size = 10, color = bbc_colors$dark_gray),
    axis.text = element_text(size = 9, color = bbc_colors$medium_gray),
    axis.line.x = element_line(color = bbc_colors$light_gray, size = 0.5),
    axis.ticks.x = element_line(color = bbc_colors$light_gray, size = 0.5),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_line(color = bbc_colors$light_gray, size = 0.3),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(15, 15, 15, 15)
  )
}

# Load data
cat("===== CREATING BBC-STYLE CMSD DASHBOARD =====\n")
cmsd_data <- read_csv("data/processed/cmsd_consolidated_final.csv")
district_trends <- read_csv("analysis/district_performance_trends.csv")
top_performers <- read_csv("analysis/top_performers_2023.csv")
improving_schools <- read_csv("analysis/most_improved_schools.csv")

# =============================================================================
# DASHBOARD COMPONENT 1: PERFORMANCE TRANSFORMATION
# =============================================================================

p1_transformation <- district_trends %>%
  filter(!is.na(avg_performance_index)) %>%
  ggplot(aes(x = school_year, y = avg_performance_index, group = 1)) +
  
  # Area fill
  geom_area(alpha = 0.15, fill = bbc_colors$blue) +
  
  # Main line
  geom_line(color = bbc_colors$blue, size = 2.5) +
  
  # Points
  geom_point(color = bbc_colors$blue, size = 4) +
  geom_point(color = "white", size = 2.5) +
  geom_point(color = bbc_colors$blue, size = 1) +
  
  # Value labels
  geom_text(
    aes(label = round(avg_performance_index, 1)), 
    vjust = -1.2, 
    size = 3.5, 
    fontface = "bold",
    color = bbc_colors$dark_gray
  ) +
  
  # Improvement arrow
  annotate("segment", 
           x = 1, xend = 2.8, 
           y = 42, yend = 42,
           arrow = arrow(type = "closed", length = unit(0.2, "cm")),
           color = bbc_colors$green, size = 1) +
  
  annotate("text", 
           x = 1.9, y = 44,
           label = "+15.5 points",
           color = bbc_colors$green, 
           fontface = "bold",
           size = 3) +
  
  scale_y_continuous(
    limits = c(35, 60),
    breaks = seq(35, 60, 5),
    labels = function(x) paste0(x, " pts")
  ) +
  
  scale_x_discrete(
    labels = c("2020-21", "2021-22", "2022-23")
  ) +
  
  labs(
    title = "District Performance: Remarkable Transformation",
    subtitle = "15.5-point improvement in just three years",
    x = NULL,
    y = "Performance Index"
  ) +
  
  theme_bbc_dashboard()

# =============================================================================
# DASHBOARD COMPONENT 2: VALUE-ADDED SUCCESS
# =============================================================================

p2_value_added <- district_trends %>%
  filter(!is.na(avg_value_added)) %>%
  ggplot(aes(x = school_year, y = avg_value_added, group = 1)) +
  
  # Zero reference line
  geom_hline(yintercept = 0, color = bbc_colors$medium_gray, 
             linetype = "dashed", size = 0.8) +
  
  # Success area
  geom_ribbon(aes(ymin = 0, ymax = pmax(avg_value_added, 0)), 
              fill = bbc_colors$green, alpha = 0.3) +
  
  # Main line
  geom_line(color = bbc_colors$green, size = 2.5) +
  
  # Points
  geom_point(color = bbc_colors$green, size = 4) +
  geom_point(color = "white", size = 2.5) +
  geom_point(color = bbc_colors$green, size = 1) +
  
  # Value labels
  geom_text(
    aes(label = paste0("+", round(avg_value_added, 2))), 
    vjust = -1.2, 
    size = 3.5, 
    fontface = "bold",
    color = bbc_colors$dark_gray
  ) +
  
  # Success annotation
  annotate("text", 
           x = 1.5, y = 1.3,
           label = "Above Expected\nGrowth",
           color = bbc_colors$green, 
           fontface = "bold",
           size = 3,
           hjust = 0.5) +
  
  scale_y_continuous(
    limits = c(-0.5, 2),
    breaks = seq(-0.5, 2, 0.5),
    labels = function(x) ifelse(x > 0, paste0("+", x), as.character(x))
  ) +
  
  scale_x_discrete(
    labels = c("2021-22", "2022-23")
  ) +
  
  labs(
    title = "Students Exceeding Growth Expectations",
    subtitle = "Positive value-added = faster learning",
    x = NULL,
    y = "Value-Added Score"
  ) +
  
  theme_bbc_dashboard()

# =============================================================================
# DASHBOARD COMPONENT 3: SCHOOLS OF EXCELLENCE
# =============================================================================

p3_excellence <- top_performers %>%
  slice_head(n = 6) %>%
  mutate(
    building_name = str_wrap(building_name, 20),
    building_name = str_replace_all(building_name, "School", "Sch."),
    building_name = fct_reorder(building_name, performance_index_score)
  ) %>%
  ggplot(aes(x = building_name, y = performance_index_score)) +
  
  # Bars
  geom_col(fill = bbc_colors$purple, alpha = 0.8, width = 0.7) +
  
  # Value labels
  geom_text(
    aes(label = round(performance_index_score, 1)), 
    hjust = -0.1, 
    size = 3, 
    fontface = "bold",
    color = bbc_colors$dark_gray
  ) +
  
  # Excellence line
  geom_hline(yintercept = 80, color = bbc_colors$green, 
             linetype = "dashed", size = 0.8) +
  
  coord_flip() +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 25),
    labels = function(x) paste0(x, " pts")
  ) +
  
  labs(
    title = "Top Performing Schools",
    subtitle = "Excellence is achievable",
    x = NULL,
    y = "Performance Index"
  ) +
  
  theme_bbc_dashboard() +
  theme(axis.text.y = element_text(size = 8))

# =============================================================================
# DASHBOARD COMPONENT 4: IMPROVEMENT CHAMPIONS
# =============================================================================

p4_champions <- improving_schools %>%
  slice_head(n = 6) %>%
  mutate(
    building_name = str_wrap(building_name, 20),
    building_name = str_replace_all(building_name, "School", "Sch."),
    building_name = fct_reorder(building_name, improvement)
  ) %>%
  ggplot(aes(x = building_name, y = improvement)) +
  
  # Bars with gradient
  geom_col(aes(fill = improvement), alpha = 0.8, width = 0.7) +
  
  # Value labels
  geom_text(
    aes(label = paste0("+", round(improvement, 1))), 
    hjust = -0.1, 
    size = 3, 
    fontface = "bold",
    color = bbc_colors$dark_gray
  ) +
  
  # Color scale
  scale_fill_gradient(
    low = bbc_colors$orange, 
    high = bbc_colors$red
  ) +
  
  coord_flip() +
  
  scale_y_continuous(
    limits = c(0, max(improving_schools$improvement[1:6], na.rm = TRUE) * 1.1),
    breaks = seq(0, 50, 10),
    labels = function(x) paste0("+", x)
  ) +
  
  labs(
    title = "Most Improved Schools",
    subtitle = "Dramatic gains possible",
    x = NULL,
    y = "Improvement (Points)"
  ) +
  
  theme_bbc_dashboard() +
  theme(axis.text.y = element_text(size = 8))

# =============================================================================
# DASHBOARD COMPONENT 5: ENROLLMENT STABILITY
# =============================================================================

p5_stability <- district_trends %>%
  ggplot(aes(x = school_year, y = total_enrollment, group = 1)) +
  
  # Area
  geom_area(alpha = 0.2, fill = bbc_colors$teal) +
  
  # Line
  geom_line(color = bbc_colors$teal, size = 2.5) +
  
  # Points
  geom_point(color = bbc_colors$teal, size = 4) +
  geom_point(color = "white", size = 2.5) +
  geom_point(color = bbc_colors$teal, size = 1) +
  
  # Value labels
  geom_text(
    aes(label = scales::comma(total_enrollment, scale = 1e-3, suffix = "K")), 
    vjust = -1.2, 
    size = 3.5, 
    fontface = "bold",
    color = bbc_colors$dark_gray
  ) +
  
  # Stability note
  annotate("text", 
           x = 2, y = 39000,
           label = "Consistent\n~40K students",
           color = bbc_colors$teal, 
           fontface = "bold",
           size = 3,
           hjust = 0.5) +
  
  scale_y_continuous(
    limits = c(38000, 42000),
    breaks = seq(38000, 42000, 1000),
    labels = function(x) scales::comma(x, scale = 1e-3, suffix = "K")
  ) +
  
  scale_x_discrete(
    labels = c("2020-21", "2021-22", "2022-23")
  ) +
  
  labs(
    title = "Enrollment Stability",
    subtitle = "Steady student population",
    x = NULL,
    y = "Total Enrollment"
  ) +
  
  theme_bbc_dashboard()

# =============================================================================
# DASHBOARD COMPONENT 6: KEY METRICS
# =============================================================================

# Create key metrics visualization
key_data <- tibble(
  metric = c("Total Schools", "Students Served", "Performance Gain", "Schools Improved"),
  value = c("112", "~40,000", "+15.5 pts", "96 of 100"),
  color = c(bbc_colors$navy, bbc_colors$teal, bbc_colors$green, bbc_colors$blue),
  x = c(1, 2, 1, 2),
  y = c(2, 2, 1, 1)
)

p6_metrics <- key_data %>%
  ggplot(aes(x = x, y = y)) +
  
  # Colored squares
  geom_tile(aes(fill = color), alpha = 0.1, width = 0.8, height = 0.8) +
  
  # Values
  geom_text(
    aes(label = value, color = color), 
    size = 6, 
    fontface = "bold",
    vjust = 0.2
  ) +
  
  # Metrics
  geom_text(
    aes(label = metric), 
    size = 3.5, 
    color = bbc_colors$dark_gray,
    vjust = 1.5
  ) +
  
  # Colors
  scale_fill_identity() +
  scale_color_identity() +
  
  scale_x_continuous(limits = c(0.5, 2.5)) +
  scale_y_continuous(limits = c(0.5, 2.5)) +
  
  labs(
    title = "Key Metrics",
    subtitle = "District overview"
  ) +
  
  theme_void() +
  theme(
    plot.title = element_text(
      family = "merriweather", 
      size = 14, 
      face = "bold", 
      color = bbc_colors$dark_gray,
      hjust = 0.5
    ),
    plot.subtitle = element_text(
      size = 11, 
      color = bbc_colors$medium_gray,
      hjust = 0.5
    ),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(15, 15, 15, 15)
  )

# =============================================================================
# COMBINE INTO COMPREHENSIVE DASHBOARD
# =============================================================================

cat("\n===== Assembling BBC-Style Dashboard =====\n")

# Create comprehensive dashboard layout
dashboard <- (p1_transformation | p2_value_added | p6_metrics) /
            (p3_excellence | p4_champions | p5_stability) +
            
            plot_annotation(
              title = "Cleveland Municipal School District: A Data-Driven Transformation",
              subtitle = "Three years of remarkable improvement in student performance and growth",
              caption = "Source: Ohio Department of Education School Report Cards (2020-21 to 2022-23) • Analysis: Nelson Foster • Data shows consistent improvement across key metrics",
              theme = theme(
                plot.title = element_text(
                  family = "merriweather", 
                  size = 20, 
                  face = "bold", 
                  color = bbc_colors$dark_gray,
                  hjust = 0.5,
                  margin = margin(b = 10)
                ),
                plot.subtitle = element_text(
                  size = 14, 
                  color = bbc_colors$medium_gray,
                  hjust = 0.5,
                  margin = margin(b = 25)
                ),
                plot.caption = element_text(
                  size = 10, 
                  color = bbc_colors$medium_gray,
                  hjust = 0.5,
                  margin = margin(t = 20)
                ),
                plot.background = element_rect(fill = "white", color = NA),
                plot.margin = margin(30, 30, 30, 30)
              )
            )

# Save the comprehensive dashboard
cat("\n===== Saving BBC-Style Dashboard =====\n")

if (!dir.exists("presentation/bbc_assets")) {
  dir.create("presentation/bbc_assets", recursive = TRUE)
}

# Save high-resolution dashboard
ggsave("presentation/bbc_assets/00_comprehensive_dashboard.png", dashboard, 
       width = 20, height = 14, dpi = 300, bg = "white")

# Save presentation-ready version
ggsave("presentation/bbc_assets/00_presentation_dashboard.png", dashboard, 
       width = 16, height = 11, dpi = 300, bg = "white")

cat("✓ Saved: Comprehensive BBC-Style Dashboard\n")
cat("✓ Saved: Presentation-Ready Dashboard\n")
cat("\n===== BBC DASHBOARD COMPLETE =====\n")
cat("Your wow-factor visualization is ready!\n")
cat("Files: presentation/bbc_assets/00_comprehensive_dashboard.png\n")
cat("       presentation/bbc_assets/00_presentation_dashboard.png\n") 