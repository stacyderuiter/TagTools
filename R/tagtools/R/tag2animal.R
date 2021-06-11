#' Tag-frame to animal-frame conversion
#'
#' Convert tag frame measurements to animal frame using pre-determined tag orientation(s) on the animal.
#'
#' @param X Data from a triaxial sensor such as an accelerometer, magnetometer or a gyroscope. X can be a three column matrix or a sensor structure (\strong{not} a data frame or tbl). In either case, X is in the tag frame, i.e., expressed in the canonical axes of the tag, not the animal. X can have any unit and any regular sampling rate (i.e., measurements are regularly sampled; equally spaced in time).
#' @param sampling_rate (optional) The sampling rate of the sensor data in Hz (samples per second). This is only needed if X is not a sensor structure. If X is a sensor data list, sampling_rate is obtained from its metadata (X$sampling_rate).
#' @param OTAB is a matrix defining the orientation of the tag on the animal as a function of time. Each row of OTAB is: \code{cue1, cue2, pitch, roll, heading}. (See \strong{Details}.)
#' @param Ya is an optional sensor structure in which the sensor data has already been
#' converted to the animal frame. The OTAB is extracted from this structure. This
#' is useful, for example, to replicate tag-to-animal conversions at different
#' sampling rates.
#' @details This function uses the OTAB matrix to convert sensor data \code{X} from tag frame of reference to whale frame of reference.
#' Each row of OTAB is: \code{cue1, cue2, pitch, roll, heading}
#' where cue1 is the start time of a move in seconds with respect to the
#' start of X. cue2 is the end time of the move. If cue1 and cue2 are the
#' same, the move is instantaneous, otherwise a gradual move will be implemented
#' in which the orientation of the tag is linearly interpolated between the
#' previous and the new orientation.
#' The pitch, roll and heading angles describe the tag orientation on the
#' animal at the end of the move (angles are in radians).
#' The first row of OTAB must have cue1 and cue2 equal to 0 as this is the initial
#' orientation of the tag on the animal. Subsequent rows (if any) of OTAB describe
#' @seealso [prh_predictor1], [prh_predictor2]
#' @export
#' @return Xa,the sensor data in the animal frame, i.e., rotated to correct for the tag
#' orientation on the animal. If X is a sensor structure, Xa will also be one. In this
#' case the structure elements 'frame' and 'name' will be changed. The OTAB will also
#' be added to the structure.
#' @export
#' @examples
#' \dontrun{
#' # See animaltags.org for examples of how to use this function.
#' }
#'
tag2animal <- function(X, sampling_rate, OTAB, Ya = NULL) {
  #*******************************************
  # input checking
  #*******************************************
  Xa <- NULL

  if (missing(sampling_rate) & !is.list(X)) {
    # if X is a matrix, then sampling_rate must be provided
    error("input sampling_rate is require for tag2animal conversion, unless X is an animaltags data structure")
  }

  if (is.list(X)) { # get sampling_rate and data from X is X is animaltags sensor structure
    sampling_rate <- X$sampling_rate
    Xa <- X
    X <- X$data
  }

  if (is.list(Ya)) { # if 2nd sensor structure is given from which to extract OTAB
    if ("OTAB" %in% toupper(names(Ya))) {
      otab_contents <- Ya[[toupper(names(OTAB)) == "OTAB"]]
      if (is.character(otab_contents)) {
        stop(sprintf(
          'OTAB reads "%s" and can not be processed.',
          otab_contents
        ))
      }
      OTAB <- matrix(otab_contents, ncol = 5, byrow = TRUE)
    } else {
      stop("input Ya must be a sensor data structure with OTAB field.\n")
    }
  } # end of "if Ya is provided"

  if (!is.matrix(X) | nrow(X) == 0) {
    stop("No X data (or empty data) provided.\n")
  }

  #*******************************************
  # Checks/adjustments to OTAB
  #*******************************************

  # first OTAB entry must be a fixed-point (i.e., cue2=0)
  if (any(OTAB[1, 1:2] != 0)) {
    message(" Adjusting first OTAB entry to have time 0\n")
    OTAB[1, 1:2] <- 0
  }

  if (nrow(OTAB) > 1) {
    # sort OTAB in ascending order by "cue1" (first column)
    OTAB <- OTAB[order(OTAB[, 1]), ]
    PTAB <- o2p(OTAB)
    # time stamps
    t <- matrix(c(0:(nrow(X) - 1)) / sampling_rate, ncol = 1)
    if (PTAB[nrow(PTAB), 1] < tail(t, 1)) {
      PTAB <- rbind(PTAB, matrix(c(tail(t, 1), PTAB[nrow(PTAB), 2:4]), nrow = 1))
    }
    prh <- matrix(0, nrow = nrow(t), ncol = 3)
    for (col in c(2:4)) {
      # linear interpolation of PTAB entries to be same n rows as t
      prh[, col] <- stats::approx(PTAB[, 1], PTAB[, col], t)
    }
  } else { # if OTAB has only one row
    prh <- OTAB[, 3:5]
  }

  #*******************************************
  # Apply OTAB (rotate data)
  #*******************************************

  Q <- euler2rotmat(p = prh[, 1], r = prh[, 2], h = prh[, 3])
  X <- rotate_vecs(X, Q)

  #*******************************************
  # Add metadata to Xa, if structure output needed
  #*******************************************
  if (~ is.null(Xa)) {
    Xa$otab <- matrix(t(OTAB), ncol = 1)
    Xa$frame <- "animal"
    Xa$name <- paste(Xa$name, "a", sep = "")
    Xa$data <- X
    if (!"history" %in% names(Xa) | length(Xa$history) == 0) {
      Xa$history <- "tag2animal"
    } else {
      Xa$history <- paste(Xa$history, "tag2animal", sep = ",")
    } # end of entering history
  } else { # end of "if Xa exists"
    Xa <- X
  }

  return(Xa)

  #*******************************************
  # o2p (helper to create PTAB from OTAB)
  #*******************************************
  o2p <- function(OTAB) {
    SMALL <- 0.1 # duration in seconds of the shortest move
    n <- nrow(OTAB)
    k <- 1

    while (k < nrow(OTAB)) {
      # remove overlapping events
      kk <- which(OTAB[k, 2] + SMALL < OTAB[c((k + 1):nrow(OTAB)), 1])
      OTAB <- OTAB[c(1:k, k + kk), ]
      k <- k + 1
    }

    if (nrow(OTAB) < n) {
      message("Overlapping events found in OTAB and removed\n")
    }

    # force sudden moves to have duration SMALL
    k <- which(OTAB[, 1] == OTAB[, 2])
    OTAB[k, 2] <- OTAB[k, 1] + SMALL

    PTAB <- matrix(OTAB[1, c(1, 3:5)], nrow = 1) # initialise PTAB
    for (k in c(2:nrow(OTAB))) { # add any moves in the OTAB
      if (OTAB[k, 2] > OTAB[k, 1]) {
        # mat: PTAB = [PTAB; OTAB(k,1) PTAB(end,2:4)] ;
        PTAB <- rbind(PTAB, cbind(OTAB[k, 1], t(PTAB[nrow(PTAB), c(2:4)])))
        PTAB <- rbind(PTAB, OTAB[k, c(2:5)])
      } else {
        PTAB <- rbind(PTAB, OTAB[k, c(1, 3:5)])
      }
    }
    # check for angles wrapping at +/- 180 degrees
    PTAB[, 2:4] <- apply(X = PTAB[, c(2:4)], MARGIN = 2, FUN = signal::unwrap)
    return(PTAB)
  } # end of o2p function
} # end of tag2animal function