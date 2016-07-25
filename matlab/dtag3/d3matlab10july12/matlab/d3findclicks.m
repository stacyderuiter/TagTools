function    CL = d3findclicks(recdir,prefix,cues,INOPTS)
%
%     CL = d3findclicks(recdir,prefix,cues,OPTS)
%		General purpose automatic click finder. Always follow with
%     findmissedclicks to ensure that most clicks are identified.
%
%     tag is the tag deployment string e.g., 'sw03_207a'
%     cue is the time in seconds-since-tag-on to start and end working.
%        cue = [start_cue end_cue].
%		OPTS is an optional 2-vector of high-pass and low-pass frequencies
%        defining a filter to apply to the audio before click detection. 
%        If no filt is given or filt=[] the species prefix in tag is used
%        to select sensible values. If OPTS is a structure, it is passed
%        directly to the click finder routine (rainbow.m). Valid fields
%        are OPTS.fh, OPTS.blanking and OPTS.thrfactor.
%     CL is the click list.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: 15 January 2007

CL = [] ;
if nargin<3,
   help d3findclicks
   return
end

LEN = 20 ;
OPTS.def.fh = [20e3 50e3] ;
OPTS.def.blanking = 15e-3 ;
OPTS.def.thrfactor = 1 ;
OPTS.def.minthr = 0.0005 ;
OPTS.def.nodisp = 1 ;
 
if nargin<4,
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts('',OPTS,INOPTS) ;

if length(cues)~=2,
   fprintf(' Must give a start and end cue\n') ;
   return
end

done = 0 ;
scue = cues(1) ;
ecue = cues(2) ;

while ~done,
   len = min([LEN ecue-scue+0.5]) ;
   fprintf(' Reading %3.1fs at %5.1f... ',len,scue) ;

   % read in current block of audio
   [x,fs] = d3wavread(scue+[0 len],recdir,prefix) ;

   % find all clicks in current block
   cl = rainbow(x,fs,OPTS) ;

   % identify saved clicks and append any clicks that don't appear in CL
   cl = scue+cl ;
   if ~isempty(CL),
      kk = find(cl>=CL(end)+OPTS.blanking & cl<ecue) ;
   else
      kk = find(cl<ecue) ;
   end
   
   if ~isempty(kk),
      CL = [CL;cl(kk)] ;     % and add them to CL
   end
   
   scue = scue+len-0.1 ; 
   done = scue >= ecue ;
end

