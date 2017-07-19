rotate <- function(event_times, full_period){
  rot_event_times <- event_times + runif(1)*max(full_period)
  rot_event_times <- sort(ifelse(rot_event_times > max(full_period),
                            rot_event_times - max(full_period),
                            rot_event_times))
  return(rot_event_times)
}

