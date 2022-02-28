library(tidyverse)

# set up some sample data
d <- data.frame(X1 = c(1:6),
                X2 = c(rep("A", 3),
                       rep("B", 3)),
                X3 = c(3:8),
                X4 = c(5:10),
                X5 = c(rep("A", 3),
                       rep("B", 3)),
                X6 = c(6,3,9,4,4,6))

set.seed(1234)

data <- missForest::prodNA(d, noNA = 0.30) %>%
  as_tibble()

## checking expected input data class
test_that("testing input data class", {
  expect_error(feature_cor(data = !data.frame(data)))
  expect_error(feature_cor(data = !tibble(data)))
  expect_error(feature_cor(data = !as.data.frame(data)))
  expect_error(feature_cor(data = !as_tibble(data)))
})

## checking expected output data type
test_that("testing output data type", {
  c <- feature_cor(data = data)
  expect_type(c, "double")
})

## checking expected output data class
test_that("testing output data class", {
  c <- feature_cor(data = data)
  expect_true(is.matrix(c))
  expect_true(is.array(c))
})

## checking visible printing
test_that("testing for visible printing", {
  expect_visible(feature_cor(data = data))
})
