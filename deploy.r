# Install and load rsconnect package
install.packages("rsconnect", repos = "https://cloud.r-project.org")
library("rsconnect")

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(name='kiron',
			  token='REPLACE THIS WITH TOKEN',
			  secret='REPLACE THIS WITH SECRET')

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()