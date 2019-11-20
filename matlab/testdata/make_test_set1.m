dataset = 'testset1' ;
load(dataset)
info=csv2struct(dataset);
A=sens_struct(A*9.81,fs,info.depid,'acc');
A.frame = 'animal' ;
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'animal' ;
P=sens_struct(p,fs,info.depid,'pr');
save_nc(dataset,A,M,P,info) ;
