function		[XX,cal,sigma] = spherical_ls(X,fstr,cal,method,T)

%		[X,cal,sigma] = spherical_ls(X,fstr,cal,method,T)
%		Least squares solver for spherical data-driven calibration.
%		This function is used by auto_cal_acc and auto_cal_mag, and
%		is a wrapper function for lssolve3.
%
%		Inputs:
%		X is a 3-column data matrix representing measurements of a
%		 field vector (i.e., a constant norm). X may be affected by
%		 various calibration errors and by additive noise.
%		 The objective of this function is to infer the calibration
%		 errors in X so as to return an improved estimate of the
%		 correct field vector measurements.
%		fstr is the target field strength in the same units as X.
%		cal is an optional structure of calibration information.
%		 Only cal.poly and cal.cross are supported.
%		method selects different calibration correction options from:
%				1 = offset only (the default if method is not given)
%				2 = offset and gain
%				3 = offset, gain and cross-terms
%           4 = offset, gain and cross-terms, and auxiliary covariate
%		T is an optional matrix of auxiliary covariates (e.g., temperature
%      or pressure measurements) with the same number of rows as X. Each
%      column of T is a covariate. If multiple covariates are given, these
%      should be reasonably uncorrelated to avoid numerical problems.
%
%		Returns:
%		X is the improved data matrix after calibration errors have been
%		 corrected.
%		cal is the improved calibration structure.
%		sigma is a 2-element vector reporting the standard deviation of the
%		 field strength in the data, relative to the mean field, before and
%		 after data-driven calibration.
%
%     Valid: Matlab, Octave
%     markjohnson@bio.au.dk
%     Last modified 27 Dec 2019 - added support for multiple covariates

if nargin<3,
	g = eye(3,4) ;
else
	g = [diag(cal.poly(:,1)),cal.poly(:,2)] ;
end

if nargin<4,
	method = 1 ; 
end
	
if nargin<5,
	T = [] ; 
end

nn = norm2(X) ;
sigma(1) = nanstd(nn)/nanmean(nn) ;
XX = X*g(:,1:3)+repmat(g(:,4)',size(X,1),1) ;	% apply initial cal

for k=1:4,     % repeat 4 times for convergence
	[XX,g] = lssolve3(XX,g,method,T);		% solve for gain and/or cross
end

cr = inv(diag(diag(g)))*g(:,1:3) ;
%g(:,1:3) = diag(diag(g))*0.5*(cr+cr') ;	% apply cross terms symmetrically

if nargin>=2 && ~isempty(fstr),
	scf = fstr/nanmean(norm2(XX)) ;
	XX = XX*scf ;
else
	scf = 1 ;
end

cal.cross = inv(diag(diag(g)))*g(:,1:3) ;
g(:,4) = inv(cal.cross)'*g(:,4) ;
cal.poly = scf*[diag(g) g(:,4)] ;

if ~isempty(T),
	cal.tcomp = scf*inv(cal.cross)'*g(:,5:end) ;
end

nn = norm2(XX) ;
sigma(2) = nanstd(nn)/nanmean(nn) ;

% below lines just to check that cal is correctly updated
%X = do_cal(X,1,cal,'nomap','T',T) ;
%nn = norm2(X) ;
%[sigma(2),nanstd(nn)/nanmean(nn)]	% should be the same
