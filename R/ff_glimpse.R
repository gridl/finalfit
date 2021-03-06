#' Descriptive statistics for dataframe
#'
#' Everyone has a funcion like this, str, glimpse, glance etc. This one is
#' specifically designed for use with \code{finalfit} language. It is different
#' in dividing variables by numeric vs factor, the former using
#' \code{link[psych]{describe}}.
#'
#' @param .data Dataframe.
#' @param dependent Optional character vector: name(s) of depdendent
#'   variable(s).
#' @param explanatory Optional character vector: name(s) of explanatory
#'   variable(s).
#' @param digits Significant digits for continuous variable summaries
#'
#' @return Dataframe on summary data.
#' @export
#' @importFrom stats median
#'
#' @examples
#' library(finalfit)
#' dependent = 'mort_5yr'
#' explanatory = c("age.factor", "extent.factor", "perfor.factor")
#' colon_s %>%
#'   finalfit_glimpse(dependent, explanatory)

ff_glimpse <- function(.data, dependent=NULL, explanatory=NULL, digits = 1){
  if(is.null(dependent) && is.null(explanatory)){
    df.in = .data
  }else{
    keep = names(.data) %in% c(dependent, explanatory)
    df.in = .data[keep]
  }

  # Continuous
  df.in %>%
    dplyr::select_if(is.numeric) -> df.numeric

  if(dim(df.numeric)[2]!=0){
   df.numeric %>%
    ff_describe(na.rm = TRUE, interp=FALSE, skew = FALSE, ranges = TRUE,
                check=TRUE,fast=F, omit=FALSE) %>%
    format(digits = digits, scientific=FALSE) %>%
      dplyr::select(-vars)-> df.numeric.out1

  df.numeric %>%
    lapply(function(x){
      label = attr(x, "label")
      list(label=label)
    }) %>%
    do.call(rbind, .) -> df.numeric.out2

  df.numeric.out = data.frame(df.numeric.out2, df.numeric.out1)

  }else{
    df.numeric.out = df.numeric
  }

  # Factors
  df.in %>%
    dplyr::select_if(Negate(is.numeric)) -> df.factors

  if(dim(df.factors)[2]!=0){
   df.factors %>%
    lapply(function(x){
      n = which(!is.na(x)) %>% length()
      missing_n = which(is.na(x)) %>% length()
      missing_percent = format(missing_n*100/length(x), digits = 2)
      label = attr(x, "label")
      levels_n = length(levels(x))
      levels = ifelse(is.factor(x),
                      levels(x) %>%
                        paste0("\"", ., "\"", collapse = ", "),
                        "-")
      levels_count = ifelse(is.factor(x),
                            summary(x) %>%
                              paste(collapse = ", "),
                            "-")
      levels_percent = ifelse(is.factor(x),
                              summary(x) %>%
                                prop.table() %>%
                                `*`(100) %>%
                                format(digits = 2) %>%
                                paste(collapse=", "),
                              "-")
      list(label=label, n=n, missing_n = missing_n, missing_percent = missing_percent,
           level_n=levels_n, levels=levels,
           levels_count=levels_count, levels_percent = levels_percent)
    }
    ) %>%
    do.call(rbind, .) %>%
    data.frame() -> df.factors.out

  }else{
    df.factors.out = df.factors
  }

  cat("Numerics\n")
  print(df.numeric.out, row.names = TRUE)
  cat("\nFactors\n")
  print(df.factors.out, row.names = TRUE)

  return(invisible(
    list(
      numerics = df.numeric.out,
      factors = df.factors.out))
  )
}

#' @rdname ff_glimpse
#' @export
finalfit_glimpse <- ff_glimpse
