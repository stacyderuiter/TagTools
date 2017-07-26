#' Sound speed estimation
#' 
#'  This function is used to estimate the sound speed using Coppens equation
#' @note Range of validity: temperature 0 to 35 °C, salinity 0 to 45 parts per thousand, depth 0 to 4000 m
#' @param T The temperature in degrees C
#' @param D (optional) The depth in meters (defaults to 1 m)
#' @param S The salinity in part-per-thousand (defaults to 35 ppt)
#' @return The sound speed in m/s
#' @note Source: http://resource.npl.co.uk/acoustics/techguides/soundseawater/content.html#UNESCO
#' @export
#' @example sound_speed(8, 1000, 34)
#'          #Returns: 1497.7 m/s

sound_speed <- function(T, D = NULL, S = NULL) {
  if (missing(T)) {
    stop("input for T required")
  }
  if (is.null(D)) {
    D <- 1
  }
  if (is.null(S)) {
    S <- 35
  }
  #v = 1449.2+4.6*T-0.055*T.^2+0.00029*T.^3+(1.34-0.01*T).*(S-35)+0.016*D ;
  t <- T / 10 
  D <- D / 1000
  v0 <- 1449.05 + 45.7 * t - 5.21 * t^2 + 0.23 * t^3 + (1.333 - 0.126 * t + 0.009 * t^2) * (S - 35)
  v <- v0 + (16.23 + 0.253 * t) * D + (0.213 - 0.1 * t) * D^2 + (0.016 + 0.0002 * (S - 35)) * (S - 35) * t * D 
  return(v)
}