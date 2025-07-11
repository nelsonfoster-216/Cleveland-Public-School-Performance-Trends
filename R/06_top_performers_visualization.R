# Top Performing Schools Visualizations
# BBC-style data journalism approach for CMSD analysis

# Load required libraries
library(tidyverse)
library(readr)
library(scales)
library(ggtext)
library(patchwork)
library(RColorBrewer)

# BBC-inspired color palette
bbc_colors <- c(
  "#1380A1",  # BBC Blue
  "#FAAB18",  # BBC Yellow
  "#990000",  # BBC Red
  "#1A8022",  # BBC Green
  "#F19201",  # BBC Orange
  "#7F3F98",  # BBC Purple
  "#C70000",  # BBC Dark Red
  "#00A2E8"   # BBC Light Blue
)

# Enhanced BBC-style theme
theme_bbc_enhanced <- function() {
  theme_minimal() +
    theme(
      # Text formatting
      plot.title = element_text(
        family = "Arial", 
        size = 18, 
        face = "bold", 
        hjust = 0,
        margin = margin(b = 20),
        color = "#222222"
      ),
      plot.subtitle = element_text(
        family = "Arial", 
        size = 14, 
        hjust = 0,
        margin = margin(b = 25),
        color = "#666666",
        lineheight = 1.2
      ),
      plot.caption = element_text(
        family = "Arial",
        size = 11,
        color = "#888888",
        hjust = 0,
        margin = margin(t = 20)
      ),
      
      # Axis formatting
      axis.title = element_text(
        family = "Arial", 
        size = 13, 
        face = "bold",
        color = "#222222"
      ),
      axis.text = element_text(
        family = "Arial", 
        size = 11,
        color = "#333333"
      ),
      
      # Legend formatting
      legend.title = element_text(
        family = "Arial", 
        size = 12, 
        face = "bold",
        color = "#222222"
      ),
      legend.text = element_text(
        family = "Arial", 
        size = 11,
        color = "#333333"
      ),
      legend.position = "bottom",
      
      # Grid and background
      panel.grid.major = element_line(color = "#E6E6E6", size = 0.5),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      
      # Margins
      plot.margin = margin(25, 25, 25, 25)
    )
}

# Load data
top_performers <- read_csv("analysis/top_performers_2023.csv", show_col_types = FALSE)
consolidated_data <- read_csv("data/processed/cmsd_consolidated_final.csv", show_col_types = FALSE)

# Clean school names for better display
top_performers <- top_performers %>%
  mutate(
    school_name_clean = str_wrap(building_name, 25),
    school_name_short = case_when(
      str_detect(building_name, "Cleveland School of Science & Medicine") ~ "Science & Medicine",
      str_detect(building_name, "Cleveland Early College High") ~ "Early College High",
      str_detect(building_name, "Near West Intergenerational") ~ "Near West Intergenerational",
      str_detect(building_name, "Cleveland School of Architecture") ~ "Architecture & Design",
      str_detect(building_name, "Cleveland School Of The Arts") ~ "Arts High School",
      str_detect(building_name, "Campus International School") ~ "Campus International",
      str_detect(building_name, "Bard Early College") ~ "Bard Early College",
      str_detect(building_name, "Northwest School of the Arts") ~ "Northwest Arts",
      TRUE ~ building_name
    )
  )

# === VISUALIZATION 1: Top Performers Table Visualization ===

# Create a comprehensive dashboard-style visualization
create_top_performers_dashboard <- function() {
  
  # Main performance index chart
  p1 <- top_performers %>%
    ggplot(aes(x = reorder(school_name_short, performance_index_score), 
               y = performance_index_score)) +
    geom_col(fill = bbc_colors[1], alpha = 0.8, width = 0.7) +
    geom_text(aes(label = performance_index_score), 
              hjust = -0.1, size = 3.5, fontface = "bold", color = "#222222") +
    coord_flip() +
    scale_y_continuous(
      limits = c(0, 105),
      breaks = seq(0, 100, 20),
      expand = expansion(mult = c(0, 0.1))
    ) +
    labs(
      title = "CMSD's Top Performing Schools 2022-2023",
      subtitle = "Performance Index scores demonstrate excellence across diverse school types",
      x = NULL,
      y = "Performance Index Score"
    ) +
    theme_bbc_enhanced() +
    theme(
      axis.text.y = element_text(size = 10),
      panel.grid.major.y = element_blank()
    )
  
  # Enrollment comparison
  p2 <- top_performers %>%
    ggplot(aes(x = reorder(school_name_short, performance_index_score), 
               y = enrollment)) +
    geom_col(fill = bbc_colors[2], alpha = 0.8, width = 0.7) +
    geom_text(aes(label = enrollment), 
              hjust = -0.1, size = 3.5, fontface = "bold", color = "#222222") +
    coord_flip() +
    scale_y_continuous(
      limits = c(0, 750),
      breaks = seq(0, 700, 100),
      expand = expansion(mult = c(0, 0.1))
    ) +
    labs(
      title = "Student Enrollment",
      subtitle = "High performance across varying school sizes",
      x = NULL,
      y = "Number of Students"
    ) +
    theme_bbc_enhanced() +
    theme(
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank()
    )
  
  # Value-added comparison
  p3 <- top_performers %>%
    ggplot(aes(x = reorder(school_name_short, performance_index_score), 
               y = value_added_composite)) +
    geom_col(aes(fill = value_added_composite > 0), alpha = 0.8, width = 0.7) +
    geom_text(aes(label = ifelse(value_added_composite > 0, 
                                paste0("+", round(value_added_composite, 1)), 
                                round(value_added_composite, 1))), 
              hjust = ifelse(top_performers$value_added_composite > 0, -0.1, 1.1), 
              size = 3.5, fontface = "bold", color = "#222222") +
    coord_flip() +
    scale_fill_manual(
      values = c("TRUE" = bbc_colors[4], "FALSE" = bbc_colors[3]),
      guide = "none"
    ) +
    scale_y_continuous(
      limits = c(-15, 20),
      breaks = seq(-15, 20, 5)
    ) +
    labs(
      title = "Value-Added Growth",
      subtitle = "Student progress beyond expectations",
      x = NULL,
      y = "Value-Added Composite Score"
    ) +
    theme_bbc_enhanced() +
    theme(
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank()
    )
  
  # Combine all three charts
  combined_chart <- p1 + p2 + p3 + 
    plot_layout(ncol = 3, widths = c(2, 1, 1)) +
    plot_annotation(
      caption = "Source: Ohio Department of Education School Report Cards, 2022-2023\nAnalysis by CMSD Data Strategy Team",
      theme = theme(
        plot.caption = element_text(
          family = "Arial", 
          size = 10, 
          color = "#888888",
          hjust = 0
        )
      )
    )
  
  return(combined_chart)
}

# Generate the dashboard
dashboard <- create_top_performers_dashboard()

# Save the dashboard
ggsave("presentation/bbc_assets/top_performers_dashboard.png", 
       plot = dashboard, 
       width = 16, height = 10, dpi = 300, bg = "white")

# === VISUALIZATION 2: Year-over-Year Trends ===

# Get trend data for top 10 schools
top_school_irns <- top_performers$building_irn[1:10]

trend_data <- consolidated_data %>%
  filter(building_irn %in% top_school_irns) %>%
  arrange(building_irn, school_year) %>%
  mutate(
    school_name_short = case_when(
      str_detect(building_name, "Cleveland School of Science & Medicine") ~ "Science & Medicine",
      str_detect(building_name, "Cleveland Early College High") ~ "Early College High",
      str_detect(building_name, "Near West Intergenerational") ~ "Near West Intergenerational",
      str_detect(building_name, "Cleveland School of Architecture") ~ "Architecture & Design",
      str_detect(building_name, "Cleveland School Of The Arts") ~ "Arts High School",
      str_detect(building_name, "Campus International School") ~ "Campus International",
      str_detect(building_name, "Bard Early College") ~ "Bard Early College",
      str_detect(building_name, "Northwest School of the Arts") ~ "Northwest Arts",
      TRUE ~ str_wrap(building_name, 20)
    ),
    school_year_clean = case_when(
      school_year == "2020-2021" ~ "2020-21",
      school_year == "2021-2022" ~ "2021-22",
      school_year == "2022-2023" ~ "2022-23",
      TRUE ~ school_year
    )
  ) %>%
  # Order schools by 2022-2023 performance
  left_join(
    top_performers %>% select(building_irn, performance_index_score) %>% 
      rename(final_performance = performance_index_score),
    by = "building_irn"
  ) %>%
  arrange(desc(final_performance))

# Create trend visualization
create_trend_visualization <- function() {
  
  # Main trend lines
  p_trends <- trend_data %>%
    filter(!is.na(performance_index_score)) %>%
    ggplot(aes(x = school_year_clean, y = performance_index_score, 
               group = school_name_short, color = school_name_short)) +
    
    # Add subtle background grid
    geom_hline(yintercept = seq(60, 100, 10), color = "#F0F0F0", size = 0.5) +
    
    # Trend lines
    geom_line(size = 1.2, alpha = 0.8) +
    geom_point(size = 3, alpha = 0.9) +
    
    # Labels for final year
    geom_text(
      data = trend_data %>% 
        filter(school_year == "2022-2023", !is.na(performance_index_score)),
      aes(label = performance_index_score),
      hjust = -0.3, size = 3.2, fontface = "bold", show.legend = FALSE
    ) +
    
    # Color scheme
    scale_color_manual(
      values = c(
        "Science & Medicine" = bbc_colors[1],
        "Early College High" = bbc_colors[2],
        "Near West Intergenerational" = bbc_colors[3],
        "Architecture & Design" = bbc_colors[4],
        "Arts High School" = bbc_colors[5],
        "Campus International" = bbc_colors[6],
        "Bard Early College" = bbc_colors[7],
        "Northwest Arts" = bbc_colors[8],
        "Douglas MacArthur" = "#FF6B6B",
        "Menlo Park Academy" = "#4ECDC4"
      ),
      name = "School"
    ) +
    
    # Scales
    scale_x_discrete(
      expand = expansion(mult = c(0.05, 0.15))
    ) +
    scale_y_continuous(
      limits = c(55, 105),
      breaks = seq(60, 100, 10),
      expand = expansion(mult = c(0.02, 0.02))
    ) +
    
    # Labels
    labs(
      title = "Three-Year Performance Trajectory: CMSD's Top Schools",
      subtitle = "Sustained excellence and continued growth among Cleveland's highest-performing schools",
      x = "School Year",
      y = "Performance Index Score",
      caption = "Source: Ohio Department of Education School Report Cards (2020-2023)\nNote: Higher scores indicate better performance. State average is approximately 80."
    ) +
    
    # Theme
    theme_bbc_enhanced() +
    theme(
      legend.position = "right",
      legend.text = element_text(size = 9),
      axis.text.x = element_text(angle = 0),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = "#E6E6E6", size = 0.3)
    ) +
    
    # Annotations
    annotate("text", x = 2.7, y = 102, 
             label = "Menlo Park Academy\n(99.4)", 
             size = 3, hjust = 0, color = "#4ECDC4", fontface = "bold") +
    annotate("text", x = 2.7, y = 92, 
             label = "Science & Medicine\n(90.1)", 
             size = 3, hjust = 0, color = bbc_colors[1], fontface = "bold")
  
  return(p_trends)
}

# Generate trend visualization
trend_viz <- create_trend_visualization()

# Save trend visualization
ggsave("presentation/bbc_assets/top_performers_trends.png", 
       plot = trend_viz, 
       width = 14, height = 10, dpi = 300, bg = "white")

# === VISUALIZATION 3: Combined Summary Statistics ===

# Create summary statistics
summary_stats <- trend_data %>%
  group_by(school_name_short) %>%
  summarise(
    years_tracked = sum(!is.na(performance_index_score)),
    initial_score = first(performance_index_score[!is.na(performance_index_score)]),
    final_score = last(performance_index_score[!is.na(performance_index_score)]),
    improvement = final_score - initial_score,
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 0),
    avg_value_added = round(mean(value_added_composite, na.rm = TRUE), 2),
    .groups = 'drop'
  ) %>%
  arrange(desc(final_score))

# Create improvement chart
create_improvement_chart <- function() {
  
  improvement_chart <- summary_stats %>%
    filter(years_tracked >= 2) %>%
    ggplot(aes(x = reorder(school_name_short, improvement), y = improvement)) +
    geom_col(aes(fill = improvement > 0), alpha = 0.8, width = 0.7) +
    geom_text(aes(label = ifelse(improvement > 0, 
                                paste0("+", round(improvement, 1)), 
                                round(improvement, 1))), 
              hjust = ifelse(summary_stats$improvement[summary_stats$years_tracked >= 2] > 0, -0.1, 1.1), 
              size = 3.5, fontface = "bold", color = "#222222") +
    coord_flip() +
    scale_fill_manual(
      values = c("TRUE" = bbc_colors[4], "FALSE" = bbc_colors[3]),
      guide = "none"
    ) +
    labs(
      title = "Performance Improvement Among Top Schools (2020-2023)",
      subtitle = "Most elite schools maintained or improved their already high performance",
      x = NULL,
      y = "Performance Index Point Change",
      caption = "Source: Ohio Department of Education School Report Cards\nNote: Positive values indicate improvement over the three-year period"
    ) +
    theme_bbc_enhanced() +
    theme(
      panel.grid.major.y = element_blank()
    )
  
  return(improvement_chart)
}

# Generate improvement chart
improvement_viz <- create_improvement_chart()

# Save improvement visualization
ggsave("presentation/bbc_assets/top_performers_improvement.png", 
       plot = improvement_viz, 
       width = 12, height = 8, dpi = 300, bg = "white")

# Print summary for console
cat("=== TOP PERFORMERS VISUALIZATION COMPLETE ===\n")
cat("Generated 3 BBC-style visualizations:\n")
cat("1. Top Performers Dashboard (comprehensive table visualization)\n")
cat("2. Three-Year Trend Analysis (year-over-year performance)\n")
cat("3. Performance Improvement Summary (change over time)\n")
cat("\nFiles saved to: presentation/bbc_assets/\n")
cat("- top_performers_dashboard.png\n")
cat("- top_performers_trends.png\n")
cat("- top_performers_improvement.png\n") 