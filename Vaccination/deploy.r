library("rsconnect")

# Set account information for deploying the application to shinyapps.io
rsconnect::setAccountInfo(
  name = '8zjn1m-kiron-ang',  # The shinyapps.io account name
  token = '46463AFD78EE58FC283684112E29743A',  # The token associated with the account
  secret = 'PiPkguwuGNN3quPEiQKnNJSYiuVoyqhi1f96hUSA'  # The secret key associated with the account
)

# Deploy the application to shinyapps.io using the current working directory
rsconnect::deployApp()