#' Convert latitude-longitude track points into a local level frame
#'
#' @param trk A data frame, two-column matrix, or two-element vector  of track points c(latitude, longitude)
#' @param pt c(latitude, longitude) of the centre point of the local level frame. If pt is not given, the first point in the track will be used.
#' @return A data frame with columns \code{northing} and \code{easting} of track points in the local level frame. Northing and easting are in metres. The axes of the frame are true (geographic) north and true east.
#' @export
#' @examples \dontrun{
#'
#' }
#' @note This function assumes the track is on the surface of the geoid,
#'  and also uses a simple spherical model for the geoid. For
#'  more accurate conversion to a Cartesian frame, use spatial and mapping packages in Matlab/Octave.

lalo2llf <- function(trk, pt) {
  if (missing(pt)) {
    if (is.matrix(trk) | "data.frame" %in% class(trk)) {
      pt <- trk[1, ]
    } else {
      stop("Unrecognized format for input trk")
    }
  }

  trk <- trk - data.frame(
    lat = rep(pt[1], nrow(trk)),
    long = rep(pt[2], nrow(trk))
  )
  NE <- data.frame(
    northing = trk[, 1] * 1852 * 60,
    easting = trk[, 2] * 1852 * 60 * cos(pt[1] * pi / 180)
  )
  return(NE)
}