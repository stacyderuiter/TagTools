## ---- include = FALSE----------------------------------------------------
#source('~/TagTools/R/tagtools/R/plott.R')
#source('~/TagTools/R/tagtools/R/njerk.R')
#source('~/TagTools/R/tagtools/R/detect_peaks.R')
#source('~/TagTools/R/tagtools/R/draw_axis.R')

## ---- results = "hide", message=FALSE------------------------------------
library(readr)
 #read_csv("~/DeRuiter2017/Datasets/bw11_210a_tagdata.csv")
bw11_210a_tagdata <- readr::read_csv('http://www.calvin.edu/~sld33/data/bw11_210a_tagdata.csv')
Aw <- cbind(bw11_210a_tagdata$Awx, bw11_210a_tagdata$Awy, bw11_210a_tagdata$Awz)
sampling_rate <- bw11_210a_tagdata$fs[1]  

## ---- fig.width=7, fig.height=5------------------------------------------
library(tagtools)
jerk <- njerk(A = Aw, sampling_rate = sampling_rate)
X <- list(jerk = jerk)
plott(X, 5, line_colors = "blue") 

## ---- results='hide'-----------------------------------------------------
sr <- bw11_210a_tagdata$sampling_rate[1]  
jerk <- jerk[1:60000]

## ---- message = FALSE, eval = FALSE--------------------------------------
#  detect_peaks(data = jerk, sr = sr, FUN = NULL,
#                   thresh = NULL, bktime = NULL, plot_peaks = TRUE)

## ---- include = FALSE----------------------------------------------------
peaks <- detect_peaks(data = Aw[1:60000, ], sr = sr, FUN = njerk, thresh = NULL, bktime = NULL, plot_peaks = TRUE, sampling_rate = sampling_rate)

## ---- echo = FALSE, fig.width=7, fig.height=5----------------------------
X <- list(jerk = jerk)
plott(X, sampling_rate, line_colors = "blue")

## ---- message = FALSE, eval = FALSE--------------------------------------
#  detect_peaks(data = Aw[1:60000, ], sr = sr, FUN = "njerk",
#                  thresh = NULL, bktime = NULL, plot_peaks = TRUE, sampling_rate = sampling_rate)

## ---- eval = FALSE-------------------------------------------------------
#  peaks <- detect_peaks(data = jerk, sr = sr, FUN = NULL,
#                            thresh = 0.874, bktime = 50, plot_peaks = TRUE)

## ---- echo = FALSE, fig.width=7, fig.height=5----------------------------
plott(X, sampling_rate, line_colors = "blue")
str(peaks)

## ------------------------------------------------------------------------
tpevents <- (60000 / sampling_rate) / 35

