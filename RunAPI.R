library(plumber)
r <- plumb('MyAPI.R')

#run it on the port in the Dockerfile
r$run(port=8000)