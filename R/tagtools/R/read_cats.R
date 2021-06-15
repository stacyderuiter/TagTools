
#' Read a CATS data file and convert to .nc
#'
#' Read a .csv file with data from a CATS tag deployment, including associated metadata, and store the resulting data in a .nc file.
#' @param fname is the file name of the CATS CSV file including the complete
#' path name if the file is not in the current working directory or in a
#' directory on the path. The .csv suffix is optional.
#' @param depid is a string containing the deployment identification code assigned
#' to this deployment, for example, 'mn12_186a'.
#' @return A string (constructed by: '\code{depid}_raw.nc'; for example, 'mn12_186a_raw.nc') containing the file name of the netCDF (.nc) file in which the output has been saved. This function
#' generates a netCDF file in the current working directory containing
#' 		the tag data variables, including:
#' 		\itemize{
#' 		\item {A, Accelerometer data structure}
#' 		\item {M, Magnetometer data structure}
#' 		\item {T, Temperature sensor data structure}
#' 		\item {info	Information structure for the deployment}
#' 		}
#' @note CATS loggers can produce very large csv files which are slow to
#' process. This function is (somewhat) optimised for speed and memory use so will
#' tolerate large files. But processing could be slow.
#' @export
#' @examples \dontrun{
#' nc_filename <- read_cats("my_cats_file.csv", "my_cats_deplyment_name")
#' load_nc("my_cats_deployment_name_raw.nc")
#' }
read_cats <- function(fname, depid) {
  V <- read_cats_csv(fname)
  info <- list(
    depid = depid,
    data_source = fname,
    data_nfiles = "1",
    data_format = "csv",
    device_serial = NULL,
    device_make = "CATS",
    device_type = "Archival",
    device_model_name = NULL,
    device_model_version = NULL,
    device_url = NULL,
    dephist_device_tzone = "0",
    dephist_device_regset = "dd-mm-yyyy HH:MM:SS",
    dephist_device_datetime_start = as.character(V[1, 1])
  )

  # time stuff
  dT <- as.numeric(diff(V[, 1] - rep(V[1, 1], nrow(V))))
  md <- stats::median(dT)
  km <- abs(dT - md) < 0.5 * md
  if (sum(km) < 0.75 * length(dT)) {
    warning("Many gaps in sampling. Inferred sampling rate may be inaccurate.\n")
  }
  # inferred sampling rate in Hertz
  sampling_rate <- 1 / mean(dT[km])

  # check which sensors are present
  Sens <- c("Acc", "Mag", "Gyr", "Temp", "Depth", "Light")
  Sens_name <- c(
    "3 axis Accelerometer", "3 axis Magnetometer", "3 axis Gyroscope",
    "Temperature", "Pressure", "Light level"
  )
  ax <- c(3, 3, 3, 1, 1, 1)
  # note: GPS are not well dealt with yet!!
  sl <- list()
  SS <- vector("logical", length = length(Sens))

  for (k in c(1:length(Sens))) {
    cols <- grep(Sens[k], names(V))
    if (any(!is.na(V[, cols]))) {
      sl <- paste(sl, Sens_name[k], ",", sep = "")
      SS[k] <- TRUE
    }
  }

  info$sensors_list <- sl
  nc_file <- paste(depid, "_raw.nc", sep = "")


  #******************************
  # I THINK CATS ACCEL IS
  # NED axes and need to change to FRU for tag tools
  #******************************

  #*********************************
  # HELPER FUNCTION
  save_sens_struct <- function(X, depid, sampling_rate, fname, name, naxes) {
    nc_file <- paste(depid, "_raw.nc", sep = "")
    cols <- grep(name, names(X))
    if (length(cols) > 0) {
      if (length(cols) < naxes) {
        warning(sprintf(" Warning: %d axes of %s missing in data\n", naxes - length(k), name))
      }
      if (naxes > 1) {
        # make sure column indices are ordered x, then y, then z
        # this assumes x, y, z cols of same sensor are named such that
        # alphabetical sorting --> x, y, z order
        cols <- cols[order(names(X)[cols])]
      } else {
        cols <- cols[1]
      }
      if (grepl("gyr", name)) {
        scf <- 0.001 # gyroscope unit is mrad/s. Multiply by 0.001 to get rad/s
      } else {
        scf <- 1 # all other units are standard
      }
      # pull names off data and make it a matrix
      X <- as.matrix(X[, cols])
      dimnames(X) <- NULL
      S <- sens_struct(
        data = X,
        sampling_rate, depid = depid, type = name
      )
      S$history <- "read_cats"
      S$files <- fname
      if (grepl("light", name)) {
        S$unit <- "1"
        S$unit_name <- "counts"
        S$unit_label <- "counts"
      }

      add_nc(nc_file, S, name)
    }
  } # end of save_sens_struct
  #********************************************************

  # now add sensor data
  for (k in c(1:length(Sens))) {
    if (SS[k]) {
      cols <- grep(Sens[k], names(V))
      save_sens_struct(V[, cols], depid, sampling_rate,
        fname,
        name = Sens[k], naxes = ax[k]
      )
    }
  }
  add_nc(nc_file, info, "info")
  return(nc_file)
} # end of read_cats
