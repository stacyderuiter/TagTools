function    [x,fs] = d3wavread(cues,recdir,prefix,suffix)
%
%     [x,fs] = d3wavread(cues,recdir,prefix,suffix)
%     cues = [start_cue end_cue], cues are in seconds with respect
%        to the ref_time associated with the recording (see d3getcues)
%     or
%     cues = [start_cue end_cue ref_time], cues are in seconds
%        with respect to a user-defined ref_time
%

x = [] ; fs = [] ;
if nargin<3,
   help d3wavread
   return
end

if nargin<4 | isempty(suffix),
   suffix = 'wav' ;
end

[ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix) ;

if isempty(ct),
   fprintf(' Unable to make cue file\n') ;
   return
end

% convert cues with a different time reference, if necessary
if length(cues)>2,
   cues = cues(1:2)+(cues(3)-ref_time) ;
end

k = max(find(ct(:,2)<=cues(1))) ;
if isempty(k),
   fprintf(' Cue is before the start of recording\n') ;
   return
end

% find which file the cue comes from and make a cuetable for the file
fnum = ct(k,1) ;
kf = find(ct(:,1)==fnum) ;
csc = [0;cumsum(ct(kf,3))] ;

% convert cue to samples wrt start of file
st = round(fs*(cues(1)-ct(k,2)))+csc(k-kf(1)+1) ;

% compute the number of samples to read
n = round(fs*diff(cues)) ;     

% find out how many samples can be taken from the first file
len = min(n,csc(end)-st) ;
if len<=0, return ; end

% and read those samples
fname = fn{kf} ;
x = wavread16([recdir fname,'.',suffix],st+[1 len]) ;

% see if any samples have to be read from the next file
if len<n,
   if fnum==max(ct(:,1)),
      fprintf(' cue is beyond end of recording - truncating\n') ;
   else
      fname = fn{kf+1} ;
      x = [x;wavread16([recdir fname,'.',suffix],[1 n-len])] ;
   end
end
return
