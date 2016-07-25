function    [C,fn,id] = d3makectab(recdir,prefix,suffix)
%
%    [C,fn,id] = d3makectab(recdir,prefix,suffix)
%     Accumulate a timing table from the wav files
%     associated with a D3 wav output stream.
%

C = [] ;
[fn,id,recn,recdir] = getrecfnames(recdir,prefix,1) ;
if isempty(fn),
   return
end

for k=1:length(fn),
   fnn = [recdir fn{k}] ;
   fname = [fnn '.' suffix] ;
   if ~exist(fname,'file'), continue, end
   [ss,fs] = wavread16(fname,'size') ;
   [stime dv rtime] = getxmlcue(fnn) ;
   if isempty(rtime), continue, end
   C(end+1,:) = [recn(k) floor(rtime) mod(rtime,1) ss(1)] ;
end

id = id(1) ;
