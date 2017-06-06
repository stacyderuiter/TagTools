
library(shiny)

#check out: htmlwidgets -- access js graphs from within R
# - for animations: rglwidget?
# - for rbokeh and dygraphs?
# - otherwise, with buttons: < and > have a 3rd object they feed into and increment the start time value.


# "server logic" for tag audit
shinyServer(function(input, output) {
  output$dataPlot <- renderPlot({
    # window duration based on input$dur from ui.R
    st <- input$st
    et <- input$st + input$dur #seconds
 
    #observe forward/back buttons
    
       
    #make plot
    panelPlot(data=dat, time=dat$time, variables=c('p', 'Ax'), 
              panelSize=c(2,1), xlim=c(st,et), 
              panelLabels=c('Depth (m)', 'Acceleration\n(x, m/sec/sec)'))
  })
  
})
