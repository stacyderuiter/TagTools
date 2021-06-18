## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval = FALSE------------------------------------------------------------
#  setwd("/path/with/folders/in/it/foo/bar") # you may have to change this

## ---- eval = FALSE------------------------------------------------------------
#  MN <- load_nc('mn12_186a_raw')

## ---- eval = FALSE------------------------------------------------------------
#  names(MN)
#  str(MN$A)
#  # not run because output is very long! see the whole STRucture of MN:
#  # str(MN)
#  # shorter outline version:
#  str(MN, max.level = 1)

## ---- eval = FALSE------------------------------------------------------------
#  plott(X=list(Depth=MN$P, Temperature=MN$T), r=c(TRUE,FALSE))

## ---- eval = FALSE------------------------------------------------------------
#  Pc = crop(MN$P)

## ---- eval = FALSE------------------------------------------------------------
#  Pc$history
#  str(Pc, max.level = 1)

## ---- eval = FALSE------------------------------------------------------------
#  plott(X = list(Pc))
#  

## ---- eval = FALSE------------------------------------------------------------
#  Tc <- crop_to(MN$T,tcues=Pc$crop)$X

## -----------------------------------------------------------------------------
? fix_pressure

## ---- eval = FALSE------------------------------------------------------------
#  Pcmf <-fix_pressure(Pcm,Tc)$p

## ---- eval = FALSE------------------------------------------------------------
#  d <-find_dives(Pcmf,mindepth=5)
#  head(d)

## ---- eval = FALSE------------------------------------------------------------
#  plott(X=list(Pcmf=Pcmf), r=TRUE)
#  points(d$start/(3600*24),rep(0,nrow(d)),col='green', pch=19)
#  points(d$end/(3600*24),rep(0,nrow(d)),col='red', pch=17)

