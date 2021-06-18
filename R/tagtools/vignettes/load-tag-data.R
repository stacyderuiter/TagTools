## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval=FALSE--------------------------------------------------------------
#  cats_nc_fname <- read_cats(fname = '20160730-091117-Froback-11-part',
#                             depid = 'cats_test')

## ----eval=FALSE---------------------------------------------------------------
#  MN <- load_nc('cats_test_raw')

## ----eval=FALSE---------------------------------------------------------------
#  names(MN)
#  str(MN, max.level = 1)
#  str(MN$A)

## ----eval=FALSE---------------------------------------------------------------
#  MN$info

## ----eval=FALSE---------------------------------------------------------------
#  MN$info$sensors_list

## ----eval=FALSE---------------------------------------------------------------
#  MN$info$data_owner <- 'Jeremy Goldbogen, Dave Cade'

## ----eval=FALSE---------------------------------------------------------------
#  more_info <- make_info(depid = 'cats_test', tagtype = 'CATS',
#                         species = 'mn', owner = 'jg')

## ----eval=FALSE---------------------------------------------------------------
#  system.file('extdata', 'researchers.csv', package='tagtools')

## ----eval=FALSE---------------------------------------------------------------
#  more_info

## ----eval=FALSE---------------------------------------------------------------
#  more_info[names(MN$info)] <- MN$info
#  MN$info <- more_info

## ----eval=FALSE---------------------------------------------------------------
#  metadata_editor()

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  knitr::include_graphics('meta_editor.png')

## ----eval=FALSE---------------------------------------------------------------
#  yet_more_info <- csv2struct('the_file_you_just_saved.csv')

## ----eval=FALSE---------------------------------------------------------------
#  yet_more_info[names(MN$info)] <- MN$info
#  MN$info <- yet_more_info

## ----eval=FALSE---------------------------------------------------------------
#  MN$info[is.na(MN$info)] <- NULL
#  add_nc('cats_test_raw', X = MN$info, vname = 'info')

