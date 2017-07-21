function  X = extract(x,fs,tst,ted)

%     X = extract(x,fs,tst,ted)
%     Extract a sub-sample of data from a vector or matrix. 
%
%		Inputs:
%     x is a vector or matrix of measurements. If x is a matrix, each column
%		 is treated as a separate measurement vector.
%     fs is the sampling rate in Hz of the data in x.
%     tst defines the start time in seconds of the interval to be extracted from x.
%     ted defines the end time in seconds of the interval to be extracted from x.
%
%     Returns:
%     X is a matrix containing a sub-sample of x. X has the same number of columns 
%		 as x. The length of the sub-sample will be round(fs*(tend-tstart)) samples. 
%
%		Output sampling rate is the same as the input sampling rate.
%		If either tstart or tend are beyond the length of x, non-existing samples will 
%		be replaced with NaN in X. 
%
%		Example:
%		 X = extract(x,fs,tintvl)
% 	    returns: X=.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

X = [] ;
if nargin<4,
   help extract
   return
end

if size(x,1)==1,
	x = x(:) ;
end
	
npre = [] ; npst = [] ;
kst = round(fs*tst)+1 ;
ked = round(fs*ted) ;
if kst>size(x,1),
	return
end
	
if kst<0,
	npre = -kst ;
	kst = 1 ;
end

if ked>size(x,1),
	npst = ked-size(x,1) ;
	ked = size(x,1) ;
end

X = [NaN*zeros(npre,size(X,2));x(kst:ked,:);NaN*zeros(npst,size(X,2))] ;
