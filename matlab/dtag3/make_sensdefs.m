function    make_sensdefs(d3path)
%
%    make_sensdefs(d3path)
%     Automatically generate the sensdefs.h header file
%     from the master d3sensdef.csv
%     Use \ for the path definition
%     When this function has finished, copy the resulting sensdefs.h
%     file from the d3/matlab directory to d3/api/include.

if ismember(d3path(end),'\/')
   d3path = d3path(1:end-1) ;
end

k = find(d3path=='/') ;
d3path(k) = '\' ;
dos(['copy ' d3path '\matlab\sensdefs_template.h ' d3path '\matlab\sensdefs.h']) ;

f = fopen([d3path '\matlab\sensdefs.h'],'at') ;
[S,hdr]=readcsv('d3sensordefs.csv');

t = clock ;
fprintf(f,'\n// Last generated %02d:%02d:%02d %s\n\n',t(4),t(5),round(t(6)),date) ;

for k=1:length(S),
   fprintf(f,'#define %s (%s) // %s\n',stripquotes(S(k).name),...
      S(k).number,stripquotes(S(k).description)) ;
end

fclose(f) ;
