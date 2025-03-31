library(shiny)
library(tidyverse)
library(tidymodels)
library(broom)
library(DT)

# Load and preprocess the Olympics dataset
olympics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-08-06/olympics.csv')

# Clean and engineer features
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
  mutate(host_country = ifelse(noc == city_noc, "yes", "no"))

# Fit the model
model3 <- lm(total_medals_athlete_olympics ~ age * host_country + height * host_country + weight * host_country, data = olympics)

# Unique years and countries
years <- sort(unique(olympics$year))
countries <- sort(unique(olympics$noc))

# UI
ui <- fluidPage(
  titlePanel("Olympic Medal Predictor Platform"),
  tabsetPanel(
    tabPanel("🎯 Medal Predictor",
             sidebarLayout(
               sidebarPanel(
                 selectInput("year", "Select Olympic Year:", choices = years, selected = 2016),
                 numericInput("age", "Athlete Age:", value = 25),
                 numericInput("height", "Height (cm):", value = 175),
                 numericInput("weight", "Weight (kg):", value = 70),
                 selectInput("host", "Is Athlete from Host Country?", choices = c("yes", "no")),
                 hr(),
                 selectInput("var_x", "Plot Variable vs Medals:", choices = c("age", "height", "weight"))
               ),
               mainPanel(
                 h4("Predicted Total Medals:"),
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
    
    tabPanel("📊 Country Medal Trends",
             sidebarLayout(
               sidebarPanel(
                 selectInput("country_select", "Choose Country:", choices = countries, selected = "USA")
               ),
               mainPanel(
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