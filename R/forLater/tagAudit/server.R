
library(shiny)

#check out: htmlwidgets -- access js graphs from within R
# - for animations: rglwidget?
# - for rbokeh and dygraphs?

shinyServer(function(input, output, session) {
  # adjust start time of plot as needed depending on
  # forward and back buttons
  observeEvent(input$forward, {
    new_start <- input$st + input$dur
    updateSliderInput(session, "st",  val=new_start)
  })
  
  observeEvent(input$back, {
    new_start <- input$st - input$dur
    updateSliderInput(session, "st",  val=new_start)
  })
  
  # draw plot
  output$data_plot <- renderPlot({
    panel_plot(data=dat, time=dat$time, variables=c('p', 'Ax'), 
               panel_size=c(2,1), 
               xlim=c(input$st,input$st+input$dur),
               panel_labels=c('Depth (m)', 
                              'Acceleration\n(x, m/sec/sec)'))
  })
})
