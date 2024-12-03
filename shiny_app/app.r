# Install required packages if they are not already installed
packages = c("shiny", "RSocrata")
new_packages = packages[!(packages %in% installed.packages()[,"Package"])] # Find packages not installed
if(length(new_packages)) install.packages(new_packages, repos = 'https://cloud.r-project.org/') # Install missing packages
lapply(packages, library, character.only = TRUE) # Load the packages

# Load vaccination data from the CDC's Socrata platform
data = read.socrata("https://data.cdc.gov/resource/ee48-w5t6.json") # Read HPV, Tetanus, MenACWY vaccination data
data$coverage_estimate = as.numeric(data$coverage_estimate) # Convert coverage_estimate to numeric
data = data[data$vaccine %in% c("HPV", "Tetanus", "≥1 Dose MenACWY"), ] # Filter by selected vaccines
data = data[data$dimension_type == "Age", ] # Filter by age dimension
data = data[data$dimension == "13-17 Years", ] # Filter by 13-17 years age group
data = data[data$geography_type == "States/Local Areas", ] # Filter by geography type
# List of states for filtering
states = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
            "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
            "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska",
            "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina",
            "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
            "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
            "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", "District of Columbia")
data = data[data$geography %in% states, ] # Filter by states
data = data[data$year_season == "2023", ] # Filter by the year 2023

# Separate the data by vaccine type
hpv = data[data$vaccine == "HPV" & data$dose == "≥1 Dose, Males and Females", ] # HPV vaccine data
menacwy = data[data$vaccine == "≥1 Dose MenACWY", ] # MenACWY vaccine data
tetanus = data[data$vaccine == "Tetanus" & data$dose == "≥1 Dose Td or Tdap", ] # Tetanus vaccine data

# Load seasonal influenza data from the CDC
influenza = read.socrata("https://data.cdc.gov/resource/vh55-3he6.json") # Read influenza vaccination data
influenza$coverage_estimate = as.numeric(influenza$coverage_estimate) # Convert coverage_estimate to numeric
influenza = influenza[influenza$vaccine == "Seasonal Influenza", ] # Filter by influenza vaccine
influenza = influenza[influenza$dimension_type == "Age", ] # Filter by age dimension
influenza = influenza[influenza$geography_type == "States/Local Areas", ] # Filter by geography type
influenza = influenza[influenza$geography %in% states & influenza$month == "5" & influenza$year_season == "2023-24", ] # Filter by geography, month, and year

# Define the user interface of the Shiny app
ui = fluidPage(
  titlePanel("Modeling the Effect of Vaccination on Disease Spread Using Real USA Vaccination Coverage Estimates"),
  sidebarLayout(
    sidebarPanel(
      # Dropdown to select a state
      selectInput(
        inputId = "state",
        label = "Select a State:",
        choices = states, # States list
        selected = "Texas" # Default selected state
      ),
      # Dropdown to select a vaccine
      selectInput(
        inputId = "vaccine",
        label = "Select a Vaccine:",
        choices = c("HPV", "Tetanus", "≥1 Dose MenACWY"), # Vaccine options
        selected = "HPV" # Default selected vaccine
      )
    ),
    mainPanel(
      # Display the circle representing vaccination coverage
      div(
        style = "display: flex; justify-content: center; align-items: center; height: 100vh;", 
        uiOutput("circle_ui") # UI element for displaying circle
      )
    )
  ),
  tags$head(
    # Define custom CSS for the circle appearance
    tags$style(HTML("
      @media (forced-colors: active) {
        #circle {
          border-radius: 50%;
          width: 200px;
          height: 200px;
          background-color: ButtonFace;
          border: 3px solid ButtonText;
        }
      }
    "))) # CSS for circle style
)

# Define the server logic of the Shiny app
server = function(input, output) {
  # Reactive expression to generate state nickname based on selection
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

  # Render the circle with vaccine coverage estimate
  output$circle_ui = renderUI({
    state = input$state
    vaccine = input$vaccine
    nickname = state_nickname()

    # Choose the correct dataset based on selected vaccine
    vaccine_data <- switch(vaccine,
      "HPV" = hpv,
      "Tetanus" = tetanus,
      "≥1 Dose MenACWY" = menacwy
    )

    # Filter data for the selected state
    state_data = vaccine_data[vaccine_data$geography == state, ]

    # Get the coverage estimate, handling cases where data is missing
    coverage = if (nrow(state_data) > 0) {
      round(state_data$coverage_estimate[1], 2)
    } else {
      "No Data"
    }

    # Choose a circle color based on state
    circle_color = switch(state,
      "Texas" = "red", "Florida" = "blue", "California" = "green", "New York" = "purple", 
      "Illinois" = "orange", "Alabama" = "yellow", "Michigan" = "pink", "Ohio" = "brown", 
      "Georgia" = "cyan", "North Carolina" = "magenta", "Virginia" = "violet", 
      "South Carolina" = "lightblue", "Tennessee" = "lightgreen", "Nevada" = "indigo", 
      "Hawaii" = "coral", "Arizona" = "teal", "Washington" = "peachpuff", "Missouri" = "lightyellow", 
      "Minnesota" = "fuchsia", "Kansas" = "gold", "Colorado" = "tan", "Louisiana" = "darkolivegreen", 
      "Indiana" = "peru", "Maine" = "salmon", "Maryland" = "dodgerblue", "Mississippi" = "crimson", 
      "Montana" = "springgreen", "Nebraska" = "lawngreen", "North Dakota" = "midnightblue", 
      "South Dakota" = "seashell", "Wyoming" = "limegreen", "Oklahoma" = "chocolate", 
      "New Jersey" = "slateblue", "Connecticut" = "lightpink", "Kentucky" = "lightseagreen", 
      "Delaware" = "thistle", "Rhode Island" = "beige", "West Virginia" = "hotpink", 
      "Utah" = "yellowgreen", "Oregon" = "indianred", "Alaska" = "yellow", "Idaho" = "orchid", 
      "California" = "salmon", "New Mexico" = "plum", "Illinois" = "ivory", "Ohio" = "khaki", 
      "Michigan" = "darkorange", "Pennsylvania" = "turquoise", "Vermont" = "mistyrose", 
      "Massachusetts" = "powderblue", "New Hampshire" = "wheat", "Wisconsin" = "lightskyblue", 
      "Iowa" = "green", "Montana" = "gray", "Wyoming" = "lightcoral", "Tennessee" = "firebrick", 
      "Colorado" = "forestgreen", "District of Columbia" = "darkblue"
    )
    
    # Render the circle and coverage text
    tagList(
      div(
        id = "circle",
        style = paste("width: 200px; height: 200px; border-radius: 50%; background-color: ", circle_color, ";"),
        title = paste(nickname, ": ", coverage, "% Coverage", sep = ""),
        HTML(paste("<div style='font-size: 30px; color: white;'>", coverage, "%</div>", sep = ""))
      )
    )
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)