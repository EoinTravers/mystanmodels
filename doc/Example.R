library(rstan)
library(mystanmodels)

stan_data = list(
  N = nrow(iris),
  K = 1, # N predictors
  X = iris$Petal.Length,
  y = iris$Petal.Width)

