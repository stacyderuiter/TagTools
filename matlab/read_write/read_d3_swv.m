function    X = read_d3_swv(fname,ch)

%     X = d3parseswv(fname)
%		or
%     X = d3parseswv(fname,ch)
%
%     Read a D3 format SWV (sensor wav) sensor file using
%     the accompanying xml file to interpret the sensor channels.
%     To read all sensor files from a deployment, use read_d3
%     which calls this function.
%
%		Inputs:
%     fname is the file name of the D3 file to be read, including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .swv suffix is not needed.
%		ch is an optional argument that limits the read to just the sensor
%		 channels listed in the vector ch. The sensor channel numbers refer to
%		 the channel numbers that would normally be read if ch was not specified,
%		 i.e., ch=[2,3] would read just the 2nd and 3rd sensor channel. Default 
%		 is to read all channels.
%
%     Returns:
%		X is a structure with the following fields.
%     X.x is a cell array of sensor vectors. There are as many
%      cells in x as there are unique sensor channels in the
%      recording. Each cell may have a different length vector
%      according to the sampling rate of the sensor channel.
%     X.fs is a vector of sampling rates. Each entry in fs is the
%      sampling rate in Hz of the corresponding cell in x.
%     X.cn is a vector of channel id numbers corresponding to
%      the cells in x. Use read_d3_chan_names to get the name and
%      description of each channel.
%
%     Updated 11/2/16 to fill NaN in outages
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

X.x = [] ; X.fs = [] ; X.cn = [] ;
if nargin<1,
	help read_d3_swv
	return
end
	
% remove a suffix from the file name if there is one because we need to read
% both .swv and .xml files with the same name.
if any(fname=='.'),
   fname = fname(1:find(fname=='.',1,'last')-1) ;
end

% get metadata
% get sensor channel names from the xml file 
d3 = read_d3_xml([fname '.xml']) ;
if isempty(d3) | ~isfield(d3,'CFG'),
   fprintf('Unable to find or read file %s.xml - check the file name\n', fname);
   return
end

[CFG,fb,dtype] = getSensorCfg(d3.CFG) ;		% see below for this function
if isempty(CFG),
   fprintf('No sensor configuration in file %s\n',fname) ;
   return
end

% find the channel count and numbers
N = str2num(CFG.CHANS.N) ;
if isempty(N),
   fprintf('Invalid attribute in CHANS field - check xml file\n') ;
   return
end

chans = sscanf(CFG.CHANS.CHANS,'%d,') ;

if length(chans)~=N,
   fprintf('Attribute N does not match value size in CHANS field - check xml file\n') ;
   return
end

chans = chans(:) ;
uchans = unique(chans) ;

% read the swv file and convert to fractional offset binary
n = get_audio([fname '.swv'],'size') ;
if n(1)*n(2)>50e6,
   fprintf(' File is too large to read in (%d bytes)\n',n(1)*n(2)*8) ;
   return ;
end
xb = get_audio([fname '.swv']) ;
if dtype==3,
   k = find(xb<0) ;
   xb(k) = 2+xb(k) ;               % convert from two's complement to offset binary
   xb = xb/2 ;                     % sensor reading range is 0..1 in Matlab
   xb(xb==0) = NaN ;               % replace fill values with NaN
end

% group channels
x = cell(length(uchans),1) ;
fs = zeros(length(uchans),1) ;
for k=1:length(uchans),
   kk = find(chans==uchans(k)) ;
   fs(k) = fb*length(kk) ;
   x{k} = reshape(xb(:,kk)',[],1) ;
end

if nargin<2 | isempty(ch),
   ch = 1:length(fs) ;
else
   ch = ch(ch>0 & ch<=length(fs)) ;
end

X.x = {x{ch}} ;
X.fs = fs(ch) ;
X.cn = uchans(ch) ;
return


function    [CFG,fb,dtype] = getSensorCfg(cfgs)
%
%
[CFG,fb] = checkD3Cfg(cfgs) ;
if ~isempty(CFG),
   dtype = 3 ;
else
   [CFG,fb] = checkD4Cfg(cfgs) ;
   dtype = 4 ;
end
return


function    [CFG,fb] = checkD3Cfg(xmlcfg)
%
%
CFG = [] ; fb = 0 ;
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && strncmp(c(1).PROC,'SENSOR',6)
      CFG = c(1) ;
      % find the sensor sampling rate
      switch CFG.MCLK.UNITS,
         case  'MHz'
            mf = 1e6 ;
         case  'kHz'
            mf = 1e3 ;
         case  'Hz'
            mf = 1 ;
         otherwise
            fprintf('Unknown unit in MCLK field "%s"\n',CFG.MCLK.UNITS) ;
            return
      end
      mclk = str2num(CFG.MCLK.MCLK)*mf ;
      fb = mclk/str2num(CFG.CLKDIV)/str2num(CFG.CHANS.N) ;
      break ;
   end
end
return


function [CFG,fb] = checkD4Cfg(xmlcfg)
%
%
CFG = [] ; fb = 0 ;
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && (strncmp(c(1).PROC,'SENS',4) || strncmp(c(1).PROC,'ACC',1)),
      CFG = c(1) ;
      sid = CFG.ID ;
      fb = str2num(CFG.FS.FS) ;      % find the sensor sampling rate
      break ;
   end
end

if isempty(CFG),
   return
end

% check if the sensor included a decimator - need to do this because the channel assignments
% change if there is a decimator
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && strncmp(c(1).PROC,'SDEC',4) && strncmp(c(1).SRC.ID,sid,length(sid))
      CFG.CHANS.CHANS = c(1).CHANS.CHANS ;
      CFG.CHANS.N = c(1).CHANS.N ;
      break ;
   end
end
return
