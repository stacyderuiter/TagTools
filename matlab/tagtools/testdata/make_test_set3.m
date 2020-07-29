dataset = 'testset3' ;
load(dataset)
info=csv2struct(dataset);
A = A*9.81;
A=sens_struct(A,fs,info.depid,'acc');
A.frame = 'animal' ;
M=M+repmat([10.1 -4.3 5.5],size(M,1),1);
M=sens_struct(M,fs,info.depid,'mag');
M.frame = 'animal' ;
P=sens_struct(p,fs,info.depid,'pr');
if exist('PCA','var'),
	PCA=sens_struct(PCA(:,2),PCA(:,1),info.depid,'PCA');
	PCA.column_names='time,duration';
	PCA.full_name='Prey capture attempt durations';
	PCA.description='Prey capture attempts inferred from buzzes in sound recording';
	PCA.unit='s';
	PCA.unit_name='seconds';
	PCA.unit_label='seconds';
	PCA.segment = [7545,21940] ;
	PCA.segment_unit = 'seconds' ;
	PCA.sound_sampling_rate = 96000 ;
	PCA.sampling_rate_unit = 'Hertz' ;
	PCA.sound_analysis_method = 'spectrogram,listening' ;
   save_nc(dataset,A,M,P,PCA,info) ;
else
   save_nc(dataset,A,M,P,info) ;
end
