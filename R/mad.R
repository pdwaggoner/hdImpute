#' Compute variable-wise mean absolute differences (MAD) between original and imputed dataframes.
#'
#' @usage mad(original, imputed, round)
#' @param original A data frame or tibble with original values.
#' @param imputed A data frame or tibble that has been imputed/completed.
#' @param round Integer. Number of places to round MAD scores. Default set to 3.
#' @return `mad_scores` as `p` x 2 tibble. One row for each variable in \code{original}, from 1 to `p`. Two columns: first is variable names (`var`) and second is associated MAD score (`mad`) as percentages for each variable.
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' mad(original = original_data, imputed = imputed_data, round = 3)
#' }
mad <- function(original, imputed, round = 3){

if(!is.data.frame(original) && !tibble::is_tibble(original)) {
  stop('`original` must be data frame or tibble\n',
       '  You have provided an object of class: ', class(original)[1])
}

if(!is.data.frame(imputed) && !tibble::is_tibble(imputed)) {
  stop('`imputed` must be data frame or tibble\n',
       '  You have provided an object of class: ', class(imputed)[1])
}

  vars <- original %>%
    names()

  mad <- vector()

  for (i in vars) {

    orig <- original %>%
      dplyr::group_by(original[[i]]) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      tidyr::drop_na() %>%
      dplyr::mutate(prop = round(n / sum(n) * 100, 2))

    imp <- imputed %>%
      dplyr::group_by(imputed[[i]]) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      dplyr::mutate(prop = round(n / sum(n) * 100, 2))

    mad[i] <- round(sum(abs(orig$prop - imp$prop)) / nlevels(factor(original[[i]])), round)

    if (any(mad > 100)) {
      warning('MAD scores are bounded between 0 and 100\n',
              'At least one score is > 100. Check and correct.')
    }

    if (any(mad < 0)) {
      warning('MAD scores are non-negative measures of deviations from ground truth.\n',
              'At least one score is < 0. Check and correct.')
    }
  }

  return(
  tibble::tibble(
    var = vars,
    mad = mad
  )
  )

}
