# Install and load packages
packages = c("shiny", "RSocrata", "dplyr")
new_packages = packages[!(packages %in% installed.packages()[,"Package"])]
if (length(new_packages)) install.packages(new_packages, repos = 'https://cloud.r-project.org/')
lapply(packages, library, character.only = TRUE)

# State list and nickname mapping
states = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", 
            "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", 
            "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
            "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", 
            "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", 
            "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", 
            "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", 
            "District of Columbia")

# Mapping state names to nicknames
state_nicknames = setNames(
  c("Alabamian", "Alaskan", "Arizonan", "Arkansan", "Californian", "Coloradan", "Connecticuter", 
    "Delawarean", "Floridian", "Georgian", "Hawaiian", "Idahoan", "Illinoisan", "Indianan", "Iowan", 
    "Kansasan", "Kentuckian", "Louisianan", "Mainer", "Marylander", "Massachusettsan", "Michigander", 
    "Minnesotan", "Mississippian", "Missourian", "Montanan", "Nebraskan", "Nevadan", "New Hampshirite", 
    "New Jerseyan", "New Mexican", "New Yorker", "North Carolinian", "North Dakotan", "Ohioan", 
    "Oklahoman", "Oregonian", "Pennsylvanian", "Rhode Islander", "South Carolinian", "South Dakotan", 
    "Tennessean", "Texan", "Utahan", "Vermonter", "Virginian", "Washingtonian", "West Virginian", 
    "Wisconsiner", "Wyomingite", "Washingtonian"), 
  states
)

# Fetch and clean data
fetch_data = function(url, vaccine_type = NULL, vaccine_dose = NULL, year_season = NULL) {
  data = read.socrata(url)
  data$coverage_estimate = as.numeric(data$coverage_estimate)
  data = data %>%
    filter(
      vaccine %in% c("HPV", "Tetanus", "≥1 Dose MenACWY", "Seasonal Influenza"),
      dimension_type == "Age", 
      dimension == "13-17 Years", 
      geography_type == "States/Local Areas",
      geography %in% states,
      year_season == year_season
    )
  if (!is.null(vaccine_type)) data = data %>% filter(vaccine == vaccine_type)
  if (!is.null(vaccine_dose)) data = data %>% filter(dose == vaccine_dose)
  return(data)
}

# HPV, MenACWY, Tetanus data
hpv = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "HPV", "≥1 Dose, Males and Females", "2023")
menacwy = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "≥1 Dose MenACWY", NULL, "2023")
tetanus = fetch_data("https://data.cdc.gov/resource/ee48-w5t6.json", "Tetanus", "≥1 Dose Td or Tdap", "2023")

# Influenza data
influenza = fetch_data("https://data.cdc.gov/resource/vh55-3he6.json", "Seasonal Influenza", NULL, "2023-24")

# UI definition
ui = fluidPage(
  tags$head(
    tags$style(HTML("
      .circle { width: 20px; height: 20px; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-size: 12px; font-weight: bold; border: 3px solid black; background-color: transparent; }
      .circle-container { display: grid; grid-template-columns: repeat(10, 1fr); gap: 10px; width: auto; height: auto; justify-content: center; align-items: center; position: relative; }
      .circle-container .circle { margin: 0; }
    "))
  ),
  titlePanel(
    div(style = "text-align: center;", 
        h1("Modeling the Effect of Vaccination", style = "margin-bottom: 0;"), 
        h1("on Disease Spread Using Real USA Vaccination Coverage Estimates", style = "margin-top: 0;")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "Select a State:", states, selected = "Texas"),
      selectInput("vaccine", "Select a Vaccine:", c("HPV, ≥1 Dose, Males and Females", "Tetanus, ≥1 Dose Td or Tdap", "≥1 Dose MenACWY", "Seasonal Influenza"), selected = "HPV, ≥1 Dose, Males and Females")
    ),
    mainPanel(
      div(style = "position: absolute; top: 20px; right: 20px; font-size: 24px; font-weight: bold;", textOutput("coverage_text")),
      div(style = "display: flex; justify-content: center; align-items: center; position: relative; height: 500px;", uiOutput("circle_ui"))
    )
  )
)

# Server logic
server = function(input, output) {
  
  state_nickname = reactive({ state_nicknames[input$state] })
  
  # Render circles
  output$circle_ui = renderUI({
    vaccine_data = switch(input$vaccine,
                           "HPV, ≥1 Dose, Males and Females" = hpv,
                           "Tetanus, ≥1 Dose Td or Tdap" = tetanus,
                           "≥1 Dose MenACWY" = menacwy,
                           "Seasonal Influenza" = influenza)
    
    state_data = vaccine_data %>% filter(geography == input$state)
    coverage = ifelse(nrow(state_data) > 0, round(state_data$coverage_estimate[1], 0), NA)
    num_circles = 100
    circle_percentage = 0

    circle_html = div(class = "circle-container")
    for (i in 1:num_circles) {
      color = ifelse(circle_percentage >= coverage, "blue", "orange")
      circle_html = tagAppendChild(circle_html, div(class = "circle", style = paste("background-color: ", color, ";")))
      circle_percentage = circle_percentage + 1
    }

    circle_html
  })

  # Display coverage text
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

# Run the Shiny app
shinyApp(ui = ui, server = server)