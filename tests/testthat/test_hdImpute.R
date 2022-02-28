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
  expect_error(hdImpute(data = !data.frame(data),
                        batch = 2))
  expect_error(hdImpute(data = !tibble(data),
                        batch = 2))
  expect_error(hdImpute(data = !as.data.frame(data),
                        batch = 2))
  expect_error(hdImpute(data = !as_tibble(data),
                        batch = 2))
})

## checking expected output data class
test_that("testing output data class", {
  c <- hdImpute(data = data, batch = 2)
  expect_s3_class(c, "tbl_df")
  expect_s3_class(c, "tbl")
  expect_s3_class(c, "data.frame")
})

## checking only one data frame is passed to hdImpute()
test_that("hdImpute() successfully only accepts single data frame as input", {
  for (num_dfs in seq(2, 5)) {
    expect_error(hdImpute(data = num_dfs))
  }
})

## checking error for NULL or non-numeric batches
test_that("hdImpute() requires numeric value for batch size supplied to n", {
  expect_error(hdImpute(data = data, batch = NULL))
  expect_error(hdImpute(data = data, batch = notanumber))
  expect_error(hdImpute(data = data, batch = "notanumber"))
})

## checking visible printing
test_that("testing visible printing", {
  i <- hdImpute(data = data, batch = 2)
  expect_visible(i)
  expect_visible(hdImpute(data = data, batch = 2))
})

## checking for at least 1 NA in supplied df
test_that("hdImpute() requires at least 1 missing value for batch creation", {
  expect_error(hdImpute(data = d)) # note: obj d is the *complete* synthetic df
  expect_error(hdImpute(data = d, batch = 2))
})
