function		s = get_researcher(initial)

%		s = get_researcher(initial)

s = [] ;
S = read_csv(which('researchers.csv')) ;
if nargin==0,
	for k=1:length(S),
		fprintf(' %s %s\n',S(k).Initial,S(k).Name) ;
	end	
	return
end

% look for S.Initial that matches researcher initial
k = strmatch(initial,{S.Initial},'exact') ;

if isempty(k),
	fprintf(' No entry matching "%s" in researchers file - edit file and retry\n',initial) ;
	return ;
end

if length(k)>1,
	fprintf(' Multiple entries matching "%s" in researchers file:\n',initial) ;
	for kk=1:length(k),
		fprintf(' %d %s\n',kk,S(k(kk)).Name) ;
	end
	n = input(' Enter number for correct researcher... ','s') ;
	n = str2double(n) ;
	if isempty(n) || isnan(n) || n<1 || n>length(k), return ; end
	k = k(n) ;
end

s = S(k) ;
