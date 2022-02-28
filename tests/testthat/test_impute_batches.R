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
  c <- feature_cor(data)
  f <- flatten_mat(c)
  expect_error(impute_batches(data = !data.frame(data),
                              features = f,
                              batch = 2))
  expect_error(impute_batches(data = !tibble(data),
                              features = f,
                              batch = 2))
  expect_error(impute_batches(data = !as.data.frame(data),
                              features = f,
                              batch = 2))
  expect_error(impute_batches(data = !as_tibble(data),
                              features = f,
                              batch = 2))
})

## checking expected output data class
test_that("testing output data class", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  i <- impute_batches(data = data, features = f, batch = 2)
  expect_s3_class(i, "tbl_df")
  expect_s3_class(i, "tbl")
  expect_s3_class(i, "data.frame")
})

## checking only one data frame is passed to impute_batches()
test_that("impute_batches() successfully only accepts single data frame as input", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  for (num_dfs in seq(2, 5)) {
    expect_error(impute_batches(data = num_dfs, features = f, batch = 2))
  }
})

## checking error for NULL or non-numeric batches
test_that("impute_batches() requires numeric value for batch size supplied to n", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  expect_error(impute_batches(data = data, features = f, batch = NULL))
  expect_error(impute_batches(data = data, features = f, batch = notanumber))
  expect_error(impute_batches(data = data, features = f, batch = "notanumber"))
})

## checking visible printing
test_that("testing visible printing", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  i <- impute_batches(data = data, features = f, batch = 2)
  expect_visible(i)
  expect_visible(impute_batches(data = data, features = f, batch = 2))
})

## checking for at least 1 NA in supplied df
test_that("impute_batches() requires at least 1 missing value for batch creation", {
  c <- feature_cor(d) # note: obj d is the *complete* synthetic df
  f <- flatten_mat(c)
  expect_error(impute_batches(data = d, features = f))
  expect_error(impute_batches(data = d, features = f, batch = 2))
})
