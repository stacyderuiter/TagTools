fir_no_delay <- function(x,n,fp,qual) {
  n = floor(n/2)*2
  if (nargs() == 4) {
    h = signal::fir1(n,fp,qual)
  } else {
    h = signal::fir1(n,fp)
  }
  isavector <- FALSE
  if (is.vector(x)) {
    x <- as.matrix(x)
    isavector <- TRUE
  }
  noffs = floor(n/2)
  if(isavector){
    y <- signal::filter(h,1,x=rbind((x[seq(noffs, 2, -1) ]), x, rev(x[seq(from = -noffs, by = 1,to= 0)][1:(length(x)-noffs-1)]))) 
  }
  else{
    
    y <- signal::filter(h,1,x=rbind((x[seq(noffs, 2, -1), ]), x, x[nrow(x) + seq(-1, -noffs, -1), ]))
  }
  #y <- signal::filter(h,1,x=rbind((x[seq(noffs, 2, -1), ]), x, x[nrow(x) + seq(-1, -noffs, -1), ]))
  y <- matrix(y, byrow = FALSE, ncol=3)
  #if(isavector){
  # y <- y[n - 1 + c(1:nrow(x)) ]
  #}
  #else{
  #  y <- y[n - 1 + c(1:nrow(x)), ]
  #}
  y <- y[n - 1 + c(1:nrow(x)), ]
  
  return(list(y=y,h=h))
}