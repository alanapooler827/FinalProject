library(plumber)
library(tidymodels)
library(ggplot2)

# import and clean data set
source("load_clean_data.R")
df <- load_clean_data()

# Create model instance using parameters from best model
rf_spec <- 
  rand_forest(
    mtry = 2,
    min_n = 40,
    trees = 100
  ) |>
  set_engine("ranger") |>
  set_mode("classification")

# fit model to entire data set
final_fit <- rf_spec |>
  fit(Diabetes_binary ~ HighBP + GenHlth + HighChol +
        Age + BMI + PhysHlth + DiffWalk,
      data = df)

# Get default variable values (means or most common classes)
get_default <- function(v) {
  if (is.numeric(v)) {
    return(mean(v, na.rm = TRUE))
  } else {
    return(names(sort(table(v), decreasing = TRUE))[1])
  }
}

defaults <- map(df |> select(-Diabetes_binary), get_default)

# Endpoint 1: pred

#* Return a predicted probability of diabetes
#* @param HighBP High blood pressure (default = most common)
#* @param GenHlth General health (default = most common)
#* @param HighChol High cholesterol (default = most common)
#* @param Age Age group (default = most common)
#* @param BMI Body mass index (default = mean)
#* @param PhysHlth Physical health days (default = mean)
#* @param DiffWalk Difficulty walking (default = most common)
#* @get /pred
#* 
function(HighBP = defaults$HighBP,
         HighChol = defaults$HighChol,
         BMI = defaults$BMI,
         GenHlth = defaults$GenHlth,
         Age = defaults$Age,
         PhysHlth = defaults$PhysHlth,
         DiffWalk = defaults$DiffWalk) {
  
  newdf <- tibble(
    HighBP = as.factor(HighBP),
    HighChol = as.factor(HighChol),
    BMI = as.numeric(BMI),
    GenHlth = as.factor(GenHlth),
    Age = as.factor(Age),
    PhysHlth = as.numeric(PhysHlth),
    DiffWalk = as.factor(DiffWalk)
  )
  
  preds <- predict(final_fit, newdf, type = "prob")$.pred_Yes
  return(list(predicted_probability = preds))
}

# Example API calls:
# http://127.0.0.1:8000/pred?HighBP=Yes&BMI=31&Age=25-29
# http://127.0.0.1:8000/pred?BMI=40&GenHlth=Poor
# http://127.0.0.1:8000/pred?HighChol=Yes&PhysHlth=10


# Endpoint 2: info
#* Return author info
#* @get /info
function() {
  list(
    name = "Alana Pooler",
    github_page = "https://alanapooler827.github.io/FinalProject/"
  )
}


# Endpoint 3: Confusion
#* Plot a confusion matrix for the fitted model
#* @get /confusion
#* @serializer png
function() {
  preds <- predict(final_fit, df, type = "class")
  
  conf_matrix_df <- data.frame(table(Predicted = preds$.pred_class, Actual = df$Diabetes_binary))
  
  # convert to ggplot using autoplot
  p <- ggplot(conf_matrix_df, aes(x = Actual, y = Predicted, fill = Freq)) +
    geom_tile() +
    geom_text(aes(label = Freq), color = "black") +
    scale_fill_gradient(low = '#f1eef6', high = '#ce1256') +
    labs(title = "Confusion Matrix For Final Model",
         x = "Actual",
         y = "Predicted") +
    theme_minimal()
  
  print(p)
}