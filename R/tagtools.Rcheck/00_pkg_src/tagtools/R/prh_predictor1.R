#' Predict the tag position on a diving animal from depth and acceleration data
#' 
#' Predict the tag position on a diving animal parameterized by p0, r0, and
#' h0, the cannonical angles between the principal axes of the tag and the animal.
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
#' @export

prh_predictor1 <- function(P, A, sampling_rate = NULL, TH = 100, DIR = 'descent'){
  #**************************************************
  # set defaults and constants
  #**************************************************
  SURFLEN <- 30   # target surface segment length in seconds
  DIVELEN <- 15   # target dive segment length in seconds
  GAP <- 4        # keep at least 4s away from a dive edge
  PRH = NULL
  
  #**************************************************
  # input checking
  #**************************************************
  if (missing(P) | missing(A)){
    stop('prh_predictor1 requires inputs P (depth data) and A (acceleration data).\n')
  }
  
  if (is.list(P) & is.list(A)){
    if(A$sampling_rate != P$sampling_rate){
      stop("A and P must have the sample sampling rate.\n")
    }
  }
  
  #**************************************************
  # prepare data
  #**************************************************
  # extract bare variables from sensor structures
  sampling_rate <- A$sampling_rate
  A <- A$data
  P <- P$data
  
  # decimate data to 5Hz if needed
  if (sampling_rate >= 7.5){
    df <- round(sampling_rate/5)
    P <- tagtools::decdc(P,df) 
    A <- tagtools::decdc(A,df) 
    sampling_rate <- sampling_rate/df 
  }
  
  # normalise A to 1 g
  A <- A * matrix(tagtools::norm2(A)^(-1),nrow = nrow(A),ncol = 3) 
  
  #**************************************************
  # dive detection 
  #**************************************************
  # find dive start/ends
  T = tagtools::find_dives(p = P, sampling_rate = sampling_rate, mindepth = TH)
  if (nrow(T) == 0){
    stop(sprintf(' No dives deeper than %4.0f found\n', TH))
  }
  # augment all dive-end times by GAP seconds
  T$end <- T$end + GAP
  
  # make descent analysis segments
  S <- matrix(T$start, nrow = nrow(T), ncol = 4) +
    matrix(c(-SURFLEN-GAP, -GAP, GAP, GAP+DIVELEN), 
           nrow = nrow(T), 
           ncol = 4, 
           byrow = TRUE)
  S <- cbind(S,-1)		# descent indicator
  
  # make ascent segments
  if (DIR == 'both'){
    SS <- matrix(T$end, nrow = nrow(T), ncol = 4) +
      matrix(c(GAP, SURFLEN + GAP, -GAP-DIVELEN, -GAP),
             nrow = nrow(T),
             ncol = 4,
             byrow = TRUE)
    SS <- cbind(SS, 1)		# add ascent indicator
    S <- rbind(S, SS)  # combine S and SS (ascents and descents)
    # sort S by dive start time
    S <- S[order(S[,1]),]
  }
  
  #**************************************************
  # PRH inference
  #**************************************************
  
  PRH <- matrix(nrow = nrow(S), ncol = 5)
  
  for (k in c(1:nrow(S))){ # apply prh inference method on segments
    prh = tagtools::applymethod1(A, sampling_rate, S[k,])
    if (is.null(prh)){
      next
    }
    PRH[k,] <- matrix(c(mean(S[k,1:2]), prh), nrow = 1)
  }
  
  #**************************************************
  # First figure -- depth, PRH estimate, quality
  # LAUNCH SHINY APP HERE?
  #**************************************************
  
  # make sure there are user options to:
  #  - Quit
  #  - zoom in and out
  #  - show values on plot if hover
  #  - remove this dive/don't use and advance to next
  #  - case "e" (edit by calling up other figure for this point)
  
  # if shiny would it work?
  # click on a point in main plot to choose what is shown in 2nd plot.
  # have button for: delete selected; be able to zoom in/out (plotly?)
  # have tab for results print out
  # in one-dive tab, have zoom in/out; brush to select an area and buttons for "set as window 1" and "set as 2"?
  

  
  
}# end of prh_predictor1 function