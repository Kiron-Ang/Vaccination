library("rsconnect")

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(name="kiron",
			  token="TOKEN",
			  secret="SECRET")

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()