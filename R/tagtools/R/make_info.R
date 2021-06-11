#' Make an info structure with tag metadata
#'
#' This function allows the user to generate a "skeleton" info structure for a tag deployment, with some common pieces of metadata filled in. Additional information can then be added manually or using a custom script before saving this \code{info} as part of a netCDF file.
#' @param depid Deployment id string for this tag record
#' @param tagtype String identifying the tag type, for example 'dtag', 'cats', 'mk10', ...
#' @param species (optional) 2-letter string with the first letters of the species binomial
#' @param owner (optional) String with initials of the tag data owner
#' @return A list containing metadata for a tag deployment. It's recommended to name this output "info" and save it as part of a netCDF tag data archive file (along with the tag sensor data).
#' @export
#' @examples \dontrun{
#' info <- make_info("zc19_365a", "dtag", "zc", "sdr")
#' }
make_info <- function(depid, tagtype, species, owner) {
  if (missing(tagtype)) {
    stop("Required inputs tagtype for make_info is missing. You may want to edit the research and/or species .csv files, stored in the inst folder with the tagtools R package.")
  }

  if (missing(species) | missing(owner)) {
    warning("make_info: Helpful inputs species and owner are missing. You may want to edit the research and/or species .csv files, stored in the inst folder with the tagtools R package.")
  }

  tagtype <- tolower(tagtype)
  ttypes <- c("dtag", "cats", "lleo", "mk10")

  if (grepl(tagtype, "dtag")) {
    n <- readline(prompt = "Enter dtag version (2, 3, 4,...): ")
    tagtype <- ifelse(n %in% c("2", "3", "4"), paste(tagtype, n, sep = ""), tagtype)
    if (tagtype == "dtag") {
      stop("Invalid dtag version specified - versions 2, 3, and 4 recognized.")
    }
  }

  template_file <- dplyr::case_when(
    tagtype == "dtag2" ~ "d2_template.csv",
    tagtype == "dtag3" ~ "d3_template.csv",
    tagtype == "dtag4" ~ "d4_template.csv",
    tagtype %in% c("sm", "smrt") ~ "sm_template.csv",
    tagtype == "cats" ~ "cats_template.csv",
    tagtype %in% c("ll", "leo", "lleo") ~ "ll_template.csv",
    tagtype == "mk10" ~ "mk10_template.csv",
    TRUE ~ "blank_template.csv"
  )
  if (template_file == "blank_template.csv") {
    warning("Unknown tag type - fill out device-related metadata by hand.\n")
  }
  T <- csv2struct(system.file("extdata", template_file, package = "tagtools"))

  T$depid <- depid
  T$dtype_datetime_made <- format(Sys.time(), tz = "UTC")
  T$dtype_nfiles <- "UNKNOWN"
  T$dtype_source <- "UNKNOWN"
  T$device_serial <- "UNKNOWN"
  T$dephist_deploy_datetime_start <- "UNKNOWN"
  T$dephist_device_datetime_start <- "UNKNOWN"

  # need to add something like this when dtag I/O tools ready:

  if (!missing(species)) {
    S <- get_species(species)
    if (length(S) > 0) {
      T$animal_species_common <- S$Common_name
      T$animal_species_science <- S$Binomial
      T$animal_dbase_url <- S$URL
      if ("ITIS" %in% names(S)) {
        T$animal_dbase_itis <- S$ITIS
      }
    }
  }

  if (!missing(owner)) {
    rm(S)
    S <- get_researcher(owner)
    if (length(S) > 0) {
      T$provider_name <- S$Name
      T$provider_details <- S$Details
      T$provider_email <- S$Email
      T$provider_license <- S$License
      T$provider_cite <- S$Cite
      T$provider_doi <- S$DOI
    }
  }
  info <- T[order(names(T))]
} # end of make_info
