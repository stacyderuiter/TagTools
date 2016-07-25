function    [SL,f] = wavsetSL_sd(fnames,dir,nfft,len, hpfilt_kHz)
%
%    [SL,f] = wavsetSL(fnames,dir,nfft,len)
%     Example:
%     ff=dir('e:/*.wav')
%     [SL,f] = wavsetSL({ff.name},'e:',1024,5);
%

SL = {} ;
if ~isempty(dir) & ~ismember(dir(end),'/\'),
   dir = [dir,'\'] ;
end

for k=1:length(fnames),
     fprintf('Processing file %d\n', k) ;
   fname = [dir,fnames{k}] ;
   [SL{k},f]=wavSL_sd(fname,[],nfft,len, hpfilt_kHz);
end
