# placeholder for basic helper funs

#' NA check 1
#' @param data a data frame/tibble
na_check <- function(data){
  if(!is.data.frame(data) && !tibble::is_tibble(data)) {
    stop('x must be a data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }
  sapply(data, function(x) sum(is.na(x)))
}

#' NA check 2
#' @param data a data frame/tibble
na_df <-  function(data) {
  if(!is.data.frame(data) && !tibble::is_tibble(data)) {
    stop('x must be a  data frame or tibble\n',
         '  You have provided an object of class: ', class(data)[1])
  }
  w <- sapply(data, function(data)all(is.na(data)))
  if (any(w)) {
    stop(paste("All NA in columns", paste(which(w), collapse = ", ")))
  } else {paste("Woohoo! No cols completely missing!")}
}
