% example script for generating a testset NetCDF file

dataset = 'testset4' ;     % change to whichever test set is required
load(dataset)
info=csv2struct(dataset);
A=sens_struct(A*9.8,fs,info.depid,'acc');
A.frame = 'animal' ;
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'animal' ;
P=sens_struct(p,fs,info.depid,'pr');
POS=sens_struct(POS,T,info.depid,'pos');
save_nc(dataset,A,M,P,POS,info) ;
