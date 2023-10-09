# `hdImpute`: Batched high dimensional imputation
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/hdImpute)](http://cran.r-project.org/package=hdImpute)
[![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/hdImpute)](http://cranlogs.r-pkg.org/)
[![Documentation](https://img.shields.io/badge/documentation-hdImpute-orange.svg?colorB=E91E63)](https://www.r-pkg.org/pkg/hdImpute)

`hdImpute` is a correlation-based batch process for addressing high dimensional imputation problems. There are relatively few algorithms designed to handle imputation of missing data in high dimensional contexts in a relatively fast, efficient manner. Further, of the existing algorithms, even fewer are flexible enough to natively handle mixed-type data, often requiring a great deal of preprocessing to get the data into proper shape, and then postprocessing to return data to its original form. Such decisions as well as assumptions made by many algorithms regarding for example, the data generating process, limit the performance, flexibility, and usability of the algorithm. Built on top of a recent set of complementary algorithms for nonparametric imputation via chained random forests, `missForest` and `missRanger`, I offer a batch-based approach for subsetting the data based on ranked cross-feature correlations, and then imputing each batch separately, and then joining imputed subsets in the final step. The process is extremely fast and accurate after a bit of tuning to find the optimal batch size. As a result, high dimensional imputation is more accessible, and researchers are not forced to decide between speed or accuracy.

See the R-Bloggers post overviewing a basic implementation of `hdImpute` in R [here](https://www.r-bloggers.com/2022/03/batched-imputation-for-high-dimensional-missing-data-problems/)

See the detailed complementary paper (*Computational Statistics*, 2023) introducing `hdImpute` along with several experimental results [here](https://link.springer.com/article/10.1007/s00180-023-01325-9) (journal site) or [here](https://github.com/pdwaggoner/hdImpute/blob/main/resfiles/hdimpute_paper.pdf) (full paper)

## Python

A complementary version of `hdImpute` is being actively developed in Python. [Take a look here](https://github.com/pdwaggoner/hdImpute_py) and please feel free to directly contribute! 

## Access

Dev:

```{r}
devtools::install_github("pdwaggoner/hdImpute")
```


Stable (on CRAN):

```{r}
install.packages("hdImpute")
library(hdImpute)
```

## Usage

`hdImpute` includes five core functions, and two helpers. The first three are to proceed by individual stages ((1) build the correlation matrix, (2) flatten and rank the matrix to give a ranked feature list, and (3) build batches, impute, and join). The fourth function (`hdImpute()`) runs all stages simultaneously, which is slightly less flexible, but much simpler. Finally, the latest release (v0.2.1) includes a fifth function to evaluate the quality of imputations by computing the mean absolute differences ("MAD scores") for each variable in the original data compared to the imputed version of the data. 

  1. `feature_cor()`: creates the correlation matrix
  
  2. `flatten_mat()`: flattens the correlation matrix from the previous stage, and ranks the features based on absolute correlations. Thus, the input for `flatten_mat()` should be the stored output from `feature_cor()`.
  
  3. `impute_batches()`: creates batches based on the feature rankings from `flatten_mat()`, and then imputes missing values for each batch, until all batches are completed. Then, joins the batches to give a completed, imputed data set. 

  4. `hdImpute()`: does everything for you. At a minimum, pass the raw data object (`data`) along with specifying the batch size (`batch`) to `hdImpute()` to return a complete, imputed data set (same as you'd get from the individual stages in the above three functions).
  
  5. `mad()`: computes variable-wise mean absolute differences (MAD) between original and imputed dataframes. Returns the MAD scores for each variable as a tibble to ensure tidy compliance and easy interaction with other Tidyverse functions (e.g., `ggplot()` for visualizing imputation error).

There are several vignettes with deeper dives into the package functionality, which include a few ideas for how to use the software for any imputation project.

## Contribute

This software is being actively developed, with many more features to come. Wide engagement with it and collaboration is welcomed! Here's a sampling of how to contribute:

  - Submit an [issue](https://github.com/pdwaggoner/hdImpute/issues) reporting a bug, requesting a feature enhancement, etc. 

  - Suggest changes directly via a [pull request](https://github.com/pdwaggoner/hdImpute/pulls)

  - [Reach out directly](https://pdwaggoner.github.io/) with ideas if you're uneasy with public interaction

Thanks for using the tool. I hope its useful.
