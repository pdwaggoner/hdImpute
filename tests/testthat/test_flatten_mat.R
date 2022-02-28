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

## checking expected output data type
test_that("testing output data type", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  expect_type(f, "list")
})

## checking expected output data class
test_that("testing output data class", {
  c <- feature_cor(data)
  f <- flatten_mat(c)
  expect_s3_class(f, "tbl_df")
  expect_s3_class(f, "tbl")
  expect_s3_class(f, "data.frame")
})

## checking visible printing
test_that("testing visible printing", {
  c <- feature_cor(data)
  expect_visible(flatten_mat(c))
})
