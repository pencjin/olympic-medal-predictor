library(shiny)
library(tidyverse)
library(tidymodels)
library(broom)
library(DT)

# Load and preprocess the Olympics dataset
olympics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-08-06/olympics.csv')

# Feature engineering
olympics <- olympics %>%
  filter(!is.na(age), !is.na(weight), !is.na(height), !is.na(medal)) %>%
  group_by(id, year) %>%
  mutate(total_medals_athlete_olympics = sum(!is.na(medal))) %>%
  ungroup() %>%
  distinct(id, year, .keep_all = TRUE) %>%
  mutate(city_noc = case_when(
    year == 2000 & season == "Summer" ~ "AUS",
    year == 2004 & season == "Summer" ~ "GRE",
    year == 2008 & season == "Summer" ~ "CHN",
    year == 2012 & season == "Summer" ~ "GBR",
    year == 2016 & season == "Summer" ~ "BRA",
    year == 1996 & season == "Summer" ~ "USA",
    TRUE ~ NA_character_
  )) %>%
  mutate(
    host_country = ifelse(noc == city_noc, "yes", "no"),
    top_5_ever = ifelse(noc %in% c("AUS", "CAN", "CHN", "FIN", "GBR", "GER", "ITA", "NOR", "RUS", "SWE", "USA"), 1, 0)
  ) %>%
  group_by(noc, year) %>%
  mutate(
    total_events_country_year = n_distinct(event),
    total_athletes_country_year = n_distinct(id)
  ) %>%
  ungroup()

# Models
model3 <- lm(total_medals_athlete_olympics ~ age * host_country + height * host_country + weight * host_country, data = olympics)
modeld <- lm(total_medals_athlete_olympics ~ total_events_country_year + total_athletes_country_year + top_5_ever, data = olympics)

# UI
ui <- fluidPage(
  titlePanel("Olympic Medal Predictor Platform"),
  tabsetPanel(
    tabPanel("🎯 Medal Predictor (Athlete)",
             sidebarLayout(
               sidebarPanel(
                 selectInput("year", "Select Olympic Year:", choices = sort(unique(olympics$year)), selected = 2016),
                 numericInput("age", "Athlete Age:", value = 25),
                 numericInput("height", "Height (cm):", value = 175),
                 numericInput("weight", "Weight (kg):", value = 70),
                 selectInput("host", "Is Athlete from Host Country?", choices = c("yes", "no")),
                 hr(),
                 selectInput("var_x", "Plot Variable vs Medals:", choices = c("age", "height", "weight"))
               ),
               mainPanel(
                 h4("Predicted Total Medals (Athlete Model):"),
                 textOutput("prediction"),
                 h4("Model Formula"),
                 verbatimTextOutput("modelformula"),
                 h4("Dynamic Scatter Plot"),
                 plotOutput("dynamicPlot"),
                 h4("Host Country Comparison Plot"),
                 plotOutput("scatter")
               )
             )
    ),
    
    tabPanel("📈 Medal Predictor (Country-level Final Model)",
             sidebarLayout(
               sidebarPanel(
                 numericInput("events", "Total Events Country Participated:", value = 100),
                 numericInput("athletes", "Total Athletes from Country:", value = 300),
                 selectInput("top5", "Is Country Historically Top 5?:", choices = c("yes" = 1, "no" = 0))
               ),
               mainPanel(
                 h4("Predicted Total Medals per Athlete (Final Model):"),
                 textOutput("final_prediction"),
                 h4("Model Explanation"),
                 p("This model predicts the average medal count per athlete based on country-level factors. It includes total number of athletes, events participated in, and whether the country is historically top 5 (from 2000–2016)."),
                 p("Equation: 0.142 − 0.00126 * Events + 0.00112 * Athletes + 0.0802 * Top5"),
                 p("Summary: The factors influencing medal count of this model include the number of athletes per country, the number of events per country, and historical performance (Top 5 Ever status). Countries with a higher number of athletes perform better overall, while those in countries that have been top 5 tend to see fewer medals per athlete, possibly due to greater competition. The effect of the number of events suggests that increased competition from more events can dilute medal outcomes.")
               )
             )
    ),
    
    tabPanel("📊 Country Medal Trends",
             sidebarLayout(
               sidebarPanel(
                 selectInput("country_select", "Choose Country:", choices = sort(unique(olympics$noc)), selected = "USA")
               ),
               mainPanel(
                 h4("Medal Trend (Includes both Summer and Winter Olympics):"),
                 plotOutput("trend_plot")
               )
             )
    ),
    
    tabPanel("🗂️ Upload CSV for Prediction",
             sidebarLayout(
               sidebarPanel(
                 fileInput("file_upload", "Upload CSV File (with columns: age, height, weight, host_country):")
               ),
               mainPanel(
                 h4("Batch Prediction Results"),
                 DTOutput("prediction_table")
               )
             )
    )
  )
)

# Server
server <- function(input, output) {
  
  filtered_data <- reactive({
    olympics %>% filter(year == input$year)
  })
  
  output$prediction <- renderText({
    newdata <- tibble(
      age = input$age,
      height = input$height,
      weight = input$weight,
      host_country = input$host
    )
    pred <- predict(model3, newdata)
    paste0("Predicted Medals: ", round(pred, 4))
  })
  
  output$final_prediction <- renderText({
    newdata <- tibble(
      total_events_country_year = input$events,
      total_athletes_country_year = input$athletes,
      top_5_ever = as.numeric(input$top5)
    )
    pred <- predict(modeld, newdata)
    paste0("Predicted Medals per Athlete: ", round(pred, 4))
  })
  
  output$modelformula <- renderPrint({
    cat("Model: total_medals ~ age * host_country + height * host_country + weight * host_country")
  })
  
  output$dynamicPlot <- renderPlot({
    ggplot(filtered_data(), aes_string(x = input$var_x, y = "total_medals_athlete_olympics")) +
      geom_point(alpha = 0.5, color = "#0072B2") +
      geom_smooth(method = "lm", se = FALSE, color = "red") +
      theme_minimal()
  })
  
  output$scatter <- renderPlot({
    ggplot(filtered_data(), aes(x = height, y = total_medals_athlete_olympics, color = host_country)) +
      geom_point(alpha = 0.4) +
      labs(title = "Height vs. Medals by Host Country") +
      theme_minimal()
  })
  
  output$trend_plot <- renderPlot({
    olympics %>%
      filter(noc == input$country_select, !is.na(medal)) %>%
      group_by(year) %>%
      summarise(total_medals = n()) %>%
      ggplot(aes(x = year, y = total_medals)) +
      geom_line(color = "darkgreen") +
      geom_point(size = 2) +
      labs(title = paste("Total Medals for", input$country_select),
           x = "Year", y = "Total Medals") +
      theme_minimal()
  })
  
  output$prediction_table <- renderDT({
    req(input$file_upload)
    filedata <- read.csv(input$file_upload$datapath)
    validate(
      need(all(c("age", "height", "weight", "host_country") %in% names(filedata)),
           "CSV must contain columns: age, height, weight, host_country")
    )
    filedata$predicted_medals <- round(predict(model3, newdata = filedata), 4)
    datatable(filedata)
  })
}

# Run App
shinyApp(ui = ui, server = server)
