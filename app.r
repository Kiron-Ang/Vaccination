library("shiny")

# Define a dataset of U.S. states and their corresponding nicknames
state_data = data.frame(
  state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", 
            "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
            "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", 
            "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", 
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", 
            "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", 
            "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", 
            "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", 
            "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
            "Washington", "West Virginia", "Wisconsin", "Wyoming", 
            "District of Columbia"),
  nickname = c("Alabamian", "Alaskan", "Arizonan", "Arkansan", "Californian", 
               "Coloradan", "Connecticuter", "Delawarean", "Floridian", 
               "Georgian", "Hawaiian", "Idahoan", "Illinoisan", "Indianan", 
               "Iowan", "Kansasan", "Kentuckian", "Louisianan", "Mainer", 
               "Marylander", "Massachusettsan", "Michigander", "Minnesotan", 
               "Mississippian", "Missourian", "Montanan", "Nebraskan", 
               "Nevadan", "New Hampshirite", "New Jerseyan", "New Mexican", 
               "New Yorker", "North Carolinian", "North Dakotan", "Ohioan", 
               "Oklahoman", "Oregonian", "Pennsylvanian", "Rhode Islander", 
               "South Carolinian", "South Dakotan", "Tennessean", "Texan", 
               "Utahan", "Vermonter", "Virginian", "Washingtonian", 
               "West Virginian", "Wisconsiner", "Wyomingite", "Washingtonian")
)

# Create a named vector to quickly look up nicknames by state
state_nicknames = setNames(state_data$nickname, state_data$state)

# Read in 2023 vaccination coverage data from the CDC
hpv = read.csv("hpv.csv")
menacwy = read.csv("menacwy.csv")
tetanus = read.csv("tetanus.csv")
influenza = read.csv("influenza.csv")

# Read state-specific immunization requirements and exemption policies data
state_policies = read.csv("state_policies.csv")

# Define the UI for the Shiny app
ui = fluidPage(
  tags$head(
    # Custom CSS for styling the circles used for vaccination coverage display
    tags$style(HTML("
      .circle { 
        width: 50px; 
        height: 50px; 
        border-radius: 50%; 
        display: flex; 
        justify-content: center; 
        align-items: center; 
        font-size: 11px; 
        font-weight: bold; 
        border: 1px solid black; 
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
      .circle-info {
        margin-top: 20px; 
        font-size: 14px; 
        padding: 10px; 
        background-color: #f9f9f9; 
        border-radius: 8px;
      }
      .circle-container-text {
        margin-top: 30px; /* Add space between circles and text */
        text-align: center;
      }
    "))
  ),
  
  # Title of the app
  titlePanel("VacState: School Vaccination Policies and Coverage Estimates by U.S. State"),
  
  # Sidebar layout with a state selector and vaccine type selector
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "Select a State:", sort(state_data$state), 
                  selected = "Texas"),
      selectInput("vaccine", "Select a Vaccine:", 
                  sort(c("HPV, ≥1 Dose, Males and Females", 
                         "Tetanus, ≥1 Dose Td or Tdap", 
                         "≥1 Dose MenACWY", "Seasonal Influenza"))),
      
      # Add a few paragraphs in the sidebar below the dropdown menus
      div(class = "circle-info",
          tags$h4("What is this?"),
          tags$p("This is a Shiny web application created to illustrate 
                 vaccination coverage differences between U.S. states.
                 Here, data from the Centers of Disease Control and Prevention
                 (CDC) are displayed to show the coverage estimates for people
                 that are 13-17 years old. Select a vaccine and a state to
                 get a wonderful grid of circles on the right that shows the 
                 percentage of youth in the state that had the vaccine 
                 in 2023. Click on different states and vaccines to compare
                 and contrast! There are 100 circles in total. Pretend that 
                 they represent 100 random children in the state. The orange
                 circles are children that are vaccinated (or vaxxed). This 
                 helps you understand what these percentages really mean."),
          
          tags$h4("Why is this important?"),
          tags$p("Below each grid of circles is a list of policies that the
                 state has. One of the easiest and cheapest ways to increase
                 vaccination coverage is for schools to send a letter home
                 to parents. Most states encourage all schools to do this;
                 However, there are some stark differences in the content
                 of the letters. For example, some states might just have
                 schools send a letter with required vaccines, but others
                 will proactively recommend vaccines, even if they aren't
                 strictly required to attend school. This Shiny web
                 application aims to help users compare different states
                 more easily and learn about how recommending vaccines
                 could potentially have a large effect."),
          
          tags$h4("Who made this?"),
          tags$p("My name is Kiron Ang, and I am the sole developer 
                 responsible for this web application. However, this is 
                 part of a larger project by an anthropology graduate
                 student at Baylor University named Blair Coe Schweiger.
                 Blair and I worked with Gail Petersen-Hock and Inev Lau 
                 to collect state-level information."),
          
          tags$h4("Where can I find the data/code for this?"),
          tags$p("Please see this GitHub repository for more information:
                 https://github.com/kiron-ang/VacState.
                 If you have any other questions, please feel free to email
                 me at kiron_ang1@baylor.edu!")
      )
    ),
    
    # Main panel displaying vaccine coverage info and a circle chart
    mainPanel(
      div(style = "display: flex; justify-content: center; align-items: center; 
                  position: relative;", uiOutput("circle_ui")),
      div(style = "font-size: 24px; text-align: center; margin: 24px;", 
          textOutput("coverage_text")),
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
    # Replace dplyr::filter with base R subset
    state_data = subset(state_policies, state == input$state)
    div(style = "padding: 15px; border-radius: 8px; font-size: 14px;", 
        tags$h4(paste(input$state, 
                      " Immunization Requirements & Exemption Policies:")), 
        tags$ul(
          tags$li(paste("HPV Vaccine Required: ", 
                        state_data$hpv_required)), 
          tags$li(paste("HPV Vaccine Recommended: ", 
                        state_data$hpv_recommended)),
          tags$li(paste("MenACWY Vaccine Required: ", 
                        state_data$hpv_required)), 
          tags$li(paste("MenACWY Vaccine Recommended: ", 
                        state_data$menacwy_recommended)),
          tags$li(paste("Tetanus Vaccine Required: ", 
                        state_data$tetanus_required)), 
          tags$li(paste("Tetanus Vaccine Recommended: ", 
                        state_data$tetanus_recommended)),
          tags$li(paste("Influenza Vaccine Required: ", 
                        state_data$influenza_required)), 
          tags$li(paste("Influenza Vaccine Recommended: ", 
                        state_data$influenza_recommended)),
          tags$li(paste("Medical Exemptions Allowed: ", 
                        state_data$medical_exemption)),
          tags$li(paste("Religious Exemptions Allowed: ", 
                        state_data$religious_exemption)),
          tags$li(paste("Philosophical Exemptions Allowed: ", 
                        state_data$philosophical_exemption))
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
    state_data = subset(vaccine_data, geography == input$state)
    coverage = ifelse(nrow(state_data) > 0, 
                      round(state_data$coverage_estimate[1], 0), NA)
    
    # Define the total number of circles to display in the grid
    num_circles = 100
    circle_percentage = 0
    circle_html = div(class = "circle-container")
    
    # Loop to generate circles representing vaccination coverage
    for (i in 1:num_circles) {
      color = ifelse(circle_percentage >= coverage, "", "orange")
      circle_html = tagAppendChild(circle_html, 
        div(class = "circle", style = paste("background-color: ", color, ";"),
            if (color == "orange") {
              tagAppendChild(div(class = "circle"), "Vaxxed")
              }
        ))
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
    state_data = subset(vaccine_data, geography == input$state)
    coverage = ifelse(nrow(state_data) > 0, state_data$coverage_estimate[1], NA)
    paste("Vaccinated ", state_nickname(), "s in 2023: ", coverage, "%", 
          sep = "")
  })
}

# Run the Shiny app with the defined UI and server
shinyApp(ui = ui, server = server)