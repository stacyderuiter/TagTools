% example script for generating a testset NetCDF file

dataset = 'testset2' ;     % change to the whichever testset is required
load(dataset)
info=csv2struct(dataset);
A=sens_struct(A,fs,info.depid,'acc');
A.frame = 'animal' ;
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'animal' ;
P=sens_struct(p,fs,info.depid,'pr');
if exist('POS','var'),
   POS=sens_struct(POS,T-184588,info.depid,'pos');
   save_nc(dataset,A,M,P,POS,info) ;
else
   save_nc(dataset,A,M,P,info) ;
end
