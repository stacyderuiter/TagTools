function    [S,fn,id] = d3makettab_x(recdir,prefix,suffix)
%
%    [S,fn,id] = d3makettab(recdir,prefix,suffix)
%     Accumulate a timing table from the t-suffix
%     timing files associated with a D3 wav output stream.
%

S = [] ;
[fn,id,recn,recdir] = getrecfnames(recdir,prefix,1) ;
if isempty(fn),
   return
end
k2 = 0;
fn2 = [];
for k=1:length(fn),
   fname = [recdir,fn{k},'.',suffix,'t'] ;
   sfname = [fn{k},'.',suffix]; %file name with suffix, without path=recdir, for later reference by getcues/wavread
   if ~exist(fname,'file'), continue, end
   k2 = k2+1; 
   fn2{k2} = sfname;
   s = str2double(csvproc(fname,[],[],1)) ;
   S(end+(1:size(s,1)),:) = [k2*ones(size(s,1),1) s] ;
   fname = [recdir,fn{k},'.',suffix,'xt'] ; %the following lines check if there is an overflow wavxt file and add it to the cuetab if so...
   sfname = [fn{k},'.',suffix,'x']; %file name with suffix, without path=recdir, for later reference by getcues/wavread
   if ~exist(fname,'file'), continue, end %if no wavxt exists, skip to next file name
   k2 = k2+1; 
   fn2{k2} = sfname;
   s = str2double(csvproc(fname,[],[],1)) ; %read in/convert data format
   S(end+(1:size(s,1)),:) = [k2*ones(size(s,1),1) s] ; %add in a line to the timing table for the wavx file
end

id = id(1) ;
fn = fn2   ;
