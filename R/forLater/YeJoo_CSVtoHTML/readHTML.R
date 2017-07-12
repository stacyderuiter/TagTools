readHTML <- function(masterHTML, csvfilename){
 
  csvFile <- parseCSV(csvfileinput)
  htmlFile <- scan(file = masterHTML, what = character(0), sep = "\n", quote = "")
  id <- csvFile$id
  field <- csvFile$field
  html_indices <- list()
  indices <- c()
  for (i in 1:length(id)){
    findstring <- paste("id=", "\"",id[i], "\"", sep = '')
    index <- grep(findstring, htmlFile)
    if (length(index) != 0){
      html_indices[[i]] <- index
      indices <- c(indices, i)
    }
  }
  newHTML <- htmlFile
  for (n in 1:length(indices)){
    if (identical(id[indices[n]], "info.dephist.device.regset")){
      next
    }
    
    if (identical(id[indices[n]], "info.udm.export")){
      old_html <- unlist(strsplit(htmlFile[html_indices[[indices[n]]]], '" />'))
      old_html_end <- old_html[2]
      if(field[indices[n]] == "1"){
        old_html[2] <- "\" checked />"
      }
      else{
        old_html[2] <- "\" />"
      }
      old_html[3] <- old_html_end
      newHTML[html_indices[[indices[n]]]] <- paste(old_html[1],old_html[2],old_html[3])
    }
    
    if (!identical(id[indices[n]], "info.dephist.device.tzone")){
      old_html <- unlist(strsplit(htmlFile[html_indices[[indices[n]]]],'value = \"\"'))
      if (length(unlist(strsplit(htmlFile[html_indices[[indices[n]]]],'value = \"\"'))) != 1){
        old_html_end <- old_html[2]
        old_html[2] <- paste("value=", "\"", field[indices[n]], "\"", ' ', sep = '')
        old_html[3] <- old_html_end
        newHTML[html_indices[[indices[n]]]] <- paste(old_html[1],old_html[2],old_html[3])
      }
    } 
  
    if (identical(id[indices[n]], "info.dephist.device.tzone")){
      f_str = paste("value=", "\"",field[indices[n]],"\"", sep = '')
      tzone_indices <- grep(f_str, htmlFile)
      if(length(tzone_indices) != 0){
        old_html <- unlist(strsplit( htmlFile[tzone_indices[1]],'">'))
        old_html_end <- old_html[2]
        old_html[2] <- paste("\"", "selected >", sep = '')
        old_html[3] <- old_html_end
        newHTML[tzone_indices[1]] <- paste(old_html[1],old_html[2],old_html[3])
      }
    }
  }
  # Write cell A into txt
  fileConn<-file("dynamic_tagmetadata.html")
  writeLines(newHTML, fileConn)
  close(fileConn)
}


parseCSV<-function(csvfilename){
  a1 <- readr::read_csv(csvfilename)
  
  local_index <- grep("info.dephist.deploy.locality", a1$field)
  local_id0 <- paste(a1[local_index, 1],'0', sep = '')
  local_id1 <- paste(a1[local_index,1],'1', sep = '')
  local_char_vector <- unlist(strsplit(as.character(a1[local_index, 3]), "[,]"))
  local_field0 <- substring(local_char_vector[1],3)
  local_field1 <- substring(local_char_vector[2],2)
  local_field1 <- substring(local_field1,1, nchar(local_field1)-2)
  local_row0 <- c(local_id0, '1', local_field0)
  local_row1 <- c(local_id1, '1', local_field1)
  a1 <- a1[-local_index,]
  a1 <- rbind(a1[1:(local_index-1),],local_row0, a1[-(1:(local_index-1)),])
  a1 <- rbind(a1[1:local_index,],local_row1, a1[-(1:local_index),])
  deploy_date_index <- grep("info.dephist.deploy.datetime.start", a1$field)
  deploy_date_id0 <- paste(a1[deploy_date_index, 1],'0', sep = '')
  deploy_date_id1 <- paste(a1[deploy_date_index, 1],'1', sep = '')
  deploy_date_vector <- unlist(strsplit(as.character(a1[deploy_date_index, 3]), " "))
  deploy_date_field0 <- deploy_date_vector[1]
  deploy_date_field1 <- deploy_date_vector[2]
  deploy_date_row0 <- c(deploy_date_id0, '1', deploy_date_field0)
  deploy_date_row1 <- c(deploy_date_id1, '1', deploy_date_field1)
  a1 <- a1[-deploy_date_index,]
  a1 <- rbind(a1[1:(deploy_date_index-1),],deploy_date_row0, a1[-(1:(deploy_date_index-1)),])
  a1 <- rbind(a1[1:deploy_date_index,],deploy_date_row1, a1[-(1:deploy_date_index),])
  
  device_date_index <- grep("info.dephist.device.datetime.start", a1$field)
  device_date_id0 <- paste(a1[device_date_index, 1],'0', sep = '')
  device_date_id1 <- paste(a1[device_date_index, 1],'1', sep = '')
  device_date_vector <- unlist(strsplit(as.character(a2[device_date_index, 3]), " "))
  device_date_field0 <- device_date_vector[1]
  device_date_field1 <- device_date_vector[2]
  device_date_row0 <- c(device_date_id0, '1', device_date_field0)
  device_date_row1 <- c(device_date_id1, '1', device_date_field1)
  a1 <- a1[-device_date_index,]
  a1 <- rbind(a1[1:(device_date_index-1),],device_date_row0, a1[-(1:(device_date_index-1)),])
  a1 <- rbind(a1[1:device_date_index,],device_date_row1, a1[-(1:device_date_index),])
  
  return(list(id=a1$field, field=a1$params))
} 

