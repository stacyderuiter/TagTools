function		make_dtag_testset(grp)
%
%		make_dtag_testset(grp)
%

Amap=[0 -1 0;-1 0 0;0 0 1];
Mmap=[0 1 0;1 0 0;0 0 1];
X=d3readswv('F:\group_practical\',sprintf('Group%d_023',grp)) ;
info=csv2struct('dtag_testset');
info.depid = sprintf('hs17_275%c',(grp-1)+'a') ;

A = decdc([X.x{1:3}],4) ;
A = A*Amap ;
fs = X.fs(1)/4;
A=sens_struct(A,fs,info.depid,'acc');
A.frame = 'tag' ;
A.unit = 'raw';
A.unit_label='Raw units';
A.unit_name='Raw units';

M=decdc([X.x{4:6}],2);
M=M*Mmap ;
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'tag' ;
M.unit = 'raw';
M.unit_label='Raw units';
M.unit_name='Raw units';
save_nc([info.depid '_raw'],A,M,info) ;
