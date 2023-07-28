#' Find features with (specified amount of) missingness
#'
#' @usage check_feature_na(data, threshold)
#' @param data A data frame or tibble.
#' @param threshold Missingness threshold in a given column/feature as a proportion bounded between 0 and 1. Default set to sensitive level at 1e-04.
#' @return A vector of column/feature names that contain missingness greater than \code{threshold}.
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' check_feature_na(data = any_data_frame, threshold = 1e-04)
#' }
check_feature_na <- function(data, threshold = 1e-04){
  if(!is.data.frame(data) && !tibble::is_tibble(data)) {
    stop('`data` must be data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }

  if (threshold < 0) {
    stop('threshold must contain only positive values')
  }

  data %>%
    purrr::map_dbl(~ round(mean(is.na(.)), 3)) %>%
    tibble::tibble() %>%
    dplyr::mutate(var = names(data)) %>%
    dplyr::arrange(plyr::desc(.)) %>%
    dplyr::relocate(var) %>%
    dplyr::filter(., . > threshold) %>%
    dplyr::pull(var)
}

#' Find number of and which rows contain any missingness
#'
#' @usage check_row_na(data, which)
#' @param data A data frame or tibble.
#' @param which Logical. Should a list be returned with the row numbers corresponding to each row with missingness? Default set to FALSE.
#' @return Either an integer value corresponding to the number of rows in \code{data} with any missingness (if \code{which = FALSE}), or a tibble containing: 1) number of rows in \code{data} with any missingness, and 2) a list of which rows/row numbers contain missingness (if \code{which = TRUE}).
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' check_row_na(data = any_data_frame, which = FALSE)
#' }
check_row_na <- function(data, which = FALSE){
  if(!is.data.frame(data) && !tibble::is_tibble(data)) {
    stop('`data` must be data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }

  if(which == FALSE) {
    data %>%
      dplyr::filter(dplyr::if_any(.fns = is.na)) %>%
      nrow()
  } else {
    tibble::tibble(
      n_rows_missing = data %>%
        dplyr::filter(dplyr::if_any(.fns = is.na)) %>%
        nrow(),
      which_rows = list(data[!complete.cases(data), ] %>%
                          row.names() %>%
                          as.integer()
                        )
    )
  }
}
