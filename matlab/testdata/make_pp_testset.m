function		info=make_pp_testset(recdir,depid)

%
%		make_pp_testset(recdir,depid)
%

X=d3readswv(recdir,depid) ;
info=csv2struct('pp_testset');
info.depid = depid ;
[ct,ref_time,fs,fn] = d3getcues(recdir,depid,'swv');
tt = datenum(d3datevec(ref_time)) ;
info.dephist_deploy_datetime_start=datestr(tt,'yyyy,mm,dd,HH,MM,SS') ;
info.dtype_datetime_made = datestr(now,'yyyy/mm/dd HH:MM:SS') ;

info.dtype_nfiles = length(fn) ;
fnames = fn{1} ;
for k=2:length(fn),
	fnames = [fnames ', ' fn{k}] ;
end
	
info.dtype_source = fnames ;
d3=readd3xml([recdir fn{1} '.xml']);
info.device_serial = d3.DEVID ;

CAL=d4findcal(recdir,depid) ;
A = [X.x{1:3}]*CAL.ACC.MAP ;
A=sens_struct(A,X.fs(1),info.depid,'acc');
A.frame = 'tag' ;
A.unit = 'raw';
A.unit_label='Raw units';
A.unit_name='Raw units';

M=[X.x{4:6}]*CAL.MAG.MAP ;
M=sens_struct(M,X.fs(4),info.depid,'mag');
M.frame = 'tag' ;
M.unit = 'raw';
M.unit_label='Raw units';
M.unit_name='Raw units';

p=polyval(CAL.PRESS.POLY,X.x{8});
P=sens_struct(p,X.fs(8),info.depid,'pres');

save_nc([info.depid '_raw'],A,M,P,info) ;
