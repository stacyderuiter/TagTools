#' Predict the tag position on a diving animal from depth and acceleration data
#'
#' Predict the tag position on a diving animal parametrized by p0, r0, and
#' h0, the canonical angles between the principal axes of the tag and the animal.
#' The tag orientation on the animal can change with time and this function
#' provides a way to estimate the orientation at the start and end of each suitable
#' dive. The function critically assumes that the animal makes a sequence of short
#' dives between respirations and that the animal remains upright (i.e., does not roll)
#' during these shallow dives. See prh_predictor1 for a method more suitable to animals
#' that rest horizontally at the surface. The function provides a graphical interface showing the estimated tag-to-animal
#' orientation throughout the deployment. Follow the directions above the top panel
#' of the figure to edit or delete an orientation estimate.
#' The function provides a graphical interface showing the estimated tag-to-animal
#' orientation throughout the deployment. Follow the directions above the top panel
#' of the figure to edit or delete an orientation estimate.
#'
#' @param P is a dive depth vector or sensor structure with units of m H2O.
#' @param A is an acceleration matrix or sensor structure with columns ax, ay, and az. Acceleration can be in any consistent unit, e.g., g or m/s^2, and must have the same sampling rate as P.
#' @param sampling_rate is the sampling rate of the sensor data in Hz (samples per second). This is only needed if neither A nor M are sensor structures.
#' @param MAXD is the optional maximum depth of near-surface dives. The default value is 10 m. This is used to find contiguous surface intervals suitable for analysis.
#' @return PRH, a data frame with columns \code{cue} \code{p0}, \code{r0}, \code{h0}, and \code{q}
#' with a row for each dive edge analysed. \code{cue} is the time in second-since-tag-start of the dive edge analysed.
#' \code{p0}, \code{r0}, and \code{h0} are the deduced tag orientation angles in radians.
#' \code{q} is the quality indicator with a low value (near 0, e.g., <0.05) indicating that the data fit more consistently with the assumptions of the method.
#' @seealso \link{prh_predictor1}, \link{tag2animal}
#' @export

prh_predictor2 <- function(P, A, sampling_rate = NULL, MAXD = 10) {
  #**************************************************
  # set defaults and constants
  #**************************************************
  MINSEG <- 30 # minimum surface segment length in seconds
  MAXSEG <- 300 # maximum surface segment length in seconds
  GAP <- 5 # keep at least 5s away from a dive edge
  PRH <- NULL

  #**************************************************
  # input checking
  #**************************************************
  if (missing(P) | missing(A)) {
    stop("prh_predictor2 requires inputs P (depth data) and A (acceleration data).\n")
  }

  if (is.list(P) & is.list(A)) {
    if (A$sampling_rate != P$sampling_rate) {
      stop("A and P must have the sample sampling rate.\n")
    }
    #**************************************************
    # prepare data
    #**************************************************
    # extract bare variables from sensor structures
    sampling_rate <- A$sampling_rate
    A <- A$data
    P <- P$data
  } else {
    if (missing(sampling_rate)) {
      stop("For prh_predictor2(), sampling_rate must be specified if A and P are matrices.")
    }
  }

  # decimate data to 5Hz if needed
  if (sampling_rate >= 7.5) {
    df <- round(sampling_rate / 5)
    P <- tagtools::decdc(P, df)
    A <- tagtools::decdc(A, df)
    sampling_rate <- sampling_rate / df
  }

  # normalise A to 1 g
  A <- A * matrix(tagtools::norm2(A)^(-1), nrow = nrow(A), ncol = 3)
  v <- depth_rate(P, sampling_rate, 0.2)
  #**************************************************
  # dive detection
  #**************************************************
  # find dive start/ends
  MAXD <- max(MAXD, 2)
  T <- find_dives(p = P, sampling_rate = sampling_rate, mindepth = MAXD)
  if (nrow(T) == 0) {
    stop(sprintf(" No dives deeper than %4.0f found - change MAXD\n", MAXD))
  }

  # augment all dive-start and dive-end times by GAP seconds
  T$start <- T$start - GAP
  T$end <- T$end + GAP

  # check if there is a segment before first dive and after last dive
  s1 <- c(max(T$start[1] - MAXSEG, 0), T$start[1])
  se <- c(T$end[nrow(T)], min(T$end[nrow(T)] + MAXSEG, (nrow(P) - 1) / sampling_rate))
  k <- tail(which(P[(round(sampling_rate * s1[1]) + 1):round(sampling_rate * s1[2])] > MAXD), 1)
  if (length(k) != 0) {
    s1[1] <- s1[1] + k / sampling_rate
  }
  k <- head(which(P[(round(sampling_rate * se[1]) + 1):round(sampling_rate * se[2])] > MAXD), 1)
  if (length(k) != 0) {
    se[2] <- se[1] + (k - 1) / sampling_rate
  }
  S <- rbind(s1, cbind(T$end[1:(nrow(T) - 1)], T$start[2:nrow(T)]), se)
  S <- S[apply(S, MARGIN = 1, FUN = diff) > MINSEG, ]

  # break up long surfacing intervals
  while (TRUE) {
    k <- head(which(apply(S, MARGIN = 1, FUN = diff) > MAXSEG), 1)
    if (length(k) == 0) {
      break
    }
    S <- rbind(
      S[1:(k - 1), ],
      S[k, 1] + c(0, MAXSEG),
      cbind(S[k, 1] + MAXSEG, S[k, 2]),
      S[(k + 1):nrow(S), ]
    )
  }

  # check for segments with sufficient variation in orientation
  V <- matrix(0, nrow = nrow(S), ncol = 1)
  for (k in c(1:nrow(S))) {
    ks <- (round(S[k, 1] * sampling_rate) + 1):round(S[k, 2] * sampling_rate)
    V[k] <- norm(stats::sd(A[ks, ]), "2")
  }

  thr <- stats::median(V) + 1.5 * stats::IQR(V) * c(-1, 1)
  S <- S[V > thr[1] & V < thr[2], ]



  #**************************************************
  # PRH inference
  #**************************************************

  PRH <- matrix(nrow = nrow(S), ncol = 5)

  for (k in c(1:nrow(S))) { # apply prh inference method on segments
    prh <- applymethod2(A, v, sampling_rate, S[k, ])
    if (is.null(prh)) {
      next
    }
    PRH[k, ] <- matrix(c(mean(S[k, 1:2]), prh), nrow = 1)
  }

  #**********************************************
  # Draw first figure
  #**********************************************
  # initial x-axis limits
  xl <- c(0, nrow(P) / sampling_rate)

  # turn off currently open graphics devices
  grDevices::graphics.off()
  # get a new graphics device that is OK for interactive
  # (not sure why need to do this twice)
  # (works on Windows, need to check mac, unix)
  grDevices::dev.new()
  # open new graphics window
  grDevices::dev.new()
  # give name to this grapics window
  # (so can later use dev.set(f1) to plot in it)
  f1 <- grDevices::dev.cur()

  main_f1_prompt <- "click to print value, or type:\n e to edit, x to delete, z or Z to zoom in/out, or q to quit"
  plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)

  #*************************************************
  # prep to draw second figure
  #*************************************************
  # open a second window for the second plot
  grDevices::dev.new()
  # give a name to the second graphics window
  f2 <- grDevices::dev.cur()
  main_f2_prompt <- "type 1 or 2 to adjust box, x to erase PRH point, or q to return"

  #*********************************************
  # Run the interative part of fig. 1
  #*********************************************

  # select first figure window
  grDevices::dev.set(f1)
  # set initial statuses for figures (they change to "Done" when user quits)
  fig1_status <- "initial"
  fig2_status <- "initial"

  while (fig1_status != "Done") {
    grDevices::dev.set(f1)
    if (fig1_status == "zoom in") {
      grDevices::setGraphicsEventHandlers(
        which = f1,
        prompt = "Choose new center point",
        onMouseDown = get_clicked_pt
      )
      zoom_ctr <- grDevices::getGraphicsEvent()
      xl <- zoom_ctr$x + diff(xl) / 4 * c(-1, 1)
      xl[1] <- max(xl[1], 0)
      xl[2] <- min(xl[2], nrow(P) / sampling_rate)
      grDevices::dev.set(f1)
      plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)
    } # end of zooming in

    if (fig1_status == "zoom out") {
      xl <- xl[1] + 0.5 * diff(xl) + diff(xl) * c(-1, 1)
      xl[1] <- max(xl[1], 0)
      xl[2] <- min(xl[2], length(P) / sampling_rate)
      grDevices::dev.set(f1)
      plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)
    }

    if (fig1_status == "delete point") {
      grDevices::dev.set(f1)
      grDevices::setGraphicsEventHandlers(
        which = f1,
        prompt = "Choose PRH point to delete",
        onMouseDown = get_clicked_pt
      )
      to_del <- grDevices::getGraphicsEvent()
      kd <- which.min(abs(to_del$x - PRH[, 1]))
      # remove this dive from S and PRH
      S <- S[-kd, ]
      # delete the row but make sure PRH never turns from matrix to vector
      PRH <- matrix(PRH[-kd, ], ncol = 5, byrow = TRUE)
      # then need to re-plot figure 1 because fewer segments are there
      grDevices::dev.set(f1)
      plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)
    }

    if (fig1_status == "edit") { # if editing point
      # get point to edit
      grDevices::dev.set(f1)
      grDevices::setGraphicsEventHandlers(
        which = f1,
        prompt = "Click PRH point to edit",
        onMouseDown = get_clicked_pt
      )
      to_ed <- grDevices::getGraphicsEvent()
      fig1_status <- "point edited"
      ke <- which.min(abs(to_ed$x - PRH[, 1]))

      # plot 2nd figure
      seg <- S[ke, ]
      prh <- PRH[ke, ]

      grDevices::dev.set(f2)
      plot_prh_fig2_m2(A, v, sampling_rate, seg, prh, main_f2_prompt)

      while (fig2_status != "Done") {
        # edit a point in the second figure
        grDevices::setGraphicsEventHandlers(
          which = f1,
          prompt = "WINDOW INACTIVE - DO NOT CLICK"
        )
        grDevices::setGraphicsEventHandlers(
          which = f2,
          prompt = main_f2_prompt,
          onKeybd = keybd2,
          onMouseDown = mousedown1
        )
        fig2_status <- grDevices::getGraphicsEvent()

        if (fig2_status == "x") {
          # remove this dive from S and PRH
          S <- matrix(S[-ke, ], ncol = 5, byrow = TRUE)
          PRH <- matrix(PRH[-ke, ], ncol = 5, byrow = TRUE)
          # then need to re-plot figure 1 because fewer segments are there
          grDevices::dev.set(f1)
          plot_prh_fig1(P, sampling_rate, PRH, xl)
          # then quit interaction with fig 2
          # because cannot execute above code more than once without causing trouble
          fig2_status <- "Done"
          break
        }

        if (fig2_status %in% c("1", "2")) {
          ss <- as.numeric(fig2_status) # convert '1', '2', ... to numeric 1, 2...
          # get new x location
          grDevices::dev.set(f2)
          grDevices::setGraphicsEventHandlers(
            which = f1,
            prompt = "WINDOW INACTIVE - DO NOT CLICK"
          )
          grDevices::setGraphicsEventHandlers(
            which = f2,
            prompt = "Click the new box edge location",
            onMouseDown = get_clicked_pt
          )
          new_edge <- grDevices::getGraphicsEvent()

          # nx is new box side x-value
          nx <- max(min(new_edge$x, nrow(A) / sampling_rate), 0)
          seg[ss] <- nx
          S[ke, ] <- seg
          prh <- applymethod2(A, v, sampling_rate, seg)
          PRH[ke, ] <- c(mean(seg[1:2]), prh)
          grDevices::dev.set(f1)
          plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)
          grDevices::dev.set(f2)
          plot_prh_fig2_m2(A, v, sampling_rate, seg, prh, main_f2_prompt)
          fig2_status <- "just adjusted box"
        } # end of "adjust boxes"
      } # end of "while fig2 not done"
      grDevices::setGraphicsEventHandlers(
        which = f2,
        prompt = "WINDOW INACTIVE - DO NOT CLICK"
      )
    } else { # end of "if edit"
      grDevices::dev.set(f1)
      grDevices::setGraphicsEventHandlers(
        which = f1,
        prompt = main_f1_prompt,
        onMouseDown = mousedown1,
        onKeybd = keybd1
      )
      fig1_status <- grDevices::getGraphicsEvent()
    }
  } # end of "while fig 1 not done"
  # this will finish when user clicks Q or q, or the figure is closed.
  return(PRH)
} # end of prh_predictor1 function