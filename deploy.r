# Install the 'rsconnect' package from CRAN using a specified mirror
install.packages('rsconnect', repos = 'https://cloud.r-project.org/')

# Load the 'rsconnect' library into the R session
library(rsconnect)

# Set the account information for deploying to shinyapps.io
rsconnect::setAccountInfo(
  name = '8zjn1m-kiron-ang',  # Shinyapps.io account name
  token = '46463AFD78EE58FC283684112E29743A',  # Token for the account
  secret = 'PiPkguwuGNN3quPEiQKnNJSYiuVoyqhi1f96hUSA'  # Secret key
)

# Deploy the application to shinyapps.io using the current working dir
rsconnect::deployApp()  # Deploys the app to shinyapps.io account
