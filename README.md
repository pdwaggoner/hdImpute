# `hdImpute`: Batched high dimensional imputation

`hdImpute` is a correlation-based batch process for addressing high dimensional imputation problems. There are relatively few algorithms designed to handle impu- tation of missing data in high dimensional contexts in a relatively fast, efficient manner. Further, of the existing algorithms, even fewer are flexible enough to natively handle mixed-type data, often requiring a great deal of preprocessing to get the data into proper shape, and then postprocessing to return data to its original form. Such decisions as well as assumptions made by many algorithms regarding for example, data generating process, limit the performance, flexibility, and usability of the algorithm. Built on top of a recent set of complementary algorithms for nonparametric imputation via chained random forests, missForest and missRanger, I offer a batch-based approach for subsetting the data based on ranked cross-feature correlations, and then imputing each batch separately, and then joining imputes subsets in the final step. The process is extremely fast and accurate. As a result, high dimensional imputation is more accessible, and researchers are not forced to decide between speed or accuracy.

The software includes four functions. The first three are to proceed by individual stages (build the correlation matrix, flatten and rank the matrix to give a ranked feature list, and buiuld batches and impute), and the fourth function (`hdImpute()`) is meant to run all stages simultaneously. 

  1. `feature_cor()`: creates the correlation matrix
  
  2. `flatten_mat()`: flattens the correlation matrix from the previous stage, and ranks the features based on absolutely correlations. Thus, the input for `flatten_mat()` should be the stored output from `feature_cor()`.
  
  3. `impute_batches()`: creates batches based on the feature rankings from `flatten_mat()`, and then imputes missing values for each batch, until all batches are completed. Then, joins the batches to give a completed, imputed data set. 

  4. `hdImpute()`: does everything for you. At a minimum, pass the raw data object (`data`) along with specifying the batch size (`batch`) to `hdImpute()` to return a complete, imputed data set (same as you'd get from the individual stages in the above three functions).

## Vignette

For a demonstration of the package, take a look at the vignette. 

## Contribute

This software is in its infancy, though a first version (0.1.0) is on CRAN. As such, wide engagement with it and collaboration is welcomed! Before collaborating, please take a look at and abide by the contributorcode of conduct. 

  - Feel free to submit an [issue](https://github.com/pdwaggoner/hdImpute/issues) reporting a bug, requesting a feature enhancement, etc. 

  - Or consider suggesting changes directly via a [pull request](https://github.com/pdwaggoner/hdImpute/pulls). 

  - Or feel free to [reach out to me directly](https://pdwaggoner.github.io/) with ideas if you're uneasy with public interaction. 

Thanks for reading and using the tool! I hope its useful.
