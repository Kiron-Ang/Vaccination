# Check if 'shiny' package is installed, if not, install it
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny", repos = 'https://cloud.r-project.org/')
}

# Load the 'shiny' library into the R session
library(shiny)

# Define UI
ui <- fluidPage(
  # Set page title
  titlePanel("Modeling the Effect of Vaccination on Disease Spread Using Real USA Vaccination Coverage Estimates"),
  
  # Use a sidebar layout to move the circle to the main area
  sidebarLayout(
    # Sidebar panel for the dropdown
    sidebarPanel(
      selectInput(
        inputId = "state",
        label = "Select a State:",
        choices = c(
          "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", 
          "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", 
          "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", 
          "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
          "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", 
          "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
        ),
        selected = "Texas"
      )
    ),
    
    # Main panel for the circle
    mainPanel(
      # Space for the circle to appear, with styling to make it centered and larger
      div(
        style = "text-align: center; padding: 20px;",  # Center the circle
        uiOutput("circle_ui")
      )
    )
  ),
  
  # Include CSS for high contrast support
  tags$head(
    tags$style(HTML("
      @media (forced-colors: active) {
        #circle {
          border-radius: 50%;
          width: 200px;  /* Increased size */
          height: 200px; /* Increased size */
          background-color: ButtonFace;
          border: 3px solid ButtonText;
        }
      }
    "))
  )
)

# Define server logic
server <- function(input, output) {
  
  # Define a reactive expression for state nickname
  state_nickname <- reactive({
    state <- input$state
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
      "Wisconsin" = "Wisconsiner", "Wyoming" = "Wyomingite"
    )
  })
  
  # Render circle and hover effect
  output$circle_ui <- renderUI({
    state <- input$state
    nickname <- state_nickname()
    
    # Set circle color based on state
    circle_color <- switch(state,
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
      "Colorado" = "forestgreen"
    )
    
    # Create the circle and hover text
    tagList(
      div(
        id = "circle",
        style = paste("width: 200px; height: 200px; border-radius: 50%; background-color: ", circle_color, ";"),
        title = nickname,
        HTML("<br><br><div id='hover-text' style='display:none;'>Hovering over a circle will show this text: ", nickname, "</div>")
      )
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
