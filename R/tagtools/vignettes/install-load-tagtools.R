## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  echo = TRUE
)

## ---- eval = FALSE------------------------------------------------------------
#  devtools::install_github('stacyderuiter/TagTools/R/tagtools',
#                           build_vignettes = TRUE)

## ---- eval = FALSE------------------------------------------------------------
#  install.packages('YourPath/YourFilename')

## ---- eval = FALSE------------------------------------------------------------
#  install.packages('/Users/YourUsernameHere/Downloads/FileName.tgz')

## ---- eval = FALSE------------------------------------------------------------
#  dpnds <- c('CircStats', 'ggformula', 'graphics', 'hht',
#             'latex2exp', 'lubridate', 'magrittr',
#             'matlab', 'ncdf4', 'plotly', 'pracma',
#             'readr', 'rgl', 'signal', 'stats',
#             'utils', 'zoo', 'zoom')
#  install.packages(pkgs = dpnds)

## -----------------------------------------------------------------------------
library(tagtools)

## ---- eval = FALSE------------------------------------------------------------
#  ?load_nc

