function    [M,cal,MMM] = auto_cal_mag(M,varargin)

%     [M,cal] = auto_cal_mag(M,cal,fstr)        % M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,cal,fstr,T)		% M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,cal,fstr,T,tc)	% M is a sensor structure
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr)     % M is a matrix
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr,T)	% M is a matrix
%		or
%     [M,cal] = auto_cal_mag(M,fs,cal,fstr,T,tc)	% M is a matrix
%
%		Automatic calibration of magnetometer data.
%		Inputs:
%		M is the raw (uncalibrated) magnetometer data in a matrix or sensor structure.
%		fs is the sampling rate of M. This is only needed if M is not a sensor structure.
%		cal is the calibration structure for the magnetometer. If there
%		 is no existing calibration, use [] for cal.
%		fstr is the local magnetic field strength in uT. To allow for the field strength
%		 changing over long deployments due to movement of the animal, fstr can also be a 
%      two-column matrix. In which case the first column is the time in seconds into the 
%		 deployment, and the second column is the corresponding magnetic field strength.
%		T is the optional tag temperature data in a vector or sensor structure. If T is a 
%		 vector, it must have the same sampling rate as M. If T is a sensor structure, it 
%		 can have a different sampling rate to M and will automatically be interpolated. 
%		 If temperature compensation is not required, T and tc can be omitted.
%		tc is an optional parameter that specifies either a time constant if positive or a
%      time delay if negative to apply to T. A positive tc specifies the time constant in 
%      seconds relating the temperature at the magnetometer to the temperature at the 
%      temperature sensor. This allows for a fast changing temperature sensor close to the 
%		 outside surface of the tag. A negative tc specifies the amount to delay T by in seconds. 
%		 Because tc is negative, this is always effectively an advance of -tc seconds. This time
%      advance can be used to partially compensate for a slow-responding temperature sensor. 
%		 If tc is not given, a value of 0 is used.
%		 For example, with DTAG4, tags with small 300 m pressure sensors need a tc of about 
%		 100 s. Tags with steel 2000 m pressure sensors do not need tc.
%
%		Results:
%		M is the calibrated magnetometer data. M is at the same sampling rate as the input data.
%		 If a sensor structure was input, M will also be a sensor structure.
%		cal is the updated calibration structure with added fields for the calibrations inferred
%		 from the data.
%
%		Note: if M is a sensor structure it can optionally include a field called cal_exclude which
%		 contains a two-column matrix. Each row is the start and end time of an interval in seconds
%		 to exclude from calibration. This is useful if animals approach magnetic anomalies such as
%		 metal structures and power lines. See pick_segments for a graphical tool for finding
%		 anomalies.
%
%     Valid: Matlab, Octave
%     markjohnson@bios.au.dk
%     Last modified: Jan 2022 - added exclusion table option


cal = [] ; fstr = [] ; T = [] ; tc = [] ; MMM=[];
TSEG = 1*24*3600 ;   % minimum cal segment length in seconds - should be at least 1 day
DO_CROP = 1 ;        % use 0 to bypass the crop step
fa = 5 ;             % target analysis sampling rate in Hz, was 1 Hz
CHECK = 0 ;          % debugging option - don't use normally
excl = [] ;				% exclude list

if nargin<2,
	help auto_cal_mag
	return
end
	
if isstruct(M),      % if M is a sensor structure, extract the data and sampling rate
	[Md,fs] = sens2var(M) ;
	nin = 1 ;
	if isfield(M,'cal_exclude'),
		DO_CROP = 0 ;
		excl = M.cal_exclude ;
	end
else
	if nargin<2 || isstruct(varargin{1}),
		fprintf(' Sampling rate is required with matrix data\n') ;
		return
	end
	Md = M ;
	fs = varargin{1} ;
	nin = 2 ;
end

if nargin>nin,    % sort out the remaining input arguments
	cal = varargin{nin} ;
end

if nargin>nin+1,
	fstr = varargin{nin+1} ;
   if length(fstr)>1 && size(fstr,2)~=2,
      fprintf('Field strength must have two columns: time (s) and strength (uT)\n') ;
      return
   end
else
	fstr = 1 ;
end

if isstruct(cal),       % check the cal structure, if one is given
   if isfield(cal,'POLY'),    % convert upper-case fields to lower case
      cal.poly = cal.POLY ;
      cal = rmfield(cal,'POLY') ;
   elseif ~isfield(cal,'poly'),
      cal.poly = [1 0;1 0;1 0] ;    % default polynomial if none is given
   end
else
	if ~isempty(cal),
		fprintf('CAL must be a structure - check you are using auto_cal_mag correctly\n') ;
		return
	end
   cal.poly = [1 0;1 0;1 0] ;
end

if nargin>nin+2,        % check the covariate argument if one is given
	T = varargin{nin+2} ;
	if isstruct(T),      % if T is a sensor-structure, extract the data
		[T,ft] = sens2var(T) ;
		if ft~=fs,
			T = interp2length(T,ft,fs,size(Md,1)) ;
		end
   end
   T = remove_nan(T) ;  % make sure there are no NaNs in the covariates
   if size(T,1)~=size(Md,1),
      fprintf('M and T must have the same number of samples\n');
      return
   end
end
	
if nargin>nin+3,
	tc = varargin{nin+3} ;
end

if ~isfield(cal,'cross'),
	cal.cross = eye(3) ;
end

J = sum(diff(Md).^2,2) ;   % find rapidly changing M
J(end+1) = J(end) ;

K = [] ;				% make exclusion list
for k=1:size(excl,1),
	K = [K round(excl(k,1)*fs):round(excl(k,2)*fs)] ;
end
K = max(min(K,size(Md,1)),1) ;
Md(K,:) = NaN ;	% blank out excluded data points

if fs>fa,      % reduce sampling rate of M and T if necessary
   df = ceil(fs/fa) ;      % decimation factor to use
   Md = decdc(Md,df) ;     % decimate M by df
   J = abs(decdc(J,df)) ;
   if ~isempty(T),
      Td = decdc(T,df) ;   % apply same decimation to T
   end
else
   df = 1 ;    % otherwise, keep the input sampling rate
   Td = T ;
end
fsd = fs/df ;           % decimated sampling rate

if DO_CROP==1,       % provide a crop gui if requested
   [Md,crp] = crop(Md,fsd) ;  % crop M now but leave T until later
   J = crop_to(J,fsd,crp) ;   % crop J the same as M
else
   crp = [0 (size(Md,1)-1)/fsd] ;   % default if there is no crop
end

nseg = max(floor(size(Md,1)/fsd/TSEG),1) ;   % number of analysis segments
kseg = [(0:nseg-1)*fsd*TSEG size(Md,1)] ; % sample limits of each segment
tseg = crp(1)+kseg/fsd ;      % time in seconds of each segment

if size(fstr,2)==2,     % interpolate field strength for each segment
   if fstr(1,1)>0,  % make sure first field strength value applies to start of data 
      fstr = [0 fstr(1,2);fstr] ;
   end
   if fstr(end,1)<tseg(end),     % and last value extends to end
      fstr(end+1,:) = [tseg(end),fstr(end,2)] ;
   end
   % interpolate field strengths to middle of each time segment
   fstr = interp1(fstr(:,1),fstr(:,2),tseg(1:end-1)+0.5*diff(tseg)) ;
else
	fstr = repmat(fstr,length(tseg)-1,1) ;
end

if ~isempty(T) 
	if ~isempty(tc),  % apply any advances or smoothing to Td before cropping
      if length(tc)~=size(Td,2),
         tc = repmat(tc,1,size(Td,2)) ;
      end
      for k=1:size(Td,2),
         if tc(k)<0,       % tc specifies the amount to delay the temperature vector
            nd = -round(fsd*tc(k)) ;
            Td(:,k) = [Td(nd:end,k);repmat(Td(end,k),nd-1,1)] ;
         elseif tc(k)>0,
            pf = 1/(fsd*tc(k)) ;  % pole frequency of a one-pole low-pass filter
            Td(:,k) = filter(pf,[1 -(1-pf)],Td(:,k),Td(1,k)) ;
         end
      end
      if any(tc<0),
         cal.tadvance = max(-tc,0) ;
      end
      if any(tc>0),
         cal.tconst = max(tc,0) ;
      end
   end
	Td = crop_to(Td,fsd,crp) ;  % now it is safe to do the crop
	cal.tcomp = zeros(3,size(T,2)) ;
	cal.tref = zeros(1,size(T,2)) ;
end

Poly = zeros(3,2,length(kseg)-1) ;
Cross = zeros(3,3,length(kseg)-1) ;
if ~isempty(T),
   Tcomp = zeros(3,size(Td,2),length(kseg)-1) ;
end
sigma = zeros(length(kseg)-1,2) ;

if CHECK,
	clf
	K={};
end

for k=1:length(kseg)-1,
	kk = kseg(k)+1:kseg(k+1) ;
	if ~isempty(T),
		[cc,ss,MM,kj] = cal_seg(J(kk),Md(kk,:),fstr(k),cal,Td(kk,:)) ;
	else
		[cc,ss,MM,kj] = cal_seg(J(kk),Md(kk,:),fstr(k),cal,[]) ;
   end
	% update CAL
	%if isempty(cc) || ss(2)>=ss(1),	% if no improvement in deviation...
	%	ss(2) = ss(1) ;
	%	cc = cal ;		% continue with old cal
   %   if ~isempty(T),
   %      cc.tcomp = zeros(3,size(Td,2)) ;
   %   end
   %end
	Poly(:,:,k) = cc.poly ;
	Cross(:,:,k) = cc.cross ;
   if ~isempty(T),
      Tcomp(:,:,k) = cc.tcomp ;
   end
	sigma(k,:) = ss ;
	
	if CHECK && ~isempty(MM),
      if k==length(kseg)-1,
         MMM = NaN(length(kk),3) ;
         MMM(kj,:) = MM ;
         plot(kj+kk(1)-1,norm2(MM),'.');hold on
      end
		K{k}=[kj+kk(1)-1 norm2(MM)];
	end
end

if size(sigma,1)==1, 	% only one segment in the calibration
	if sigma(2)>=sigma(1),
		fprintf(' Deviation not improved from %3.2f%% - check data\n',sigma(1)*100) ;
   else
      fprintf(' Deviation improved from %3.2f%% to %3.2f%%\n',sigma*100) ;
      cal = cc ;
   end
else     % more than one segment in the calibration
	sbad = sigma(:,2)>=sigma(:,1) ;
	if any(sbad),
		fprintf(' Deviation not improved in %d of %d intervals\n',sum(sbad),size(sigma,1)) ;
		if all(sbad),
			return
		end
	end
	
	fprintf(' Mean deviation improved from %3.2f%% to %3.2f%% over %d intervals\n',nanmean(sigma)*100,sum(~isnan(sigma(:,1)))) ;
	fprintf(' Interval\tStart day\tInitial %%\tFinal %%\n') ;
	for k=1:size(sigma,1),
		fprintf(' %d\t\t\t%2.1f\t\t\t%2.1f\t\t%2.1f\n',k,tseg(k)/86400,sigma(k,1)*100,sigma(k,2)*100) ;
	end
	cal.tseg = [0 tseg(2:end-1)] ;
	cal.poly = squeeze(Poly) ;
	cal.cross = squeeze(Cross) ;
   if ~isempty(T),
   	cal.tcomp = squeeze(Tcomp) ;
   end
end

if size(T,2)>1,
   cal.tcompsrc = 'various' ;
end

% apply cal to the complete magnetometer signal

if isstruct(M),
	if ~isfield(M,'history') || isempty(M.history),
		M.history = 'auto_cal_mag' ;
	else
		M.history = [M.history ',auto_cal_mag'] ;
	end
end

if ~isempty(T),
   if isstruct(M),
   	M=do_cal(M,cal,'T',T);
   else
   	M=do_cal(M,fs,cal,'T',T);
   end
else
   if isstruct(M),
      M=do_cal(M,cal);
   else
      M=do_cal(M,fs,cal);
   end
end

if CHECK,
	for k=1:length(K),
		S = K{k} ;
      if isstruct(M),
   		Md = sens2var(M);
      end
      if df>1,
         Md = decdc(Md,df) ;
      end
      Md = crop_to(Md,fsd,crp) ;
		nn = norm2(Md(S(:,1),:)) ;
      if k==length(K),
   		plot(S(:,1),nn,'g.')
      end
		fprintf('ls norm %3.1f%%, docal norm %3.1f%%, difference %3.1f%%\n',...
         [nanstd(S(:,2))/nanmean(S(:,2)) nanstd(nn)/nanmean(nn) nanmean(abs(nn-S(:,2)))/nanmean(nn)]*100) ;
	end
end
return


function		[cc,sigma,MM,k] = cal_seg(JJ,MM,fstr,cal,TT)
%
%
nn = sum(~isnan(JJ)) ;
if nn<0.2*length(JJ),
   cc=[];
   sigma=NaN(1,2);
   k=[];
   return
end

%pp = min(80,max(1,5e6/nn)) ;  % was 25
pp = 75 ;
thr = prctile(JJ,pp) ;
k = find(JJ<thr) ;
MM = MM(k,:) ;

if ~isempty(TT),
	TT = TT(k,:) ;
end

[MM,cc,sigma] = spherical_ls(MM,fstr,cal,3,TT) ;
return
