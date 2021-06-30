function		[X,varargout] = crop_all(tcues,X,varargin)

%		X = crop_all(tcues,X)		% X is a sensor structure or set of sensor structures
%		or
%		[X,Y,...] = crop_all(tcues,X,Y,...)		% X, Y, ... are sensor structures
%
%		Reduce the time span of a dataset by cropping out any data that falls before and
%		after two time cues.
%
%     Inputs:
%		tcues is a two-element vector containing the start and end time cue
%		 in seconds of the data segment to keep, i.e., tcues = [start_time, end_time].
%     X is a sensor structure or a set of sensor structures (e.g., from loadnc).
%		Y,... are additional sensor structures.
%
%     Results:
%     X is a sensor structure or set of sensor structures containing the cropped data segment.
%		 The output data have the same units, frame and sampling characteristics as the input.
%     Y,... are additional sensor structures as required to match the input.
%
%		Example:
%		 X = load_nc('testset3'); % in Octave, this semicolon is very important
%		 d = find_dives(X.P,300) ;
%		 X = crop_all([d.start(2) d.end(2)],X);	% crop all data to 2nd dive
%		 plott(X.P,X.A)
%		 % plot shows the dive profile and acceleration of the second dive
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 28 July 2017

if nargin<2,
	help crop_all
	return
end
	
if ~isstruct(X),
	fprintf(' Input to crop_all must be sensor structures\n');
	X = [] ;
	return
end
	
if isfield(X,'info'),		% X is a set of sensor structures
	f = fieldnames(X) ;
	for k=1:length(f),
		if strcmpi(f{k},'info'), continue, end
		X.(f{k}) = crop_to(X.(f{k}),tcues) ;
	end
	return
end

X = crop_to(X,tcues) ;
n = min(nargin-1,nargout)-1 ;
for k=1:n,
	varargout{k} = crop_to(varargin{k},tcues) ;
end
	