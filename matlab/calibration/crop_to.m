function		[X,T] = crop_to(X,fs,tcues)

%		Y = crop_to(X,tcues)				% X is a sensor structure
%		or
%		Y = crop_to(X,fs,tcues)			% X is a regularly sampled vector or matrix
%		or
%		[Y,T] = crop_to(X,T,tcues)		% X is an irregularly sampled vector or matrix
%
%		Reduce the time span of data by cropping out any data that falls before and
%		after two time cues.
%
%     Inputs:
%     X is a sensor structure, vector or matrix. X can be regularly or
%		 irregularly sampled data in any frame and unit.
%     fs is the sampling rate of X in Hz. This is only needed if
%		 X is not a sensor structure and X is regularly sampled.
%		T is a vector of sampling times for X. This is only needed if X is
%		 not a sensor structure and X is not regularly sampled.
%		tcues is a two-element vector containing the start and end time cue
%		 in seconds of the data segment to keep, i.e., tcues = [start_time, end_time].
%
%     Results:
%     Y is a sensor structure, vector or matrix containing the cropped data segment.
%		 If the input is a sensor structure, the output will also be. The output has
%		 the same units, frame and sampling characteristics as the input.
%     T is a vector of sampling times for Y. This is only returned if X is irregularly
%	    sampled and X is not a sensor structure. If X is a sensor structure, the sampling
%		 times are stored in the structure.
%
%		Example:
%		 load_nc('testset3');
%		 d = find_dives(P,300) ;
%		 P2 = crop_to(P,[d.start(2) d.end(2)]);	% crop to 2nd dive
%		 plott(P2)
%		 % plot shows the profile of the second dive
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 23 Dec 2018
%     - changed sensor structure field names

T = [] ;
if nargin<2,
	help crop_to
	return
end
	
if isstruct(X),
	[x,fst] = sens2var(X) ;
	if isempty(x), return, end
	tcues = fs ;
	fs = fst ;
else
	if nargin<3,
		help crop_to
		return
	end
	x = X ;
	if size(x,1)==1,		% make sure x is a column vector
		x = x(:) ;
	end
end

if length(tcues)~=2,
	fprintf(' crop_to: tcues must be a two-element vector of [start_time,end_time]\n') ;
	return
end

if tcues(1)>=tcues(2),
	X = [] ;
	return
end
	
if length(fs)>1,		% irregularly sampled data
	k = find(fs>=tcues(1) & fs<=tcues(2)) ;
	T = fs(k)-tcues(1) ;
else
	k = max(round(tcues(1)*fs)+1,1):min(round(tcues(2)*fs)+1,size(x,1)) ;
end

if isempty(k),								% crop excludes all of the input data
	X = [] ; T = [] ;
	return
end

if k(1)<=1 && k(end)>=size(x,1),		% crop includes all of the input data
	return
end
	
if ~isstruct(X),
	X = x(k,:) ;
	return
end
	
if length(fs)>1,
	X.data = [T x(k,:)] ;
else
	X.data = x(k,:) ;
end
X.crop = tcues ;
X.crop_units = 'seconds' ;
X.start_offset = tcues(1) ;
X.start_offset_units = 'seconds' ;

if ~isfield(X,'history') || isempty(X.history),
	X.history = 'crop_to' ;
else
	X.history = [X.history ',crop_to'] ;
end
