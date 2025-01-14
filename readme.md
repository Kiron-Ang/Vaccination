# VacState: School Vaccination Policies and Coverage Estimates by U.S. State

**VacState** is a web application that visualizes vaccination coverage estimates across U.S. states for four key vaccines: **HPV**, **MenACWY**, **Tetanus**, and **Influenza**. Users can explore and compare vaccination rates among adolescents aged 13-17 years across various states, alongside detailed school vaccination policies and exemption guidelines. 

You can interact with the live application here: [VacState Web Application](https://kiron.shinyapps.io/vacstate).

## Features

- **State-Based Vaccine Coverage**: View vaccine coverage percentages for each U.S. state based on the most recent data from the CDC.
- **Circle Representation**: Visualize vaccination rates as grids of circles, where each circle represents a child, and the color indicates whether they are vaccinated.
- **Policy Overview**: Learn about each state’s vaccination requirements and exemption policies.
- **Comparison Tool**: Easily compare vaccination rates between different states and vaccines to understand trends and disparities.

## Data Sources

- **HPV, MenACWY, and Tetanus Vaccination Coverage Estimates**:  
  Data from the CDC on adolescent vaccination rates for HPV, MenACWY, and Tetanus vaccines:  
  [Vaccination Coverage among Adolescents (13-17 years)](https://data.cdc.gov/Teen-Vaccinations/Vaccination-Coverage-among-Adolescents-13-17-Years/ee48-w5t6).

- **Influenza Vaccination Coverage Estimates**:  
  Data from the CDC on influenza vaccination coverage across all ages:  
  [Influenza Vaccination Coverage for All Ages](https://data.cdc.gov/Flu-Vaccinations/Influenza-Vaccination-Coverage-for-All-Ages-6-Mont/vh55-3he6).

- **State Immunization Requirements and Exemption Policies**:  
  Custom data collected on each state's school vaccination policies, including whether a vaccine is required or recommended and if medical, religious, or philosophical exemptions are allowed.

## Installation and Setup

To run the app locally, follow these steps:

1. **Clone the repository**:
   ```
   git clone https://github.com/Kiron-Ang/VacState.git
   ```

2. **Install R and RStudio** (if not already installed):
   - [Download R](https://cran.r-project.org/)
   - [Download RStudio](https://posit.co/download/rstudio-desktop/)

3. **Install required R packages**:
   In RStudio, navigate to the folder where the files are located, and run the following:
	 ```
   install.packages("shiny")
	 shiny::runApp()
   ```

## How to Use the Web Application

1. **Select a State**: Choose a state from the dropdown menu to view its vaccination data.
2. **Select a Vaccine**: Choose from the list of vaccines to see coverage estimates (HPV, MenACWY, Tetanus, or Influenza).
3. **View Circle Grid**: A grid of 100 circles will appear representing vaccinated vs. unvaccinated individuals in the state for the selected vaccine. Orange circles represent vaccinated individuals.
4. **Explore State Policies**: Learn about the selected state’s vaccination requirements and exemption policies in the sidebar.

## Example Use Case

Imagine you're a public health researcher comparing vaccination coverage for the HPV vaccine between two states. Using **VacState**, you can:

- **Select HPV as the vaccine** and compare coverage between **Texas** and **California**.
- Visualize the data in a grid of circles, showing the percentage of adolescents vaccinated in each state.
- Examine the immunization requirements and exemption policies for both states, identifying potential factors contributing to the differences in vaccination rates.

## Contributing

Contributions are welcome! If you’d like to contribute to this project, please follow the instructions below:

1. Fork the repository.
2. Create a new branch for your changes.
3. Commit your changes to the new branch.
4. Open a pull request detailing the changes made.

## License

This project is licensed under the MIT License; see the [license.txt](license.txt) file for details.

## Acknowledgments

- **Blair Coe Schweiger**, Anthropology Graduate Student at Baylor University, for her collaboration in collecting state vaccination policy data.
- **CDC** for providing the data on vaccination coverage among adolescents.

## Contact

For questions, comments, or feedback, please contact **Kiron Ang**.
- Email: [kiron_ang1@baylor.edu](mailto:kiron_ang1@baylor.edu)  
- GitHub: [https://github.com/Kiron-Ang](https://github.com/Kiron-Ang)