# VacState: School Vaccination Policies and Coverage Estimates in the United States

You can view the web application online at https://kiron.shinyapps.io/vacstate.

HPV, MenAWCY, and Tetanus Vaccination Coverage Estimates: https://data.cdc.gov/Teen-Vaccinations/Vaccination-Coverage-among-Adolescents-13-17-Years/ee48-w5t6

Influenza Vaccination Coverage Estimates: https://data.cdc.gov/Flu-Vaccinations/Influenza-Vaccination-Coverage-for-All-Ages-6-Mont/vh55-3he6

Deploy the Shiny application with the following lines of R code:

```
library("rsconnect")

rsconnect::setAccountInfo(name="NAME",
			  token="TOKEN",
			  secret="SECRET")

rsconnect::deployApp()
```

Please email Kiron Ang if you have any questions or comments: kiron_ang1@baylor.edu.