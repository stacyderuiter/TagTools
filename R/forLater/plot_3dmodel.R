plot_3dmodel <- function(fname = NULL){

  
  
  if (is.null(fname)){
    fname <- 'dolphin' 
  }
  
  SZ <- 5 			# size of the gimbal
  CSZ <- 1.07 	# multiplier for size of the compass wheel
  PLOT_RINGS <- 0 
  
  # load wire frame
  #warning off
  P <- load(paste(fname, 'pts.csv', sep = ''))
  K <- load(paste(fname, 'knx.csv', sep = ''))
  #warning on
  #clf
  
  # convert from
  P = cbind(-P[,1],P[,2:3])
  p = patch('faces',K[,1:3]+1, 'vertices',cbind(P[,1], -P[,2], P[,3]))
  set(p, 'facealpha',1)
  colormap(flipud(bone))
  brighten(-0.3)
  set(p, 'FaceVertexCData',P[,3])
  set(p, 'FaceColor', 'flat')
  #shading flat
  #axis square
  #hold on
  
  c <- exp(j*2*pi*t((0:500-1))/500)
  CX <- SZ*cbind(real(c), imag(c), matrix(0,nrow = 500,ncol = 1))
  
  if(PLOT_RINGS){
    C(1) <- cloud(CX[,3]~CX[,1]*-CX[,2],'k');
    C(2) <- cloud(CX[,2]~CX[,3]*-CX[,1],'k');
    C(3) <- cloud(CX[,1]~CX[,2]*-CX[,3],'k');
    set(C,'color',0.6*c(1, 1, 1))
  }
  else{
    C <-  numeric()
  }
  
  COMP <- cloud (CX[,3]~(CSZ*CX[,1])*(CSZ*CX[,2]),'k')
  CTICK <- cloud(matrix(0,nrow = 2,ncol = 4)~(CSZ*SZ*matrix(c(1,0, -1, 0,CSZ, 0, -CSZ, 0), nrow = 2, ncol = 4))*(CSZ*SZ*matrix(c(0, 1, 0, -1,0, CSZ, 0, -CSZ), nrow = 2, ncol = 4)),'k') ;
  set(COMP,'LineWidth',1)
  set(CTICK,'LineWidth',1)
  text(CSZ^3*SZ,0,0,'N','Color','k')
  LX = SZ*matrix(c(-1, 0, 0,1, 0, 0), nrow = 2, ncol = 3) 
  L[1]=cloud(LX[,3]~LX[,1]*-LX[,2],'b')
  L[2]=cloud(LX[,2]~LX[,3]*-LX[,1],'g');
  L[3]=cloud(LX[,1]~LX[,2]*-LX[,3],'r');
  set(L,'LineWidth',1.5)
  AX = SZ*c(1,0,0) ;
  A[1]=cloud(LX[2,3]~LX[2,1]*-LX[2,2],'b.')
  A[2]=cloud(LX[2,2]~LX[2,3]*-LX[2,1],'g.')
  A[3]=cloud(LX[2,1]~LX[2,2]*-L[2,3],'r.')
  set(A,'MarkerSize',14);
  axis(c(-1, 1, -1, 1, -1, 1)*SZ*sqrt(2))
  #view(c(30,20)
  #axis off
  F <- data.frame(p = p, P = P, LX = LX, L = L, CX = CX, C = C, A = A)
  return(F)
}
        