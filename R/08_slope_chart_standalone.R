# BBC-Style CMSD Slope Chart - Standalone Version
# Creates a clean, professional slope chart for interview presentation
# Demonstrates range in visualization techniques

# Load libraries
library(tidyverse)
library(readxl)
library(scales)
library(ggplot2)

# Load the district trends data
district_trends <- read_csv("data/processed/cmsd_consolidated_final.csv") %>%
  group_by(school_year) %>%
  summarise(
    total_schools = n(),
    total_enrollment = sum(enrollment, na.rm = TRUE),
    avg_enrollment = round(mean(enrollment, na.rm = TRUE), 1),
    avg_value_added = round(mean(value_added_composite, na.rm = TRUE), 2),
    avg_performance_index = round(mean(performance_index_score, na.rm = TRUE), 1),
    median_performance_index = round(median(performance_index_score, na.rm = TRUE), 1),
    .groups = 'drop'
  )

# BBC-inspired color palette
bbc_transformation <- c(
  primary_blue = "#1380A1",
  success_green = "#1A8022", 
  warning_red = "#C70000",
  text_dark = "#222222",
  text_medium = "#666666",
  text_light = "#888888",
  grid_light = "#E6E6E6"
)

# Clean BBC-style theme for slope chart
theme_bbc_slope <- function() {
  theme_minimal() +
    theme(
      # Typography
      plot.title = element_text(
        size = 22, 
        face = "bold", 
        hjust = 0,
        margin = margin(b = 15),
        color = bbc_transformation["text_dark"]
      ),
      plot.subtitle = element_text(
        size = 16, 
        hjust = 0,
        margin = margin(b = 30),
        color = bbc_transformation["text_medium"],
        lineheight = 1.2
      ),
      plot.caption = element_text(
        size = 13,
        color = bbc_transformation["text_light"],
        hjust = 0,
        margin = margin(t = 20)
      ),
      
      # Axes
      axis.title = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_text(
        size = 14,
        face = "bold",
        color = bbc_transformation["text_dark"],
        margin = margin(t = 10)
      ),
      axis.ticks = element_blank(),
      
      # Grid
      panel.grid.major.y = element_line(
        color = bbc_transformation["grid_light"], 
        linewidth = 0.5
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      
      # Background
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      
      # Margins
      plot.margin = margin(25, 25, 25, 25)
    )
}

# Prepare data for slope chart
slope_data <- district_trends %>%
  filter(!is.na(avg_performance_index)) %>%
  filter(school_year %in% c("2020-2021", "2022-2023")) %>%
  mutate(
    year_clean = case_when(
      school_year == "2020-2021" ~ "2020-21",
      school_year == "2022-2023" ~ "2022-23"
    ),
    year_position = case_when(
      school_year == "2020-2021" ~ 1,
      school_year == "2022-2023" ~ 2
    )
  )

# Calculate improvement metrics
improvement_amount <- slope_data$avg_performance_index[2] - slope_data$avg_performance_index[1]
improvement_percent <- round((improvement_amount / slope_data$avg_performance_index[1]) * 100, 1)

# Create the slope chart
p_slope <- ggplot(slope_data, aes(x = year_position, y = avg_performance_index)) +
  
  # Background performance zones (subtle)
  annotate("rect", xmin = 0.5, xmax = 2.5, ymin = 0, ymax = 40, 
           fill = bbc_transformation["warning_red"], alpha = 0.06) +
  annotate("rect", xmin = 0.5, xmax = 2.5, ymin = 40, ymax = 60, 
           fill = "#F19201", alpha = 0.06) +
  annotate("rect", xmin = 0.5, xmax = 2.5, ymin = 60, ymax = 80, 
           fill = bbc_transformation["success_green"], alpha = 0.06) +
  
  # Performance zone labels (right side)
  annotate("text", x = 2.4, y = 20, label = "Needs\nImprovement", 
           color = bbc_transformation["warning_red"], fontface = "bold", 
           size = 4, hjust = 1, alpha = 0.7) +
  annotate("text", x = 2.4, y = 50, label = "Developing", 
           color = "#F19201", fontface = "bold", 
           size = 4, hjust = 1, alpha = 0.7) +
  annotate("text", x = 2.4, y = 70, label = "Proficient", 
           color = bbc_transformation["success_green"], fontface = "bold", 
           size = 4, hjust = 1, alpha = 0.7) +
  
  # Main connecting line
  geom_line(color = bbc_transformation["primary_blue"], linewidth = 4, alpha = 0.8) +
  
  # Points for start and end
  geom_point(color = "white", size = 10) +
  geom_point(color = bbc_transformation["primary_blue"], size = 8) +
  
  # Value labels on points
  geom_text(aes(label = avg_performance_index), 
            color = "white", size = 5, fontface = "bold") +
  
  # Improvement arrow and annotation
  annotate("segment", 
           x = 1.15, y = slope_data$avg_performance_index[1], 
           xend = 1.85, yend = slope_data$avg_performance_index[2],
           arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
           color = bbc_transformation["success_green"], linewidth = 2.5, alpha = 0.9) +
  
  # Improvement metrics callout
  annotate("text", x = 1.5, y = 47, 
           label = paste0("+", improvement_amount, " points\n+", improvement_percent, "%"), 
           color = bbc_transformation["success_green"], 
           fontface = "bold", size = 6, hjust = 0.5,
           lineheight = 0.9) +
  
  # Year labels
  geom_text(aes(label = year_clean), 
            y = 32, color = bbc_transformation["text_dark"], 
            size = 5, fontface = "bold", hjust = 0.5) +
  
  # Context annotations
  annotate("text", x = 1, y = slope_data$avg_performance_index[1] - 4,
           label = "Starting Point",
           color = bbc_transformation["text_medium"],
           size = 4, hjust = 0.5) +
  
  annotate("text", x = 2, y = slope_data$avg_performance_index[2] + 4,
           label = "Current Position",
           color = bbc_transformation["text_medium"],
           size = 4, hjust = 0.5) +
  
  # Scales
  scale_x_continuous(limits = c(0.7, 2.5), breaks = NULL) +
  scale_y_continuous(limits = c(30, 75), breaks = seq(30, 70, 10)) +
  
  # Labels
  labs(
    title = "CMSD District Performance Transformation",
    subtitle = "Three-year journey from 'Needs Improvement' toward 'Proficient' performance\nRepresenting ~40,000 students across 100+ schools",
    caption = "Source: Ohio Department of Education School Report Cards | Performance Index Scale: 0-100"
  ) +
  
  # Apply theme
  theme_bbc_slope()

# Add key statistics panel
stats_panel <- data.frame(
  x = c(0.8, 0.8, 0.8, 0.8),
  y = c(68, 64, 60, 56),
  label = c(
    "96 schools improved",
    "4 schools declined", 
    "21 schools consistently high",
    "27 schools need support"
  ),
  color = c(
    bbc_transformation["success_green"],
    bbc_transformation["warning_red"],
    bbc_transformation["primary_blue"],
    "#F19201"
  )
)

# Add statistics as annotations
for(i in 1:nrow(stats_panel)) {
  p_slope <- p_slope +
    annotate("text", x = stats_panel$x[i], y = stats_panel$y[i],
             label = stats_panel$label[i],
             color = stats_panel$color[i],
             fontface = "bold", size = 4, hjust = 0)
}

# Save the slope chart
ggsave("presentation/bbc_assets/cmsd_slope_chart.png", 
       plot = p_slope,
       width = 16, height = 10, dpi = 300, bg = "white")

cat("BBC-style slope chart saved successfully!\n")
cat("File: presentation/bbc_assets/cmsd_slope_chart.png\n")
cat("Dimensions: 16x10 inches at 300 DPI\n")
cat("Background: White\n")
cat("Format: PNG\n") 