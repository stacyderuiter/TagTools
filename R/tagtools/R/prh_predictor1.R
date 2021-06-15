#' Predict the tag position on a diving animal from depth and acceleration data
#'
#' Predict the tag position on a diving animal parameterized by p0, r0, and
#' h0, the canonical angles between the principal axes of the tag and the animal.
#' The tag orientation on the animal can change with time and this function
#' provides a way to estimate the orientation at the start and end of each suitable
#' dive. The function critically assumes that the animal rests horizontally at the
#' surface (at least on average) and dives steeply away from the surface without an
#' initial roll. If ascents are processed, there must also be no roll in the last
#' seconds of the ascents. See prh_predictor2 for a method more suitable to animals
#' that make short dives between respirations.
#' The function provides a graphical interface showing the estimated tag-to-animal
#' orientation throughout the deployment. Follow the directions above the top panel
#' of the figure to edit or delete an orientation estimate.
#'
#' @param P is a dive depth vector or sensor structure with units of m H2O.
#' @param A is an acceleration matrix or sensor structure with columns ax, ay, and az. Acceleration can be in any consistent unit, e.g., g or m/s^2, and must have the same sampling rate as P.
#' @param sampling_rate is the sampling rate of the sensor data in Hz (samples per second). This is only needed if neither A nor M are sensor structures.
#' @param TH is an optional minimum dive depth threshold (default is 100m). Only the descents at the start of dives deeper than TH will be analysed (and the ascents at the end of dives deeper than TH if ALL is true).
#' @param DIR is an optional dive direction constraint. The default (DIR = 'descent') is to only analyse descents as these tend to give better results. But if DIR = 'both', both descents and ascents are analysed.
#' @return PRH, a data frame with columns \code{cue} \code{p0}, \code{r0}, \code{h0}, and \code{q}
#' with a row for each dive edge analysed. \code{cue} is the time in second-since-tag-start of the dive edge analysed.
#' \code{p0}, \code{r0}, and \code{h0} are the deduced tag orientation angles in radians.
#' \code{q} is the quality indicator with a low value (near 0, e.g., <0.05) indicating that the data fit more consistently with the assumptions of the method.
#' @seealso \link{prh_predictor2}, \link{tag2animal}
#' @export

prh_predictor1 <- function(P, A, sampling_rate = NULL, TH = 100, DIR = "descent") {
  #**************************************************
  # set defaults and constants
  #**************************************************
  SURFLEN <- 30 # target surface segment length in seconds
  DIVELEN <- 15 # target dive segment length in seconds
  GAP <- 4 # keep at least 4s away from a dive edge
  PRH <- NULL

  #**************************************************
  # input checking
  #**************************************************
  if (missing(P) | missing(A)) {
    stop("prh_predictor1 requires inputs P (depth data) and A (acceleration data).\n")
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
      stop("For prh_predictor1(), sampling_rate must be specified if A and P are matrices.")
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

  #**************************************************
  # dive detection
  #**************************************************
  # find dive start/ends
  T <- tagtools::find_dives(p = P, sampling_rate = sampling_rate, mindepth = TH)
  if (nrow(T) == 0) {
    stop(sprintf(" No dives deeper than %4.0f found\n", TH))
  }
  # augment all dive-end times by GAP seconds
  T$end <- T$end + GAP

  # make descent analysis segments
  S <- matrix(T$start, nrow = nrow(T), ncol = 4) +
    matrix(c(-SURFLEN - GAP, -GAP, GAP, GAP + DIVELEN),
      nrow = nrow(T),
      ncol = 4,
      byrow = TRUE
    )
  S <- cbind(S, -1) # descent indicator

  # make ascent segments
  if (DIR == "both") {
    SS <- matrix(T$end, nrow = nrow(T), ncol = 4) +
      matrix(c(GAP, SURFLEN + GAP, -GAP - DIVELEN, -GAP),
        nrow = nrow(T),
        ncol = 4,
        byrow = TRUE
      )
    SS <- cbind(SS, 1) # add ascent indicator
    S <- rbind(S, SS) # combine S and SS (ascents and descents)
    # sort S by dive start time
    S <- S[order(S[, 1]), ]
  }

  #**************************************************
  # PRH inference
  #**************************************************

  PRH <- matrix(nrow = nrow(S), ncol = 5)

  for (k in c(1:nrow(S))) { # apply prh inference method on segments
    prh <- applymethod1(A, sampling_rate, S[k, ])
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
  main_f2_prompt <- "type 1, 2, 3 or 4 to adjust boxes, x to erase PRH point, or q to return"

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
      plot_prh_fig2(A, sampling_rate, seg, prh, main_f2_prompt)

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

        if (fig2_status %in% c("1", "2", "3", "4")) {
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
          if (seg[5] < 0) { # if this is a descent, the index is correct
            seg[ss] <- nx
          } else { # if it's an ascent, swap 3,4 with 1,2
            seg[(ss + 1 %% 4) + 1] <- nx
          }
          S[ke, ] <- seg
          prh <- applymethod1(A, sampling_rate, seg)
          PRH[ke, ] <- c(mean(seg[1:2]), prh)
          grDevices::dev.set(f1)
          plot_prh_fig1(P, sampling_rate, PRH, xl, main_f1_prompt)
          grDevices::dev.set(f2)
          plot_prh_fig2(A, sampling_rate, seg, prh, main_f2_prompt)
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