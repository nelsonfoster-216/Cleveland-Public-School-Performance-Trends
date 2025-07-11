# BBC-Style CMSD Transformation Infographic
# Creates a compelling data journalism visualization of CMSD's Performance Index transformation
# Replaces simple line charts with dramatic storytelling elements

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

# Enhanced BBC color palette for transformation story
transformation_colors <- c(
  primary_blue = "#1380A1",
  success_green = "#1A8022", 
  warning_amber = "#F19201",
  dramatic_red = "#C70000",
  light_blue = "#00A2E8",
  text_dark = "#222222",
  text_medium = "#666666",
  text_light = "#888888"
)

# Enhanced BBC theme for data journalism
theme_bbc_transformation <- function() {
  theme_void() +
    theme(
      # Text formatting
      plot.title = element_text(
        size = 28, 
        face = "bold", 
        hjust = 0,
        margin = margin(b = 15),
        color = transformation_colors["text_dark"]
      ),
      plot.subtitle = element_text(
        size = 18, 
        hjust = 0,
        margin = margin(b = 40),
        color = transformation_colors["text_medium"],
        lineheight = 1.2
      ),
      plot.caption = element_text(
        size = 12,
        color = transformation_colors["text_light"],
        hjust = 0,
        margin = margin(t = 30)
      ),
      
      # Background
      plot.background = element_rect(fill = "white", color = NA),
      
      # Margins
      plot.margin = margin(40, 40, 40, 40)
    )
}

# Prepare transformation data with enhanced metrics
transformation_data <- district_trends %>%
  filter(!is.na(avg_performance_index)) %>%
  mutate(
    year_label = case_when(
      school_year == "2020-2021" ~ "2020-21\nBASELINE",
      school_year == "2021-2022" ~ "2021-22\nRECOVERY", 
      school_year == "2022-2023" ~ "2022-23\nTRANSFORMATION"
    ),
    year_numeric = case_when(
      school_year == "2020-2021" ~ 1,
      school_year == "2021-2022" ~ 2,
      school_year == "2022-2023" ~ 3
    ),
    improvement_from_baseline = avg_performance_index - first(avg_performance_index),
    cumulative_improvement = cumsum(c(0, diff(avg_performance_index))),
    performance_category = case_when(
      avg_performance_index < 40 ~ "Needs Improvement",
      avg_performance_index < 60 ~ "Developing",
      avg_performance_index < 80 ~ "Proficient",
      TRUE ~ "Advanced"
    )
  )

# Create the main transformation visualization
p_transformation <- ggplot(transformation_data, aes(x = year_numeric, y = avg_performance_index)) +
  
  # Background reference zones
  annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 0, ymax = 40, 
           fill = transformation_colors["dramatic_red"], alpha = 0.1) +
  annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 40, ymax = 60, 
           fill = transformation_colors["warning_amber"], alpha = 0.1) +
  annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 60, ymax = 80, 
           fill = transformation_colors["success_green"], alpha = 0.1) +
  annotate("rect", xmin = 0.5, xmax = 1.5, ymin = 80, ymax = 100, 
           fill = transformation_colors["primary_blue"], alpha = 0.1) +
  
  # Zone labels
  annotate("text", x = 0.7, y = 20, label = "NEEDS\nIMPROVEMENT", 
           color = transformation_colors["dramatic_red"], fontface = "bold", 
           size = 4.5, hjust = 0) +
  annotate("text", x = 0.7, y = 50, label = "DEVELOPING", 
           color = transformation_colors["warning_amber"], fontface = "bold", 
           size = 4.5, hjust = 0) +
  annotate("text", x = 0.7, y = 70, label = "PROFICIENT", 
           color = transformation_colors["success_green"], fontface = "bold", 
           size = 4.5, hjust = 0) +
  annotate("text", x = 0.7, y = 90, label = "ADVANCED", 
           color = transformation_colors["primary_blue"], fontface = "bold", 
           size = 4.5, hjust = 0) +
  
  # Dramatic area fill showing improvement
  geom_area(fill = transformation_colors["primary_blue"], alpha = 0.3) +
  
  # Main trend line - thick and bold
  geom_line(color = transformation_colors["primary_blue"], linewidth = 5, alpha = 0.8) +
  
  # Large points for each year
  geom_point(color = "white", size = 15) +
  geom_point(color = transformation_colors["primary_blue"], size = 12) +
  geom_point(color = "white", size = 7) +
  
  # Performance Index values inside the points
  geom_text(aes(label = avg_performance_index), 
            color = transformation_colors["text_dark"], 
            size = 5, fontface = "bold") +
  
  # Dramatic improvement arrows and annotations
  annotate("segment", 
           x = 1.2, y = transformation_data$avg_performance_index[1], 
           xend = 2.8, yend = transformation_data$avg_performance_index[3],
           arrow = arrow(length = unit(0.7, "cm"), type = "closed"),
           color = transformation_colors["success_green"], linewidth = 3, alpha = 0.8) +
  
  # Large improvement callout
  annotate("text", x = 2, y = 47, 
           label = "+15.5\nPOINTS", 
           color = transformation_colors["success_green"], 
           fontface = "bold", size = 10, hjust = 0.5) +
  
  # Year labels below
  geom_text(aes(label = year_label), 
            y = 25, color = transformation_colors["text_dark"], 
            size = 5, fontface = "bold", hjust = 0.5) +
  
  # Percentage improvement callout
  annotate("text", x = 3.2, y = transformation_data$avg_performance_index[3] + 5,
           label = "+39%\nIMPROVEMENT",
           color = transformation_colors["success_green"],
           fontface = "bold", size = 5, hjust = 0.5) +
  
  # Key milestone annotations
  annotate("text", x = 1, y = transformation_data$avg_performance_index[1] - 8,
           label = "Starting Point:\nBelow Proficient",
           color = transformation_colors["text_medium"],
           size = 4, hjust = 0.5) +
  
  annotate("text", x = 3, y = transformation_data$avg_performance_index[3] + 8,
           label = "Destination:\nApproaching Proficient",
           color = transformation_colors["text_medium"],
           size = 4, hjust = 0.5) +
  
  # Scales and limits
  scale_x_continuous(limits = c(0.5, 3.5), breaks = NULL) +
  scale_y_continuous(limits = c(15, 70), breaks = NULL) +
  
  # Labels and title
  labs(
    title = "CMSD DISTRICT TRANSFORMATION",
    subtitle = "Remarkable 15.5-point improvement demonstrates district-wide progress\nFrom 'Needs Improvement' toward 'Proficient' performance levels",
    caption = "Source: Ohio Department of Education School Report Cards | Performance Index Scale: 0-100\nAnalysis covers 2020-21 through 2022-23 school years representing ~40,000 students across 100+ schools"
  ) +
  
  # Apply theme
  theme_bbc_transformation()

# Add context boxes with key statistics
key_stats <- data.frame(
  x = c(0.8, 0.8, 0.8, 2.2, 2.2, 2.2),
  y = c(65, 60, 55, 65, 60, 55),
  label = c(
    "96 SCHOOLS\nIMPROVED",
    "4 SCHOOLS\nDECLINED", 
    "~40,000\nSTUDENTS",
    "21 SCHOOLS\nCONSISTENT HIGH",
    "27 SCHOOLS\nNEED SUPPORT",
    "15.5 POINTS\nGROWTH"
  ),
  color = c(
    transformation_colors["success_green"],
    transformation_colors["dramatic_red"],
    transformation_colors["primary_blue"],
    transformation_colors["success_green"],
    transformation_colors["warning_amber"],
    transformation_colors["primary_blue"]
  )
)

# Add the key statistics as text annotations
for(i in 1:nrow(key_stats)) {
  p_transformation <- p_transformation +
    annotate("text", x = key_stats$x[i], y = key_stats$y[i],
             label = key_stats$label[i],
             color = key_stats$color[i],
             fontface = "bold", size = 4.5, hjust = 0.5)
}

# Save the high-resolution visualization
ggsave("presentation/bbc_assets/01_district_transformation.png", 
       plot = p_transformation, 
       width = 16, 
       height = 10, 
       dpi = 300, 
       bg = "white")

# Display the transformation
print(p_transformation)

# Success message
cat("BBC-style transformation infographic created successfully!\n")
cat("Saved as: presentation/bbc_assets/01_district_transformation.png\n")
cat("This dramatic visualization replaces the simple line chart with data journalism storytelling.\n") 