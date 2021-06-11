#' Edits a html file from given csv.
#'
#' Takes data from csv, and edits a default or given html to fill in data from the csv. HTML must be tagmetadata.html or variations, csv should only contain metadata of tag.
#' @param masterHTML default masterHTML is located in the package, or can be changed according to user input.
#' @param csvfilename file name of csv to be used for editing the HTML
#' @return A "dynamic tagmetadata.html" which is the masterHTML with changes from csv. This file is written to the current working directory, and also opened for editing by the user.
#' @export

metadata_editor <- function(masterHTML = system.file("extdata", "tagmetadata.html", package = "tagtools"),
                            csvfilename = system.file("extdata", "blank_template.csv", package = "tagtools")) {
  csvFile <- parseCSV(csvfilename)
  htmlFile <- scan(file = masterHTML, what = character(0), sep = "\n", quote = "")
  newHTML <- htmlFile
  csvFile2 <- suppressMessages(readr::read_csv(csvfilename))
  param2 <- csvFile2$params
  req2 <- csvFile2$required
  field2 <- csvFile2$field
  field_arr_str <- ""
  for (p in 1:length(field2)) {
    if (p == 1) {
      field_arr_str <- paste(field_arr_str, "[", '"', field2[p], '"', sep = "")
    }
    else {
      if (p != length(field2)) {
        field_arr_str <- paste(field_arr_str, " ", ",", '"', field2[p], '"', sep = "")
      }
      else {
        field_arr_str <- paste(field_arr_str, ",", " ", '"', field2[p], '"', "]", sep = "")
      }
    }
  }
  field_arr_index <- grep("csv_fields = ", htmlFile)
  field_arr_line <- unlist(strsplit(htmlFile[field_arr_index], "="))
  newHTML[field_arr_index] <- paste(field_arr_line[1], " = ", field_arr_str, sep = "")
  req_arr_str <- ""
  for (p in 1:length(req2)) {
    if (p == 1) {
      req_arr_str <- paste(req_arr_str, "[", '"', req2[p], '"', sep = "")
    }
    else {
      if (p != length(req2)) {
        req_arr_str <- paste(req_arr_str, " ", ",", '"', req2[p], '"', sep = "")
      }
      else {
        req_arr_str <- paste(req_arr_str, ",", " ", '"', req2[p], '"', "]", sep = "")
      }
    }
  }
  req_arr_index <- grep("req_field = ", htmlFile)
  req_arr_line <- unlist(strsplit(htmlFile[req_arr_index], "="))
  newHTML[req_arr_index] <- paste(req_arr_line[1], " = ", req_arr_str, sep = "")
  param_arr_str <- ""
  for (p in 1:length(param2)) {
    if (p == 1) {
      param_arr_str <- paste(param_arr_str, "[", '"', param2[p], '"', sep = "")
    } else {
      check_comm <- grep(",", param2[p])
      if (p != length(param2)) {
        if (length(check_comm) != 0) {
          param_arr_str <- paste(param_arr_str, " ", ",", "'", '"', param2[p], '"', "'", sep = "")
        } else {
          param_arr_str <- paste(param_arr_str, " ", ",", '"', param2[p], '"', sep = "")
        }
      } else {
        if (length(check_comm) != 0) {
          param_arr_str <- paste(param_arr_str, ",", " ", "'", '"', param2[p], '"', "'", "]", sep = "")
        } else {
          param_arr_str <- paste(param_arr_str, ",", " ", '"', param2[p], '"', "]", sep = "")
        }
      }
    }
  }
  param_arr_index <- grep("other_field = ", htmlFile)
  param_arr_line <- unlist(strsplit(htmlFile[param_arr_index], "="))
  newHTML[param_arr_index] <- paste(param_arr_line[1], " = ", param_arr_str, sep = "")
  id <- csvFile$id
  field <- csvFile$field
  html_indices <- list()
  indices <- c()
  for (i in 1:length(id)) {
    findstring <- paste("id=", "\"", id[i], "\"", sep = "")
    index <- grep(findstring, htmlFile)
    if (length(index) != 0) {
      html_indices[[i]] <- index
      indices <- c(indices, i)
    }
  }

  for (n in 1:length(indices)) {
    if (identical(id[indices[n]], "dephist.device.regset")) {
      next
    }

    if (identical(id[indices[n]], "udm.export")) {
      old_html <- unlist(strsplit(htmlFile[html_indices[[indices[n]]]], '" />'))
      old_html_end <- old_html[2]
      if (field[indices[n]] == "1") {
        old_html[2] <- "\" checked />"
      } else {
        old_html[2] <- "\" />"
      }
      old_html[3] <- old_html_end
      newHTML[html_indices[[indices[n]]]] <- paste(old_html[1], old_html[2], old_html[3], sep = "")
    }

    if (!identical(id[indices[n]], "dephist.device.tzone")) {
      old_html <- unlist(strsplit(htmlFile[html_indices[[indices[n]]]], 'value = \"\"'))
      if (length(old_html) != 1) {
        old_html_end <- old_html[2]
        old_html[2] <- paste("value=", "\"", field[indices[n]], "\"", " ", sep = "")
        old_html[3] <- old_html_end
        newHTML[html_indices[[indices[n]]]] <- paste(old_html[1], old_html[2], old_html[3])
      }
    }

    if (identical(id[indices[n]], "dephist.device.tzone")) {
      f_str <- paste("value=", "\"", field[indices[n]], "\"", sep = "")
      tzone_indices <- grep(f_str, htmlFile)
      if (length(tzone_indices) != 0) {
        old_html <- unlist(strsplit(htmlFile[tzone_indices[1]], '">'))
        old_html_end <- old_html[2]
        old_html[2] <- paste("\"", "selected >", sep = "")
        old_html[3] <- old_html_end
        newHTML[tzone_indices[1]] <- paste(old_html[1], old_html[2], old_html[3])
      }
    }
  }
  fileConn <- file("dynamic_tagmetadata.html")
  writeLines(newHTML, fileConn)
  close(fileConn)

  openHTML("dynamic_tagmetadata.html")
}


parseCSV <- function(csvfilename) {
  ret_frame <- readr::read_csv(csvfilename)
  deploy_date_index <- grep("dephist.deploy.datetime.start", ret_frame$field)
  deploy_date_id0 <- paste(ret_frame[deploy_date_index, 1], "0", sep = "")
  deploy_date_id1 <- paste(ret_frame[deploy_date_index, 1], "1", sep = "")
  deploy_date_vector <- unlist(strsplit(as.character(ret_frame[deploy_date_index, 3]), " "))
  deploy_date_field0 <- deploy_date_vector[1]
  deploy_date_field1 <- deploy_date_vector[2]
  deploy_date_row0 <- c(deploy_date_id0, "1", deploy_date_field0)
  deploy_date_row1 <- c(deploy_date_id1, "1", deploy_date_field1)
  ret_frame <- ret_frame[-deploy_date_index, ]
  ret_frame <- rbind(ret_frame[1:(deploy_date_index - 1), ], deploy_date_row0, ret_frame[-(1:(deploy_date_index - 1)), ])
  ret_frame <- rbind(ret_frame[1:deploy_date_index, ], deploy_date_row1, ret_frame[-(1:deploy_date_index), ])

  device_date_index <- grep("dephist.device.datetime.start", ret_frame$field)
  device_date_id0 <- paste(ret_frame[device_date_index, 1], "0", sep = "")
  device_date_id1 <- paste(ret_frame[device_date_index, 1], "1", sep = "")
  device_date_vector <- unlist(strsplit(as.character(ret_frame[device_date_index, 3]), " "))
  device_date_field0 <- device_date_vector[1]
  device_date_field1 <- device_date_vector[2]
  device_date_row0 <- c(device_date_id0, "1", device_date_field0)
  device_date_row1 <- c(device_date_id1, "1", device_date_field1)
  ret_frame <- ret_frame[-device_date_index, ]
  ret_frame <- rbind(ret_frame[1:(device_date_index - 1), ], device_date_row0, ret_frame[-(1:(device_date_index - 1)), ])
  ret_frame <- rbind(ret_frame[1:device_date_index, ], device_date_row1, ret_frame[-(1:device_date_index), ])



  return(list(id = ret_frame$field, req = ret_frame$required, field = ret_frame$params))
}

openHTML <- function(x) utils::browseURL(paste0("file://", file.path(getwd(), x)))
