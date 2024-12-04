# https://8zjn1m-kiron-ang.shinyapps.io/shiny_app

packages = c("shiny", "RSocrata")
new_packages = packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = 'https://cloud.r-project.org/')
lapply(packages, library, character.only = TRUE)

data = read.socrata("https://data.cdc.gov/resource/ee48-w5t6.json")
data$coverage_estimate = as.numeric(data$coverage_estimate)
data = data[data$vaccine %in% c("HPV", "Tetanus", "≥1 Dose MenACWY"), ]
data = data[data$dimension_type == "Age", ]
data = data[data$dimension == "13-17 Years", ]
data = data[data$geography_type == "States/Local Areas", ]
states = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", 
           "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", 
           "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
           "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", 
           "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", 
           "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", 
           "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", 
           "District of Columbia")
data = data[data$geography %in% states, ]
data = data[data$year_season == "2023", ]

hpv = data[data$vaccine == "HPV" & data$dose == "≥1 Dose, Males and Females", ]
menacwy = data[data$vaccine == "≥1 Dose MenACWY", ]
tetanus = data[data$vaccine == "Tetanus" & data$dose == "≥1 Dose Td or Tdap", ]

influenza = read.socrata("https://data.cdc.gov/resource/vh55-3he6.json")
influenza$coverage_estimate = as.numeric(influenza$coverage_estimate)
influenza = influenza[influenza$vaccine == "Seasonal Influenza", ]
influenza = influenza[influenza$dimension_type == "Age", ]
influenza = influenza[influenza$geography_type == "States/Local Areas", ]
influenza = influenza[influenza$geography %in% states & influenza$month == "5" & influenza$year_season == "2023-24", ]

ui = fluidPage(

  tags$head(
    tags$style(HTML("
      .circle {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 12px;
        font-weight: bold;
        border: 3px solid black;
        background-color: transparent;
      }

      .circle-container {
        display: grid;
        grid-template-columns: repeat(10, 1fr);
        gap: 10px; 
        width: auto; 
        height: auto; 
        justify-content: center;
        align-items: center;
        position: relative;
      }

      .circle-container .circle {
        margin: 0; 
      }
    ")
  ),

  titlePanel(
    div(style = "text-align: center;", 
        h1("Modeling the Effect of Vaccination", style = "margin-bottom: 0;"), 
        h1("on Disease Spread Using Real USA Vaccination Coverage Estimates", style = "margin-top: 0;")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "state",
        label = "Select a State:",
        choices = states,
        selected = "Texas"
      ),
      selectInput(
        inputId = "vaccine",
        label = "Select a Vaccine:",
        choices = c("HPV, ≥1 Dose, Males and Females", "Tetanus, ≥1 Dose Td or Tdap", "≥1 Dose MenACWY", "Seasonal Influenza"),
        selected = "HPV, ≥1 Dose, Males and Females"
      )
    ),
    mainPanel(
      div(
        style = "position: absolute; top: 20px; right: 20px; font-size: 24px; font-weight: bold;", 
        textOutput("coverage_text")
      ),
      div(
        style = "display: flex; justify-content: center; align-items: center; position: relative; height: 500px;",
        uiOutput("circle_ui")
      )
    )
  ),

  )
)

server = function(input, output) {
  state_nickname = reactive({
    state = input$state
    switch(state,
      "Alabama" = "Alabamian", "Alaska" = "Alaskan", "Arizona" = "Arizonan", "Arkansas" = "Arkansan", 
      "California" = "Californian", "Colorado" = "Coloradan", "Connecticut" = "Connecticuter", 
      "Delaware" = "Delawarean", "Florida" = "Floridian", "Georgia" = "Georgian", "Hawaii" = "Hawaiian", 
      "Idaho" = "Idahoan", "Illinois" = "Illinoisan", "Indiana" = "Indianan", "Iowa" = "Iowan", 
      "Kansas" = "Kansasan", "Kentucky" = "Kentuckian", "Louisiana" = "Louisianan", "Maine" = "Mainer", 
      "Maryland" = "Marylander", "Massachusetts" = "Massachusettsan", "Michigan" = "Michigander", 
      "Minnesota" = "Minnesotan", "Mississippi" = "Mississippian", "Missouri" = "Missourian", 
      "Montana" = "Montanan", "Nebraska" = "Nebraskan", "Nevada" = "Nevadan", "New Hampshire" = "New Hampshirite", 
      "New Jersey" = "New Jerseyan", "New Mexico" = "New Mexican", "New York" = "New Yorker", 
      "North Carolina" = "North Carolinian", "North Dakota" = "North Dakotan", "Ohio" = "Ohioan", 
      "Oklahoma" = "Oklahoman", "Oregon" = "Oregonian", "Pennsylvania" = "Pennsylvanian", 
      "Rhode Island" = "Rhode Islander", "South Carolina" = "South Carolinian", "South Dakota" = "South Dakotan", 
      "Tennessee" = "Tennessean", "Texas" = "Texan", "Utah" = "Utahan", "Vermont" = "Vermonter", 
      "Virginia" = "Virginian", "Washington" = "Washingtonian", "West Virginia" = "West Virginian", 
      "Wisconsin" = "Wisconsiner", "Wyoming" = "Wyomingite", "District of Columbia" = "Washingtonian"
    )
  })

  output$circle_ui = renderUI({
    state = input$state
    vaccine = input$vaccine
    nickname = state_nickname()

    vaccine_data = switch(vaccine,
      "HPV, ≥1 Dose, Males and Females" = hpv, 
      "Tetanus, ≥1 Dose Td or Tdap" = tetanus, 
      "≥1 Dose MenACWY" = menacwy,
      "Seasonal Influenza" = influenza
    )

    state_data = vaccine_data[vaccine_data$geography == state, ]
    coverage = ifelse(nrow(state_data) > 0, round(state_data$coverage_estimate[1], 0), NA)
    num_circles = 100
    circle_percentage = 0

    circle_html = div(class = "circle-container")

    for (i in 1:num_circles) {
      color <- ifelse(circle_percentage >= coverage, "blue", "orange")
      circle_html = tagAppendChild(circle_html, div(class = "circle", style = paste("background-color: ", color, ";")))
      circle_percentage = circle_percentage + 1
    }

    circle_html
  })

  output$coverage_text = renderText({
    state = input$state
    vaccine = input$vaccine
    nickname = state_nickname()

    vaccine_data = switch(vaccine,
      "HPV, ≥1 Dose, Males and Females" = hpv, 
      "Tetanus, ≥1 Dose Td or Tdap" = tetanus, 
      "≥1 Dose MenACWY" = menacwy,
      "Seasonal Influenza" = influenza
    )

    state_data = vaccine_data[vaccine_data$geography == state, ]

    coverage = ifelse(nrow(state_data) > 0, state_data$coverage_estimate[1], NA)
    paste("Vaccinated ", nickname, "s in 2023: ", coverage, "%", sep = "")
  })
}

shinyApp(ui = ui, server = server)