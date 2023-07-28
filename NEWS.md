# NEWS

# `hdImpute` 0.2.1
## A Batch Process for High Dimensional Imputation

### Changes

* Added citation onLoad message: *Waggoner, P. D. (2023). A batch process for high dimensional imputation. Computational Statistics, 1-22. <doi:10.1007/s00180-023-01325-9>*

* Added `mad()` function for evaluation by computing mean absolute differences between imputations and the original data

* Added unit testing for basic `mad()` functionality

* Added column-wise and row-wise NA checks for pre- and post- imputation checking:
    - `check_feature_na()`: find features with (specified amount of) missingness
    - `check_row_na()`: find number of and which rows contain any missingness

* Added two new vignettes to work examples using the new functions:
    - NA checking
    - MAD score computation

* Cleaned up `DESCRIPTION`, fixed typos, and some small edits

## How do I get `hdImpute `?

A stable version of the package is released on CRAN. If you have any questions, find any bugs, have ideas for improvements, etc., please follow any of the suggestions at the bottom of the README. Thanks!
