# Start from the rstudio/plumber image
FROM rstudio/plumber

# Install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev pandoc 
    
    
# Install packages used in project
RUN R -e "install.packages(c('plumber', 'tidymodels', 'ggplot2', 'tidyverse', 'ranger'))"

# Copy API file into the container
COPY MyAPI.R MyAPI.R

# Copy data import and cleaning function
COPY load_clean_data.R load_clean_data.R

# Copy data set
COPY diabetes_binary_health_indicators_BRFSS2015.csv diabetes_binary_health_indicators_BRFSS2015.csv

# Open port to traffic
EXPOSE 8000

# When the container starts, start the MyAPI.R script
ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('/MyAPI.R'); pr$run(host='0.0.0.0', port=8000)"]
