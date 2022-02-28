#' High dimensional imputation via batch processed chained random forests
#'
#' Build correlation matrix
#'
#' @usage feature_cor(data, return_cor)
#' @param data A data object.
#' @param return_cor Logical. Should the correlation matrix be printed? Default set to FALSE.
#' @references van Buuren S, Groothuis-Oudshoorn K (2011). "mice: Multivariate Imputation by Chained Equations in R." Journal of Statistical Software, 45(3), 1-67. doi: <10.18637/jss.v045.i03>
#' @return A cross-feature correlation matrix
#' @export
#' @examples
#' \dontrun{
#' feature_cor(data = data, return_cor = FALSE)
#' }
feature_cor <- function(data,
                        return_cor = FALSE) {

  if(!is.data.frame(data) && !tibble::is_tibble(data) && !is.atomic(data)) {
    stop('x must be atomic, data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }

  nvar <- ncol(data)
  data_matrix <- matrix(0,
                        nrow = nvar,
                        ncol = nvar,
                        dimnames = list(names(data),
                                        names(data)))
  x <- data.matrix(data)
  r <- !is.na(x)

  suppressWarnings(v <- abs(stats::cor(x, use = "pairwise.complete.obs",
                                       method = "pearson")))
  v[is.na(v)] <- 0
  suppressWarnings(u <- abs(stats::cor(y = x, x = r, use = "pairwise.complete.obs",
                                       method = "pearson")))
  u[is.na(u)] <- 0
  max_cor <- pmax(v, u)

  if(return_cor == TRUE){
    print(max_cor)
  } else max_cor
}

#' Flatten and arrange cor matrix to be df
#'
#' @usage flatten_mat(cor_mat, return_mat)
#' @param cor_mat A correlation matrix output from running \code{feature_cor()}
#' @param return_mat Logical. Should the flattened matrix be printed? Default set to FALSE.
#' @return A vector of correlation-based ranked features
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' flatten_mat(cor_mat = cor_mat, return_mat = FALSE)
#' }
flatten_mat <- function(cor_mat,
                        return_mat = FALSE) {

  ut <- upper.tri(cor_mat)

  all_cor_mat <- tibble::tibble(
    row = rownames(cor_mat)[row(cor_mat)[ut]],
    column = rownames(cor_mat)[col(cor_mat)[ut]],
    cor = (cor_mat)[ut]
  ) %>%
    dplyr::arrange(plyr::desc(cor))

  if(return_mat == TRUE){
    print(all_cor_mat)
  }

  # interweave cols for batch creation
  df_x <- all_cor_mat %>%
    dplyr::select(row) %>%
    dplyr::rename(col = row)

  df_y <- all_cor_mat %>%
    dplyr::select(column) %>%
    dplyr::rename(col = column)

  # create new df, ordered by correlation
  ranked <- dplyr::bind_rows(
    df_x, df_y
  ) %>%
    dplyr::distinct(col)

  ranked
}

#' Impute batches and return completed data frame
#'
#' @usage impute_batches(data, features, batch, pmm_k, n_trees, seed, save)
#' @param data Original data frame (with missing values)
#' @param features Correlation-based vector of ranked features output from running \code{flatten_mat()}
#' @param batch Numeric. Batch size.
#' @param pmm_k Integer. Number of neighbors considered in imputation. Default at 5.
#' @param n_trees Integer. Number of trees used in imputation. Default at 15.
#' @param seed Integer. Seed to be set for reproducibility.
#' @param save Should the list of individual imputed batches be saved as .rds file to working directory? Default set to FALSE.
#' @details Step 1. group data by dividing the \code{row_number()} by batch size (\code{batch}, number of batches set by user) using integer division. Step 2. pass through \code{group_split()} to return a list. Step 3. impute each batch individually and time. Step 4. generate completed (unlisted/joined) imputed data frame
#' @references Stekhoven, D. J., & Bühlmann, P. (2012). MissForest—non-parametric missing value imputation for mixed-type data. Bioinformatics, 28(1), 112-118.
#' @return A completed, imputed data set
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' impute_batches(data = data, features = flat_mat,
#' batch = 2,  pmm_k = 5, n_trees = 15, seed = 123,
#' save = FALSE)
#' }
impute_batches <- function(data,
                           features,
                           batch,
                           pmm_k = 5,
                           n_trees = 15,
                           seed = 123,
                           save = FALSE) {

  if (!is.null(seed)) {
    set.seed(seed)
  }

  if(!is.data.frame(data) && !tibble::is_tibble(data) && !is.atomic(data)) {
    stop('x must be atomic, data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }

  # Step 1
  splits <- features %>%
    dplyr::group_split(batch = (dplyr::row_number() %/% batch) + 1)

  # Step 2
  batches <- list()

  batches <- purrr::map(
    splits,
    function(split) {
      stopifnot(
        "The data object must have at least 1 missing value for imputation.
        Your data are already complete! Aren't you lucky..." = any(is.na(data))
      )
      data %>%
        dplyr::select(tidyselect::all_of(split$col))
    }
  )

  # Step 3
  time_imp <- system.time(
    {

      set.seed(123)

      suppressWarnings(
        imputed_batches <- lapply(batches,
                                  missRanger::missRanger,
                                  formula = . ~ .,
                                  pmm.k = pmm_k,
                                  num.trees = n_trees,
                                  seed = seed)
      )

    }
  )[3]

  if(save == TRUE){
    saveRDS(imputed_batches, file = "imputed_batches.rds")
  }

  # Step 4 (note: put cols from imputed obj back into same order as original data obj)
  imputed <- dplyr::bind_cols(imputed_batches, .id = "row_label") %>%
    dplyr::select(-.id)

  imputed <- imputed[names(data)]

  imputed
}

#' Complete hdImpute process: correlation matrix, flatten, rank, create batches, impute, join
#'
#' @usage hdImpute(data, batch, pmm_k, n_trees, seed, save)
#' @param data Original data frame (with missing values)
#' @param batch Numeric. Batch size.
#' @param pmm_k Integer. Number of neighbors considered in imputation. Default set at 5.
#' @param n_trees Integer. Number of trees used in imputation. Default set at 15.
#' @param seed Integer. Seed to be set for reproducibility.
#' @param save Should the list of individual imputed batches be saved as .rds file to working directory? Default set to FALSE.
#' @details Step 1. group data by dividing the \code{row_number()} by batch size (\code{batch}, number of batches set by user) using integer division. Step 2. pass through \code{group_split()} to return a list. Step 3. impute each batch individually and time. Step 4. generate completed (unlisted/joined) imputed data frame
#' @references Stekhoven, D. J., & Bühlmann, P. (2012). MissForest—non-parametric missing value imputation for mixed-type data. Bioinformatics, 28(1), 112-118.
#' @return A completed, imputed data set
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' impute_batches(data = data,
#' batch = 2,  pmm_k = 5, n_trees = 15,
#' seed = 123, save = FALSE)
#' }
hdImpute <- function(data,
                     batch,
                     pmm_k = 5,
                     n_trees = 15,
                     seed = 123,
                     save = FALSE) {

  if(!is.data.frame(data) && !tibble::is_tibble(data) && !is.atomic(data)) {
    stop('x must be atomic, data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }

  nvar <- ncol(data)
  data_matrix <- matrix(0,
                        nrow = nvar,
                        ncol = nvar,
                        dimnames = list(names(data),
                                        names(data)))
  x <- data.matrix(data)
  r <- !is.na(x)

  suppressWarnings(v <- abs(stats::cor(x, use = "pairwise.complete.obs",
                                       method = "pearson")))
  v[is.na(v)] <- 0
  suppressWarnings(u <- abs(stats::cor(y = x, x = r, use = "pairwise.complete.obs",
                                       method = "pearson")))
  u[is.na(u)] <- 0
  max_cor <- pmax(v, u)

# flatten and rank matrix
  ut <- upper.tri(max_cor)

  all_cor_mat <- tibble::tibble(
    row = rownames(max_cor)[row(max_cor)[ut]],
    column = rownames(max_cor)[col(max_cor)[ut]],
    cor = (max_cor)[ut]
  ) %>%
    dplyr::arrange(plyr::desc(cor))

# interweave cols for batch creation
  df_x <- all_cor_mat %>%
    dplyr::select(row) %>%
    dplyr::rename(col = row)

  df_y <- all_cor_mat %>%
    dplyr::select(column) %>%
    dplyr::rename(col = column)

# create new df, ordered by correlation
  ranked <- dplyr::bind_rows(
    df_x, df_y
  ) %>%
    dplyr::distinct(col)

# impute batches
  if (!is.null(seed)) {
    set.seed(seed)
  }

# Step 1
  splits <- ranked %>%
    dplyr::group_split(batch = (dplyr::row_number() %/% batch) + 1)

# Step 2
  batches <- list()

  batches <- purrr::map(
    splits,
    function(split) {
      stopifnot(
        "The data object must have at least 1 missing value for imputation.
        Your data are already complete! Aren't you lucky..." = any(is.na(data))
      )
      data %>%
        dplyr::select(tidyselect::all_of(split$col))
  }
  )

# Step 3
  {
    set.seed(123)

    suppressWarnings(
      imputed_batches <- lapply(batches,
                                missRanger::missRanger,
                                formula = . ~ .,
                                pmm.k = pmm_k,
                                num.trees = n_trees,
                                seed = seed)
    )
    }

  if(save == TRUE){
    saveRDS(imputed_batches, file = "imputed_batches.rds")
  }

# Step 4 (note: put cols from imputed obj back into same order as original data obj)
  imputed <- dplyr::bind_cols(imputed_batches, .id = "row_label") %>%
    dplyr::select(-.id)

  imputed <- imputed[names(data)]

  imputed
}
