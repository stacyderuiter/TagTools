function    S = readnmefiles(recdir,prefix)
%
%    S = readnmefiles(recdir,prefix)
%

[fn,dmon,recn,recdir] = getrecfnames(recdir,prefix) ;
S = {} ;
for k=1:length(fn),
   fname = [recdir,fn{k},'.nme'] ;
   if ~exist(fname,'file'), continue, end
   s = csvproc(fname) ;
   [S{end+(1:size(s,1)),1:size(s,2)}] = deal(s{:}) ;
end
