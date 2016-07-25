function    BCL = buzzclickcontext(BCL,CL,intervl)
%
%    BCL = buzzclickcontext(BCL,CL,intervl)
%

tstart = min(BCL(:,1)) ;
tend = max(BCL(:,1)) ;
minsp = 2e-3 ;
kpre = find(CL>tstart+intervl(1) & CL<tstart-minsp) ;
kpost = find(CL<tend+intervl(2) & CL>tend-minsp) ;
BCL = sort([CL(kpre,1);BCL(:,1);CL(kpost,1)]) ;
