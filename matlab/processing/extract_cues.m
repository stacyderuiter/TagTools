function  [X,cues] = extract_cues(x,fs,cues,len)

%     [X,cues] = extract_cues(x,cues,len) % x is sensor structure
%     or
%     [X,cues] = extract_cues(x,fs,cues,len) % x is a vector or matrix
%
%     Extract multiple sub-samples of data from a vector or matrix. 
%
%		Inputs:
%     x is a sensor structure or a vector or matrix of measurements. 
%      If x (or the data inside x) is a matrix, each column is treated as 
%      a separate measurement vector.
%     fs is the sampling rate in Hz of the data in x. fs is only needed if
%      x is not a sensor structure. In fact, if x is a sensor structure and
%      fs is input anyway, this will not work. So, DO NOT input fs if
%      you're inputting data from a sensor structure for x.
%     cues defines the start time in seconds of the intervals to be extracted from x.
%     len is the length of the interval to extract in seconds. This should be a scalar.
%
%     Returns:
%     X is a matrix containing sub-samples of x. If x is a vector, X has as many
%		 columns as there are cues, i.e., each cue generates a column of X.
%		 If x is a pxm matrix, X will be a qxmxn matrix where n is the size of cues and 
%		 q is the length of the interval requested, i.e., round(fs*len) samples. 
%		cues is the list of cues actually used. cues that require data outside of x are
%		 rejected.
%
%		Output sampling rate is the same as the input sampling rate.
%
%		Example:
%
%        load_nc('testset1')
%        sampling_rate = P.sampling_rate
%        timecues = [0 120 300 600]
%        length = 30
%		 X = extract_cues(P, sampling_rate, timecues, length)
% 	    returns: TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

X = [] ;
if nargin<3,
   help extract_cues
   return
end

if isstruct(x),
   len = cues ;
	cues = fs ;
	[x,fs] = sens2var(x) ;
	if isempty(x), return, end
elseif nargin<4,
	help extract_cues
	return
end

if size(x,1)==1,
	x = x(:) ;
end
	
kcues = round(fs*cues) ;
klen = round(fs*len(1)) ;	
k = find(kcues>=0 & kcues<size(x,1)-klen) ;
kcues = kcues(k) ;
cues = cues(k) ;

if(size(x,2)==1),
   X = zeros(klen,length(k)) ;
   for kk=1:length(k),
      X(:,kk) = x(kcues(kk)+(1:klen),:) ;
   end
else
   X = zeros(klen,size(x,2),length(k)) ;
   for kk=1:length(k),
      X(:,:,kk) = x(kcues(kk)+(1:klen),:) ;
   end
end

