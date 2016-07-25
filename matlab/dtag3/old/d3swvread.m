function    [x,fs,uchans,ch_names,descr] = d3swvread(recdir,prefix,files,d3dir)
%
%    [x,fs,uchans,ch_names,descr] = d3swvread(recdir,prefix,files,d3dir)
%

suffix = 'swv' ;
k = strfind(prefix,['.' suffix]) ;
if ~isempty(k),
   prefix = prefix(1:k-1) ;
end

[ct,fsb,fn,recdir] = d3getcues(recdir,prefix,suffix) ;

if nargin>=3 & ~isempty(files),
   fnn = {} ;
   for k=1:length(files),
      kk = strmatch([recdir prefix sprintf('%03d',files(k))],fn,'exact') ;
      if ~isempty(kk),
         fnn{end+1} = fn{kk} ;
      end
   end
   fn = fnn ;
end

X = {} ;
for k=1:length(fn),
   fprintf('Reading %s...', fn{k}) ;
   [x,fs,uchans] = d3parseswv(fn{k}) ;
   [X{k,1:length(fs)}] = deal(x{:}) ;
   fprintf('\r') ;
end

x = cell(1,length(fs)) ;
for k=1:length(fs),
   x{k} = vertcat(X{:,k}) ;
   [X{:,k}] = deal({}) ;
end

if nargout<=3,
   return
end

if nargin<4,
   fprintf('d3swvread: Need d3dir argument to convert channel names\n') ;
   ch_names = [] ;
   descr = [] ;
else
   [ch_names,descr,ch_nums] = d3channames(d3dir,uchans) ;
end

