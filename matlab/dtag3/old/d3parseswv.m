function    [x,fs,uchans] = d3parseswv(fname)
%
%    [x,fs,uchans] = d3parseswv(fname)
%
%

% get sensor channel names from the xml file 
[attr,val] = getxmlfield(fname,'CHANS') ;
   
if isempty(attr)|isempty(val),
   fprintf('Unable to read xml file or find CHANS field\n') ;
   return
end

N = [] ;
for k=1:length(attr),
   [n m] = strtok(attr{k},'="') ;
   if strcmp(n,'N'),
      [n m] = strtok(m,'="') ;
      N = str2num(n) ;
      break
   end
end

if isempty(N),
   fprintf('Invalid attribute in CHANS field - check xml file\n') ;
   return
end

if length(val)~=N,
   fprintf('Attribute N does not match value size in CHANS field - check xml file\n') ;
   return
end

chans = [] ;
for k=1:N,
   n = strtok(val{k},' ,') ;
   chans(end+1) = str2num(n) ;
end

chans = chans(:) ;
uchans = unique(chans) ;

% get precise conversion rate from the xml file
[attr,val] = getxmlfield(fname,'MCLK') ;
if isempty(val),
   fprintf('Unable to read xml file or find MCLK field\n') ;
   return
end

mclk = str2num(val)*1e6 ;

[attr,val] = getxmlfield(fname,'CLKDIV') ;
if isempty(val),
   fprintf('Unable to read xml file or find MCLK field\n') ;
   return
end

fb = mclk/str2num(val)/N ;

% read the swv file and convert to fractional offset binary
xb = wavread16([fname '.swv']) ;
xb(xb<0)=2+xb(xb<0) ;
xb=xb/2 ;

% group channels
x = cell(length(uchans),1) ;
fs = zeros(length(uchans),1) ;
for k=1:length(uchans),
   kk = find(chans==uchans(k)) ;
   fs(k) = fb*length(kk) ;
   x{k} = reshape(xb(:,kk)',[],1) ;
end

