#make a new variable, GrpChange, that is logical: 1 
# in time points where focal group size changes,
# and also the timepoints before and after such a change.
findchanges <- function(ids, dat){
  #mark times when dat changes with ONEs
  #unless it's a change from one ID to the next
  ch0 <- unlist(tapply(X=dat, INDEX=ids, 
                       FUN=function(x) c(0,diff(x)) != 0 ))
  #again within ID,
  #mark the timesteps before/after a change
  #with ONEs
  ch <- unlist(tapply(X=ch0, INDEX=ids,
                      FUN=function(x) x + 
                        c(0,head(x,-1)) + 
                        c(tail(x,-1),0)))
  #make sure ch is never > 1
  ch[ch>1] <- 1
  return(ch)
}