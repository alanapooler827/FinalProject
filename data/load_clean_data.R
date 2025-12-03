library(tidyverse)

load_clean_data <- function() {
  df <- read_csv('data/diabetes_binary_health_indicators_BRFSS2015.csv')
  
  # columns to leave numeric
  skip_convert <- c('BMI', 'MentHlth', 'PhysHlth')
  
  df <- df |>
    mutate(across(-all_of(skip_convert), as.factor))
  
  # variables that should not be recoded to yes/no
  skip_recode <- c(
    'BMI', 'GenHlth', 'MentHlth', 'PhysHlth',
    'Sex', 'Age', 'Education', 'Income'
  )
  
  lvl_map <- c('0' = 'No', '1' = 'Yes')
  
  df <- df |>
    mutate(
      # yes/no recoding for all factor columns except skip_recode
      across(-all_of(skip_recode), ~ recode(.x, !!!lvl_map)),
      
      GenHlth = fct_recode(
        GenHlth,
        'Excellent' = '1',
        'Very Good' = '2',
        'Good' = '3',
        'Fair' = '4',
        'Poor' = '5'
      ),
      Sex = fct_recode(
        Sex,
        'Female' = '0',
        'Male' = '1'
      ),
      Age = fct_recode(
        Age,
        '18-24' = '1',
        '25-29' = '2',
        '30-34' = '3',
        '35-39' = '4',
        '40-44' = '5',
        '45-49' = '6',
        '50-54' = '7',
        '55-59' = '8',
        '60-64' = '9',
        '65-69' = '10',
        '70-74' = '11',
        '75-79' = '12',
        '80+' = '13'
      ),
      Education = fct_recode(
        Education,
        'None' = '1',
        'Elementary School' = '2',
        'Some High School' = '3',
        'High School' = '4',
        'Some College' = '5',
        'College Graduate' = '6'
      ),
      Income = fct_recode(
        Income,
        'Less than $10k' = '1',
        '$10k to < $15k' = '2',
        '$15k to < $20k' = '3',
        '$20k to < $25k' = '4',
        '$25k to < $35k' = '5',
        '$35k to < $50k' = '6',
        '$50k to < $75k' = '7',
        '$75k or more' = '8'
      )
    )
}
