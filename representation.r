# Define the CRAN mirror (if not already set)
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Check if required packages are installed, if not, install them
required_packages <- c("shiny", "ggplot2", "dplyr", "plotly")

for(pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)  # Now will use the default CRAN mirror
    library(pkg, character.only = TRUE)
  }
}

# Define UI
ui <- fluidPage(
  titlePanel("Vaccination Impact on Disease Spread"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("vaccination_rate", 
                  "Vaccination Rate:", 
                  min = 0, 
                  max = 1, 
                  value = 0.7,
                  step = 0.05),
      actionButton("start_button", "Start Simulation")
    ),
    
    mainPanel(
      plotlyOutput("plot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  observeEvent(input$start_button, {
    # Initialize simulation parameters
    vaccination_rate <- input$vaccination_rate
    n_balls <- 100
    n_vaccinated <- round(n_balls * vaccination_rate)
    
    # Create a dataframe for balls
    balls <- data.frame(
      id = 1:n_balls,
      x = runif(n_balls),  # Random x positions
      y = runif(n_balls),  # Random y positions
      status = c(rep("unvaccinated", n_balls - n_vaccinated), rep("vaccinated", n_vaccinated)),
      infected = FALSE
    )
    
    # Randomly select one ball to be infected
    infected_index <- sample(1:n_balls, 1)
    balls$infected[infected_index] <- TRUE
    
    # Define function to spread the disease
    spread_infection <- function(balls) {
      for (i in 1:nrow(balls)) {
        if (balls$infected[i] == TRUE) {
          # Infect other unvaccinated balls that are close enough
          for (j in 1:nrow(balls)) {
            if (balls$infected[j] == FALSE && balls$status[j] == "unvaccinated" &&
                sqrt((balls$x[i] - balls$x[j])^2 + (balls$y[i] - balls$y[j])^2) < 0.1) {
              balls$infected[j] <- TRUE
            }
          }
        }
      }
      return(balls)
    }
    
    # Simulate disease spread
    balls <- spread_infection(balls)
    
    # Plot the results
    output$plot <- renderPlotly({
      gg <- ggplot(balls, aes(x = x, y = y, color = ifelse(infected, "red", ifelse(status == "vaccinated", "green", "orange")))) +
        geom_point(size = 5) +
        scale_color_identity() +
        theme_void() +
        theme(legend.position = "none")
      
      ggplotly(gg)
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)