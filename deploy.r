# Install and load rsconnect package
install.packages("rsconnect", repos = "https://cloud.r-project.org")
library("rsconnect")

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(name='kiron',
			  token='349BC13B153D21DBEE3856FD163F1351',
			  secret='<SECRET>')

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()