#' Carry out a rotation randomization test.
#'
#' Carry out a rotation test (as applied in Miller et al. 2004 and detailed in DeRuiter and Solow 2008). This test is a
#' variation on standard randomization or permutation tests that is appropriate for time-series of non-independent events
#' (for example, time series of behavioral events that tend to occur in clusters).
#'
#' This implementation of the rotation test compares a test statistic (some summary of
#' an "experimental" time-period) to its expected value during non-experimental periods. Instead of resampling random subsets of observations from the original dataset,
#' the rotation test samples many contiguous blocks from the original data, each the same duration as the experimental period. The summary statistic,
#' computed for these "rotated" samples, provides a distribution to which the test statistic from the data can be compared.
#' @inheritParams rotate
#' @param exp_period A two-column vector, matrix, or data frame specifying the start and end times of the "experimental" period for the test. If a matrix or data frame is provided, one column should be start time(s) and the other end time(s). Note that all data that falls into any experimental period will be concatenated and passed to \code{ts_fun}. If finer control is desired, consider writing your own test using the underlying function \code{rotate}.
#' @param n_rot Number of rotations (randomizations) to carry out. Default is \code{n_rot=10000}.
#' @param ts_fun A function to compute the test statistic. Input provided to this function will be the times of events that occur during the "experimental" period.  The default function is \code{length} - in other words, the default test statistis is the number of events that happen during the experimental period.
#' @param skip_sort Logical. Should times be sorted in ascending order? Default is \code{skip_sort=FALSE}.
#' @param conf_level Confidence level to be used for the bootstrap CI calculation, specified as a proportion. (default is \code{conf_level=0.95}, or 95\% confidence.)
#' @param return_rot_stats Logical. Should output include the test statistics computed for each rotation of the data? Default is \code{return_rot_stats=FALSE}.
#' @param ... Additional inputs to be passed to \code{ts_fun}
#' @return A list containing the following components:
#' \itemize{
#'   \item{\strong{result}}{, A one-row data frame with rows:
#'   \itemize{
#'      \item{\strong{statistic: }}{Test statistic (from original data)}
#'      \item{\strong{p_value: }}{P-value of the test (2-sided)}
#'      \item{\strong{n_rot: }}{Number of rotations}
#'      \item{\strong{CI_low: }}{Lower bound on rotation-resampling percentile-based confidence interval}
#'      \item{\strong{CI_up: }}{Upper bound on rotation-resampling percentile-based confidence interval}
#'      \item{\strong{conf_level: }}{Confidence level, as a proportion}
#'
#'      }}
#'   \item{\strong{rot_stats}}{ (If \code{return_rot_stats} is TRUE), a vector of \code{n_rot} statistics from the rotated datasets}
#'   }
#'
#' @export
#' @references
#'    Miller, P. J. O., Shapiro, A. D., Tyack, P. L. and Solow, A. R. (2004). Call-type matching in vocal exchanges of free-ranging resident killer whales, Orcinus orca. Anim. Behav. 67, 1099–1107.
#'
#'    DeRuiter, S. L. and Solow, A. R. (2008). A rotation test for behavioural point-process data. Anim. Behav. 76, 1103–1452.
#' @seealso Advanced users seeking more flexibility may want to use the underlying function \code{\link{rotate}} to carry out customized rotation resampling. \code{\link{rotate}} generates one rotated dataset from \code{event_times} and \code{exp_period}.
#' @examples
#' r <- rotation_test(
#'   event_times =
#'     2000 * runif(500),
#'   exp_period = c(100, 200),
#'   return_rot_stats = TRUE, ts_fun = mean
#' )
rotation_test <- function(event_times, exp_period, full_period = range(event_times, na.rm = TRUE),
                          n_rot = 10000, ts_fun = length, skip_sort = FALSE,
                          conf_level = 0.95, return_rot_stats = FALSE, ...) {
  # Input checking
  # ============================================================================
  if (missing(event_times) | missing(exp_period)) {
    stop("event_times and exp_period are required inputs.")
  }

  if (sum(is.na(exp_period)) > 0) {
    stop("start/end times in can not contain any missing (NA) values.")
  }

  if (sum(is.na(event_times)) > 0) {
    message("Warning (rotation_test): missing values in event_times will be ignored.")
    event_times <- stats::na.omit(event_times)
  }

  # arrange exp_period as a data frame with columns st and et (start and end time(s))
  if (length(exp_period) > 2) {
    exp_period <- data.frame(exp_period)
    names(exp_period) <- c("st", "et")
  } else {
    exp_period <- data.frame(st = min(exp_period), et = max(exp_period))
  }
  # sort times if skip_sort is FALSE
  if (skip_sort == "FALSE") {
    event_times <- event_times[order(event_times)]
  }

  # Carry out rotation test
  # ==================================================================

  # get event times from experimental time period
  get_e_data <- function(event_times, exp_period) {
    e_data <- event_times[event_times >= exp_period[1, "st"] &
      event_times <= exp_period[1, "et"]]

    if (nrow(exp_period) > 1) { # if multiple experimental periods,
      for (p in 2:nrow(exp_period)) { # loop over experimental periods.
        e_data <- c(e_data, event_times[event_times >= exp_period["st", p] &
          event_times <= exp_period["et", p]])
      }
    }
    return(e_data)
  }

  e_data <- get_e_data(event_times = event_times, exp_period = exp_period)
  # compute test statistic for observed dataset
  data_ts <- ts_fun(e_data, ...)

  # find TS for n_rot rotations
  rot_stats <- numeric(length = n_rot)
  for (b in 1:n_rot) {
    rot_events <- rotate(event_times, full_period)
    rot_e_dat <- get_e_data(rot_events, exp_period = exp_period)
    rot_stats[b] <- ts_fun(rot_e_dat, ...)
  }

  # fill results data.frame
  result <- data.frame(statistic = data_ts)
  result$CI_low <- stats::quantile(rot_stats, (1 - conf_level) / 2)
  result$CI_up <- stats::quantile(rot_stats, 1 - (1 - conf_level) / 2)
  result$n_rot <- n_rot
  result$conf_level <- conf_level
  result$p_value <- 2 * (sum(rot_stats >= data_ts) + 1) /
    (n_rot + 1)
  result$p_value <- ifelse(result$p_value > 1,
    2 * (sum(rot_stats <= data_ts) + 1) / (n_rot + 1),
    result$p_value
  )

  if (!return_rot_stats) {
    return(list(result = result))
  } else {
    return(list(result = result, rot_stats = rot_stats))
  }
}