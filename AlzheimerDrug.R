# check if not installed
required_packages <- c("shiny", "shinythemes", "DT", "jsonlite")
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
    }
  }
}


library(shiny)
library(shinythemes)
library(DT)
library(jsonlite)

# Read parameters from JSON file
params <- fromJSON("Params/params.json")

# Define UI for the app
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  
  # Custom CSS for logo and styling
  tags$head(
    tags$style(HTML("
      .logo { display: block; margin: 0 auto 10px auto; width: 200px; }
      h3 { color: #2c3e50; }
      .sidebar { padding-top: 0; }
      .main-panel { padding-top: 0; }
    "))
  ),
  
  # Title of the App
  titlePanel("NeuroGuard for Alzheimer's Disease"),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      tags$img(src = "NeuroGuard.png", class = "logo"),
      # Team number display (updated dynamically)
      uiOutput("team_display"),
      numericInput("sample_size", 
                   label = "Enter Sample Size:", 
                   value = params$sample_size, 
                   min = 10),
      actionButton("generate", "Generate Sample"),
      actionButton("compute_stats", "Compute Sample Statistics"),
      downloadButton("downloadData", "Download Data as CSV"),
      width = 3
    ),
    
    # Main panel
    mainPanel(
      h3("Sampled Data of Capsule Ingredients (mg)"),
      DTOutput("sample_table"),
      h3("Sample Statistics"),
      tableOutput("sample_stats"),
      width = 9
    )
  )
)

# Define server logic for the app
server <- function(input, output, session) {
  
  # Show modal dialog for team number input when app starts
  showModal(modalDialog(
    title = "Enter Team Number",
    numericInput("team_number", "Please enter your team number (1-6):", value = 1, min = 1, max = 6),
    footer = tagList(
      actionButton("submit_team", "Submit")
    )
  ))
  
  # Reactive value to store the team number
  team_num <- reactiveVal(NULL)
  
  # Handle team number submission
  observeEvent(input$submit_team, {
    if (!is.null(input$team_number) && input$team_number >= 1 && input$team_number <= 6) {
      team_num(input$team_number)
      removeModal()
    } else {
      showNotification("Please enter a valid team number between 1 and 6.", type = "error")
    }
  })
  
  # Display team number in sidebar
  output$team_display <- renderUI({
    req(team_num())
    tags$p(paste("Team Number:", team_num()))
  })
  
  # Reactive expression to generate sample with original progress animation
  sampled_data <- eventReactive(input$generate, {
    req(team_num())
    sample_size <- input$sample_size
    
    # Original progress animation
    withProgress(message = "Analyzing capsules...", detail = "Please wait...", value = 0, {
      for (i in 1:10) {
        incProgress(0.1)
        Sys.sleep(params$waiting_time / 10)  # Spread waiting time over 10 steps
      }
      
      # Generate random values using params
      set.seed(input$team_number)
      memorin_values <- rnorm(sample_size, mean = params$memorin$mean, sd = params$memorin$sd)
      galantamine_values <- rnorm(sample_size, mean = params$galantamine$mean, sd = params$galantamine$sd)
      vitamin_e_values <- rnorm(sample_size, mean = params$vitamin_e$mean, sd = params$vitamin_e$sd)
      
      # Add time element
      collection_time <- Sys.time() + runif(sample_size, -3600, 3600)
      
      # Create data frame
      data <- data.frame(
        Capsule = 1:sample_size,
        Collection_Time = format(collection_time, "%Y-%m-%d %H:%M:%S"),
        Memorin = round(memorin_values, 2),
        Galantamine = round(galantamine_values, 2),
        Vitamin.E = round(vitamin_e_values, 2)
      )
    })
    
    data
  })
  
  # Display the generated sample in a DT table with 100 rows by default
  output$sample_table <- renderDT({
    data <- sampled_data()
    datatable(data, options = list(pageLength = 100)) %>%
      formatStyle("Memorin", 
                  backgroundColor = styleInterval(c(params$memorin$min_range, params$memorin$max_range), 
                                                  c("red", "white", "red"))) %>%
      formatStyle("Galantamine", 
                  backgroundColor = styleInterval(c(params$galantamine$min_range, params$galantamine$max_range), 
                                                  c("red", "white", "red"))) %>%
      formatStyle("Vitamin.E", 
                  backgroundColor = styleInterval(c(params$vitamin_e$min_range, params$vitamin_e$max_range), 
                                                  c("red", "white", "red")))
  })
  
  # Reactive value to store whether stats should be shown
  show_stats <- reactiveVal(FALSE)
  
  # Compute and show stats only when button is clicked
  observeEvent(input$compute_stats, {
    show_stats(TRUE)
  })
  
  # Generate sample statistics only if button is clicked
  output$sample_stats <- renderTable({
    req(show_stats())
    data <- sampled_data()
    stats <- data.frame(
      Ingredient = c("Memorin", "Galantamine", "Vitamin.E"),
      Mean = round(c(mean(data$Memorin), mean(data$Galantamine), mean(data$Vitamin.E)), 2),
      SD = round(c(sd(data$Memorin), sd(data$Galantamine), sd(data$Vitamin.E)), 2),
      Min = round(c(min(data$Memorin), min(data$Galantamine), min(data$Vitamin.E)), 2),
      Max = round(c(max(data$Memorin), max(data$Galantamine), max(data$Vitamin.E)), 2)
    )
    stats
  })
  
  # Download functionality
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("sample_data_team_", team_num(), "_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(sampled_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)