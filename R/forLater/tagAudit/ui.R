library(shiny)

# Define UI for application for interactive plotting and annotation of tag data
shinyUI(fluidPage(
  
  # Application title
  titlePanel("tagAudit Test"),
  
  # Sidebar with a slider input for window duration 
  sidebarLayout(
    sidebarPanel(
       sliderInput(inputId="st",
                   label="Start Time:",
                   min = min(dat$time, na.rm=TRUE),
                   max = max(dat$time, na.rm=TRUE),
                   value = min(dat$time, na.rm=TRUE)),
       
       actionButton("backButton", 
                    icon('arrow-left', class = NULL, lib = "font-awesome")),
       actionButton("forwardButton", 
                    icon('arrow-right', class = NULL, lib = "font-awesome")),
       
       sliderInput(inputId="dur",
                   label="Duration (seconds):",
                   min = 5,
                   max = 600,
                   value = 15)
    ),
    
      
    
    # Show a plot of the tag data
    mainPanel(
       plotOutput("dataPlot")
    )
    # to add: animation pane, button to play audio? 
    # Button to play acc as sound?
  )
))
