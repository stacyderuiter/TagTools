function		s = get_species(initial)

%		s = get_species(initial)

s = [] ;
S = read_csv('species.csv') ;
if nargin==0,
	for k=1:length(S),
		fprintf(' %s %s\n',S(k).Initial,S(k).Common_name) ;
	end	
	return
end

% look for S.Initial that matches species initial
k = strmatch(initial,{S.Initial},'exact') ;

if isempty(k),
	fprintf(' No entry matching "%s" in species file - edit file and retry\n',initial) ;
	return ;
end

if length(k)>1,
	fprintf(' Multiple entries matching "%s" in species file:\n',initial) ;
	for kk=1:length(k),
		fprintf(' %d %s\n',kk,S(k(kk)).Common_name) ;
	end
	n = input(' Enter number for correct species... ','s') ;
	n = str2double(n) ;
	if isempty(n) || isnan(n) || n<1 || n>length(k), return ; end
	k = k(n) ;
end

s = S(k) ;
