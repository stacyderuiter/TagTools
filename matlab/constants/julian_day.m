function      n = julian_day(y,m,d)
%
%      n = julian_day(y,m,d)
%      Convert between dates and Julian day numbers.
%		 n = julian_day
%		   Returns the Julian day number for today.
%		 n = julian_day(y,d)
%			where y is a single year or a vector of years
%			and d is a single day number or a vector of day
%			numbers.
%		   Returns the date vector [year,month,day] for each
%			year,day pair.
%		 n = julian_day(y,m,d)
%			where y is a single year or a vector of years,
%			m is a single month or vector of months, and d is
%			a single month day or a vector of month days.
%		 	Returns the Julian day number for each year, month, day.
%
%		 Example:
%			julian_day(2016,10,12)	% returns 286
%			julian_day(2016,286)		% returns [2016,10,12]
%
%      Valid: Matlab, Octave
%      markjohnson@st-andrews.ac.uk
%      Last modified: 4 May 2017

n = [] ;
switch nargin,
	case 0,
		d = clock ;
		t = now ;
		n = floor(t-datenum([d(1) 1 1 0 0 0]))+1 ;
	case 2,
		k = max([length(y) length(m)]) ;
		if length(y)<k,
			y(end+1:k) = y(end) ;
		end
		if length(m)<k,
			m(end+1:k) = m(end) ;
		end
		n = datevec(datenum(horzcat(y(:),zeros(length(y),1),m(:)))) ;
		n = n(:,1:3) ;
	case 3,
		k = max([length(y) length(m) length(d)]) ;
		if length(y)<k,
			y(end+1:k) = y(end) ;
		end
		if length(m)<k,
			m(end+1:k) = m(end) ;
		end
		if length(d)<k,
			d(end+1:k) = d(end) ;
		end
		t = datenum(horzcat(y(:),m(:),d(:))) ;
		n = floor(t-datenum([y(:) repmat([1 1 0 0 0],length(y),1)]))+1 ;
	otherwise
		help julianday
		return
end
