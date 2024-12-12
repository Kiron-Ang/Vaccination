# Load required packages
packages <- c("shiny", "RSocrata", "dplyr")

# Check if required packages are installed, and install missing ones
new_packages <- setdiff(packages, installed.packages()[,"Package"])
if(length(new_packages)) install.packages(new_packages)

# Load all required packages
invisible(lapply(packages, require, character.only = TRUE))

# Define a dataset of U.S. states and their corresponding nicknames
state_data <- data.frame(
  state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", 
            "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", 
            "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", 
            "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
            "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", 
            "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", 
            "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", 
            "Wisconsin", "Wyoming", "District of Columbia"),
  nickname = c("Alabamian", "Alaskan", "Arizonan", "Arkansan", "Californian", "Coloradan", 
               "Connecticuter", "Delawarean", "Floridian", "Georgian", "Hawaiian", "Idahoan", 
               "Illinoisan", "Indianan", "Iowan", "Kansasan", "Kentuckian", "Louisianan", "Mainer", 
               "Marylander", "Massachusettsan", "Michigander", "Minnesotan", "Mississippian", 
               "Missourian", "Montanan", "Nebraskan", "Nevadan", "New Hampshirite", "New Jerseyan", 
               "New Mexican", "New Yorker", "North Carolinian", "North Dakotan", "Ohioan", 
               "Oklahoman", "Oregonian", "Pennsylvanian", "Rhode Islander", "South Carolinian", 
               "South Dakotan", "Tennessean", "Texan", "Utahan", "Vermonter", "Virginian", 
               "Washingtonian", "West Virginian", "Wisconsiner", "Wyomingite", "Washingtonian")
)

# Create a named vector to quickly look up nicknames by state
state_nicknames <- setNames(state_data$nickname, state_data$state)

# Function to fetch vaccination data from the CDC
fetch_data <- function(url, vaccine_type = NULL, vaccine_dose = NULL, year_season = NULL) {
  # Read data from the provided URL (using Socrata API)
  data <- read.socrata(url)
  
  # Ensure that coverage estimate is numeric
  data$coverage_estimate <- as.numeric(data$coverage_estimate)
  
  # Predefined filters for vaccine data (age group, geography, etc.)
  filters <- list(
    vaccine = c("HPV", "Tetanus", "≥1 Dose MenACWY", "Seasonal Influenza"),
    dimension_type = "Age",
    dimension = "13-17 Years",
    geography_type = "States/Local Areas",
    geography = state_data$state,
    year_season = year_season
  )
  
  # Apply the filters to the data
  data <- data %>%
    filter(
      vaccine %in% filters$vaccine,
      dimension_type == filters$dimension_type,
      dimension == filters$dimension,
      geography_type == filters$geography_type,
      geography %in% filters$geography,
      year_season == year_season
    )
  
  # If a specific vaccine type is specified, further filter the data
  if (!is.null(vaccine_type)) data <- data %>% filter(vaccine == vaccine_type)
  
  # If a specific vaccine dose is specified, further filter the data
  if (!is.null(vaccine_dose)) data <- data %>% filter(dose == vaccine_dose)
  
  # Return the filtered data
  return(data)
}

# Fetch vaccination data for different vaccine types and doses
hpv = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "HPV", "≥1 Dose, Males and Females", "2023")
menacwy = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "≥1 Dose MenACWY", NULL, "2023")
tetanus = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "Tetanus", "≥1 Dose Td or Tdap", "2023")
influenza = fetch_data("https://data.cdc.gov/resource/vh55-3he6.json", "Seasonal Influenza", NULL, "2023-24")

# Read state-specific immunization requirements and exemption policies data
phase_1 = read.csv("https://github.com/Kiron-Ang/Vaccination/blob/main/phase_1.csv?raw=true")

# Define the UI for the Shiny app
ui = fluidPage(
  tags$head(
    # Custom CSS for styling the circles used for vaccination coverage display
    tags$style(HTML("
      .circle { width: 30px; height: 30px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 12px; font-weight: bold; border: 1px solid black; background-color: transparent; }
      .circle-container { display: grid; grid-template-columns: repeat(10, 1fr); gap: 10px; width: auto; height: auto; justify-content: center; align-items: center; position: relative; }
      .circle-container .circle { margin: 0; }
    "))
  ),
  
  # Title of the app
  titlePanel("Vaccination Coverage in the United States"),
  
  # Sidebar layout with a state selector and vaccine type selector
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "Select a State:", state_data$state, selected = "Texas"),
      selectInput("vaccine", "Select a Vaccine:", 
                  c("HPV, ≥1 Dose, Males and Females", "Tetanus, ≥1 Dose Td or Tdap", "≥1 Dose MenACWY", "Seasonal Influenza"), 
                  selected = "HPV, ≥1 Dose, Males and Females")
    ),
    
    # Main panel displaying vaccine coverage info and a circle chart
    mainPanel(
      div(style = "position: absolute; top: 20px; right: 20px; font-size: 24px; font-weight: bold;", textOutput("coverage_text")),
      div(style = "display: flex; justify-content: center; align-items: center; position: relative; height: 500px;", uiOutput("circle_ui")),
      uiOutput("state_info")
    )
  )
)

# Define the server function to render the app's outputs
server = function(input, output) {
  
  # Reactive expression to get the state nickname based on selected state
  state_nickname = reactive({ state_nicknames[input$state] })
  
  # Render the state immunization information and exemption policies dynamically
  output$state_info = renderUI({
    state_data = phase_1 %>% filter(state == input$state)
    div(style = "background-color: #f9f9f9; padding: 15px; border-radius: 8px; font-size: 14px;", 
        tags$h4(paste(input$state, " Immunization Requirements & Exemption Policies:")), 
        tags$ul(
          tags$li(paste("HPV Vaccine Required: ", state_data$hpv_required)), 
          tags$li(paste("HPV Vaccine Recommended: ", state_data$hpv_recommended)),
          tags$li(paste("MenACWY Vaccine Required: ", state_data$hpv_required)), 
          tags$li(paste("MenACWY Vaccine Recommended: ", state_data$menacwy_recommended)),
          tags$li(paste("Tetanus Vaccine Required: ", state_data$tetanus_required)), 
          tags$li(paste("Tetanus Vaccine Recommended: ", state_data$tetanus_recommended)),
          tags$li(paste("Influenza Vaccine Required: ", state_data$influenza_required)), 
          tags$li(paste("Influenza Vaccine Recommended: ", state_data$influenza_recommended)),
          tags$li(paste("Medical Exemptions Allowed: ", state_data$medical_exemption)),
          tags$li(paste("Religious Exemptions Allowed: ", state_data$religious_exemption)),
          tags$li(paste("Philosophical Exemptions Allowed: ", state_data$philosophical_exemption))
        )
    )
  })
  
  # Render the circle UI to represent vaccination coverage as a grid of circles
  output$circle_ui = renderUI({
    vaccine_data = switch(input$vaccine,
                          "HPV, ≥1 Dose, Males and Females" = hpv,
                          "Tetanus, ≥1 Dose Td or Tdap" = tetanus,
                          "≥1 Dose MenACWY" = menacwy,
                          "Seasonal Influenza" = influenza)
    state_data = vaccine_data %>% filter(geography == input$state)
    coverage = ifelse(nrow(state_data) > 0, round(state_data$coverage_estimate[1], 0), NA)
    
    # Define the total number of circles to display in the grid
    num_circles = 100
    circle_percentage = 0
    circle_html = div(class = "circle-container")
    
    # Loop to generate circles representing vaccination coverage
    for (i in 1:num_circles) {
      color = ifelse(circle_percentage >= coverage, "blue", "orange")
      circle_html = tagAppendChild(circle_html, div(class = "circle", style = paste("background-color: ", color, ";")))
      circle_percentage = circle_percentage + 1
    }
    
    circle_html
  })
  
  # Render the coverage percentage text
  output$coverage_text = renderText({
    vaccine_data = switch(input$vaccine,
                          "HPV, ≥1 Dose, Males and Females" = hpv,
                          "Tetanus, ≥1 Dose Td or Tdap" = tetanus,
                          "≥1 Dose MenACWY" = menacwy,
                          "Seasonal Influenza" = influenza)
    state_data = vaccine_data %>% filter(geography == input$state)
    coverage = ifelse(nrow(state_data) > 0, state_data$coverage_estimate[1], NA)
    paste("Vaccinated ", state_nickname(), "s in 2023: ", coverage, "%", sep = "")
  })
}

# Run the Shiny app with the defined UI and server
shinyApp(ui = ui, server = server)