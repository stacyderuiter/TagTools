#' Measure tortuosity index 
#' 
#' This function is used to measure the toruosity of a regularly sampled horizontal track. Tortuosity can be measured in a number of ways. This function compares the stretched-out track length (STL) over an interval of time with the distance made good (DMG, i.e., the distance actually covered in the interval). The index returned is (STL-DMG)/STL which is 0 for straightline movement and 1 for extreme circular movement.
#' @param T Contains the animal positions in a local horizontal plane. T has a row for each position and two columns: northing and easting. The positions can be in any consistent spatial unit, e.g., metres, km, nautical miles, and are referenced to an arbitrary 0,0 location. T cannot be in degrees as the distance equivalent to a degree latitude is not the same as for a degree longitude.
#' @param sampling_rate The sampling rate of the positions in Hertz (samples per second).
#' @param intvl The time interval in seconds over which tortuosity is calculated. This should be chosen according to the scale of interest, e.g., the typical length of a foraging bout.
#' @return The tortuosity index which is between 0 and 1 as described above. t contains a value for each period of intvl seconds.
#' @note This tortuosity index is fairly insensitive to speed so if T is produced by dead-reckoning (e.g., using ptrack or htrack), the speed estimate is not important. Also the frame of T is not important as long as the two axes (nominally called northing and easting) used to describe the positions are perpendicular.
#' @examples 
#' \dontrun{ 
#' BW <- beaked_whale
#' T <- ptrack(A = BW$A$data, M = BW$M$data, s = 3, 
#' sampling_rate = BW$A$sampling_rate, 
#' fc = NULL, include_pe = TRUE)$T
#' t <- tortuosity(T, sampling_rate = BW$A$sampling_rate, intvl = 25)
#' }
#' @export

tortuosity <- function(T, sampling_rate, intvl) {
  k <- round(sampling_rate * intvl) 
  N <- buffer(T[, 1], k, 0, nodelay = TRUE)
  E <- buffer(T[, 2], k, 0, nodelay = TRUE)
  lmg <- t(sqrt((E[nrow(E), ] - E[1, ])^2 + (N[nrow(N), ] - N[1, ])^2))
  stl <- t(colSums(sqrt(diff(E)^2 + diff(N)^2)))
  t <- t((stl - lmg) / stl) 
  t <- cbind(t, matrix(0, nrow(t), 1))
  t[, 2] <- t(sqrt(colMeans((N - pracma::repmat(colMeans(N), nrow(N),1))^2 + (E - pracma::repmat(colMeans(E), nrow(E), 1))^2)))
  return(t)
}
