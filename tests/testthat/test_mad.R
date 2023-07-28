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
  imp <- hdImpute(data = data, batch = 2)
  expect_error(mad(original = !data.frame(data),
                   imputed = !data.frame(imp)))
  expect_error(mad(original = !tibble(data),
                   imputed = !tibble(imp)))
  expect_error(mad(original = !as.data.frame(data),
                   imputed = !as.data.frame(imp)))
  expect_error(mad(original = !as_tibble(data),
                   imputed = !as_tibble(imp)))
})

## checking expected output data class
test_that("testing output data class", {
  imp <- hdImpute(data = data, batch = 2)
  mad <- mad(data, imp)
  expect_s3_class(mad, "tbl_df")
  expect_s3_class(mad, "tbl")
  expect_s3_class(mad, "data.frame")
})

## checking visible printing
test_that("testing visible printing", {
  imp <- hdImpute(data = data, batch = 2)
  expect_visible(mad(data, imp))
  mad <- mad(data, imp)
  expect_visible(mad)
})
