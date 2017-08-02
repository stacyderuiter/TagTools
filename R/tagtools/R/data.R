#' Set of sensor lists for a beaked_whale
#'
#' Data is from a _Mesoplodon densirostris_ with tag ID md13_134a. The device used was a DTAG3 and it was deployed at 2013-05-14 12:42:00 in El Hierro, Canary Islands, Spain.
#'
#' @format A set of sensor lists:
#' \describe{
#'   \item{A}{sensor list contining a triaxial acceleration matrix sampled at 25 Hz}
#'   \item{M}{sensor list containing a triaxial magnetometer matrix sampled at 25 Hz}
#'   \item{P}{sensor list containing a pressure (depth) vector sampled at 25 Hz}
#' }
"beaked_whale"

#' Set of sensor lists for a harbor seal
#'
#' Data is from a _Phoca vitulina_ with tag ID 'hs16_265c'. The device used was a DTAG4 and it was deployed at 2016-09-21 07:55:22 in Husum, Germany.
#'
#' @format A set of sensor lists:
#' \describe{
#'   \item{A}{sensor list contining a triaxial acceleration matrix sampled at 5 Hz}
#'   \item{M}{sensor list containing a triaxial magnetometer matrix sampled at 5 Hz}
#'   \item{P}{sensor list containing a pressure (depth) vector sampled at 5 Hz}
#'   \list{POS}{sensor list containing a position matrix with columns [sampling time, latitude, longitude]}
#' }
"harbor_seal"