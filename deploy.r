# Install and load rsconnect package
install.packages("rsconnect", repos = "https://cloud.r-project.org")
library("rsconnect")

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(name='8zjn1m-kiron-ang', 
  token='F877836920DEC73B145F4F0006EC87F3', 
  secret='REPLACE THIS TEXT')

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()