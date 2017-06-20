fir_nodelay <- function(x,n,fp,qual) {
  n = floor(n/2)*2
  if (nargs() == 4) {
    h = signal::fir1(n,fp,qual)
  } else {
    h = signal::fir1(n,fp)
  }
  if (is.vector(x)) {
    x <- as.matrix(x)
  }
  noffs = floor(n/2)
  y <- signal::filter(h,1,x=rbind((x[seq(noffs, 2, -1), ]), x, x[nrow(x) + seq(-1, -noffs, -1), ]))
  y <- matrix(y, byrow = FALSE, ncol=3)
  y <- y[n - 1 + c(1:nrow(x)), ]
  return(y)
}
