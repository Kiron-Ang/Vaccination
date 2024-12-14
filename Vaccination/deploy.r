# Define a vector containing the required package names
packages = c("rsconnect")

# Identify which packages are not installed on the system
new_packages = packages[!(packages %in% installed.packages()[,"Package"])]

# Install the missing packages from the specified repository
if(length(new_packages)) install.packages(new_packages, repos = 'https://cloud.r-project.org/')

# Load the required packages into the R session
lapply(packages, library, character.only = TRUE)

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(
  name = '8zjn1m-kiron-ang',  # The shinyapps.io account name
  token = '46463AFD78EE58FC283684112E29743A',  # The token associated with the account
  secret = 'PiPkguwuGNN3quPEiQKnNJSYiuVoyqhi1f96hUSA'  # The secret key associated with the account
)

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()