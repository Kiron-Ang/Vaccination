library(shiny)

# Define UI
ui <- fluidPage(
  # Set page title
  titlePanel("Choose Your State"),
  
  # Add a dropdown menu for states
  selectInput(
    inputId = "state",
    label = "Select a State:",
    choices = c(
      "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", 
      "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", 
      "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", 
      "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
      "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", 
      "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", 
      "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", 
      "Rhode Island", "South Carolina", "South Dakota", "Tennessee", 
      "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", 
      "Wisconsin", "Wyoming"
    ),
    selected = "Texas"
  ),
  
  # Add space for the circle to appear
  div(
    style = "display: inline-block; vertical-align: top; padding: 20px;",
    uiOutput("circle_ui")
  )
)

# Define server logic
server <- function(input, output) {
  
  # Define a reactive expression for state nickname
  state_nickname <- reactive({
    state <- input$state
    switch(state,
      "Alabama" = "Alabamian", 
      "Alaska" = "Alaskan", 
      "Arizona" = "Arizonan", 
      "Arkansas" = "Arkansan", 
      "California" = "Californian", 
      "Colorado" = "Coloradan", 
      "Connecticut" = "Connecticuter", 
      "Delaware" = "Delawarean", 
      "Florida" = "Floridian", 
      "Georgia" = "Georgian", 
      "Hawaii" = "Hawaiian", 
      "Idaho" = "Idahoan", 
      "Illinois" = "Illinoisan", 
      "Indiana" = "Indianan", 
      "Iowa" = "Iowan", 
      "Kansas" = "Kansasan", 
      "Kentucky" = "Kentuckian", 
      "Louisiana" = "Louisianan", 
      "Maine" = "Mainer", 
      "Maryland" = "Marylander", 
      "Massachusetts" = "Massachusettsan", 
      "Michigan" = "Michigander", 
      "Minnesota" = "Minnesotan", 
      "Mississippi" = "Mississippian", 
      "Missouri" = "Missourian", 
      "Montana" = "Montanan", 
      "Nebraska" = "Nebraskan", 
      "Nevada" = "Nevadan", 
      "New Hampshire" = "New Hampshirite", 
      "New Jersey" = "New Jerseyan", 
      "New Mexico" = "New Mexican", 
      "New York" = "New Yorker", 
      "North Carolina" = "North Carolinian", 
      "North Dakota" = "North Dakotan", 
      "Ohio" = "Ohioan", 
      "Oklahoma" = "Oklahoman", 
      "Oregon" = "Oregonian", 
      "Pennsylvania" = "Pennsylvanian", 
      "Rhode Island" = "Rhode Islander", 
      "South Carolina" = "South Carolinian", 
      "South Dakota" = "South Dakotan", 
      "Tennessee" = "Tennessean", 
      "Texas" = "Texan", 
      "Utah" = "Utahan", 
      "Vermont" = "Vermonter", 
      "Virginia" = "Virginian", 
      "Washington" = "Washingtonian", 
      "West Virginia" = "West Virginian", 
      "Wisconsin" = "Wisconsiner", 
      "Wyoming" = "Wyomingite"
    )
  })
  
  # Render circle and hover effect
  output$circle_ui <- renderUI({
    state <- input$state
    nickname <- state_nickname()
    
    # Set circle color
    circle_color <- switch(state,
      "Texas" = "red", 
      "Florida" = "blue", 
      "California" = "green",
      "New York" = "purple",
      "Illinois" = "orange",
      "Alabama" = "yellow",
      "Michigan" = "pink",
      "Ohio" = "brown",
      "Georgia" = "cyan",
      "North Carolina" = "magenta",
      "Virginia" = "violet",
      "South Carolina" = "lightblue",
      "Tennessee" = "lightgreen",
      "Nevada" = "indigo",
      "Hawaii" = "coral",
      "Arizona" = "teal",
      "Washington" = "peachpuff",
      "Missouri" = "lightyellow",
      "Minnesota" = "fuchsia",
      "Kansas" = "gold",
      "Colorado" = "tan",
      "Louisiana" = "darkolivegreen",
      "Indiana" = "peru",
      "Maine" = "salmon",
      "Maryland" = "dodgerblue",
      "Mississippi" = "crimson",
      "Montana" = "springgreen",
      "Nebraska" = "lawngreen",
      "North Dakota" = "midnightblue",
      "South Dakota" = "seashell",
      "Wyoming" = "limegreen",
      "Oklahoma" = "chocolate",
      "New Jersey" = "slateblue",
      "Connecticut" = "lightpink",
      "Kentucky" = "lightseagreen",
      "Delaware" = "thistle",
      "Rhode Island" = "beige",
      "West Virginia" = "hotpink",
      "Utah" = "yellowgreen",
      "Oregon" = "indianred",
      "Alaska" = "yellow",
      "Idaho" = "orchid",
      "California" = "salmon",
      "New Mexico" = "plum",
      "Illinois" = "ivory",
      "Ohio" = "khaki",
      "Michigan" = "darkorange",
      "Pennsylvania" = "turquoise",
      "Vermont" = "mistyrose",
      "Massachusetts" = "powderblue",
      "New Hampshire" = "wheat",
      "Wisconsin" = "lightskyblue",
      "Iowa" = "green",
      "Montana" = "gray",
      "Wyoming" = "lightcoral",
      "Tennessee" = "firebrick",
      "Colorado" = "forestgreen"
    )
    
    # Create the circle and hover text
    tagList(
      div(
        id = "circle",
        style = paste("width: 100px; height: 100px; border-radius: 50%; background-color: ", circle_color, ";"),
        title = nickname,
        HTML("<br><br><div id='hover-text' style='display:none;'>Hovering over a circle will show this text: ", nickname, "</div>")
      )
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)