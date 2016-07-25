function    CL = findmissedclicks(tag,CL,FBP,TH,cue)
%
%    C = findmissedclicks(tag,C,[FBP,TH,cue])
%    Tool to add clicks to a click list based upon gaps in the ICI.
%    C is either a click list from findclicks or the output of a previous
%    call to findmissedclicks. FBP is a bandpass filter frequency
%    specification FBP=[fl,fh]. TH=[ts,fd] or TH=ts, where ts is the
%    shortest gap in the ICI to consider and fd is the minimum fractional 
%    change in ICI to consider as a gap. Default values are TH=[0.4 0.5].
%    If cue is specified, only gaps after cue will be checked.
%
%    Valid on-screen instructions are:
%     x - delete nearest click
%     r - delete all clicks in interval
%     f - go to next gap
%     b - go to last gap
%     F - go to next 5s interval
%     B - go to previous 5s interval
%     g - go to next same sized interval
%     n - go to previous same sized interval
%     s - select the nearest single click with level above the cursor
%     t - select all clicks in the interval with level above the cursor
%     q - quit
%     left-button click - look for a click at the cursor
%           in the envelope window, press the left button to accept
%           the suggested click cue; type 's' to force a cue at the
%           cursor position; or type 'x' to abandon the click.
%
%    Returns vector C of click cues.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: July 2006
%

if nargin<3,
   help findmissedclicks
   return
end

THDEF = [0.4 0.5] ;     % default thresholds
BL = 512 ;              % specgram (fft) block size
CLIM = [-90 0] ;        % color axis limits in dB for specgram
WIN = 750 ;             % show +-WIN samples in click select window
SWIN = 0.5e-3 ;
MARGIN = 0.5 ;
RELTH = 0.1 ;
MAXICI = 1 ;            % maximum ICI to display
MAXSHOW = 5 ;           % maximum gap to show
RECFILE = 'RECOVER_findmissedclicks' ;

if nargin<4,
   TH = THDEF ;        
elseif length(TH)==1,
   TH(2) = THDEF(2) ;
end

if nargin<5,
   cue = 0 ;
end

if ~isempty(CL),
   CL = sort(CL(:,1)) ;
end

[c,t,s,len,fs,id]=tagcue(tag) ;
afs = fs(1) ;

if nargin<3,
   if afs > 96e3,
      FBP = [10e3,70e3] ;
   else
      FBP = [10e3,45e3] ;
   end
end

[b a] = butter(4,FBP/(afs/2)) ;
OPTS.fh = FBP ;
OPTS.fl = [] ;
k = 1 ;
FORCE = 0 ;

while 1,
   if ~FORCE,
      gaps = findgaps(CL,TH,cue) ;
      if isempty(gaps),
         return
      elseif k>size(gaps,1),
         k = size(gaps,1) ;
      end
      margin = max([WIN/afs min([3*gaps(k,2) MAXSHOW])])+WIN/afs ;
      st = CL(gaps(k),1)-margin ;
      ed = CL(gaps(k),1)+margin ;
   else
      FORCE = 0 ;
   end

   x = tagwavread(tag,st,ed-st) ;
   xf = filter(b,a,x(:,1)) ;
   xx = hilbenv(xf) ;
   MX = max(xx(WIN:end-WIN)) ;
   [B F T] = specgram(x(:,1),BL,afs,hamming(BL),BL/2) ;
   figure(1), clf
   subplot(211), plot(st+(1:length(xx))/afs,xx); grid
   ss = sprintf('Gap %d of %d',k,length(gaps)) ;
   title(ss) ;
   xax = [st+WIN/afs ed-WIN/afs] ;
   set(gca,'XLim',xax,'YLim',[0 MX*1.1]) ;
   hold on
   kkk = find(CL>st & CL<ed) ;
   if ~isempty(kkk),
      doth = plot(CL(kkk),0.9*MX+0*kkk,'ro') ;
   else
      doth = plot(0,0,'ro') ;   
   end

   BB = adjust2axis(20*log10(abs(B))) ;
   subplot(212), imagesc(st+T+BL/2/afs,F/1000,BB,CLIM) ;
   axis xy, grid ;
   set(gca,'XLim',xax) ;
   subplot(211)
   
   done = 0 ;
   while done==0,
      figure(3),clf
      marg = 20*(ed-st) ;
      kdi = find(CL>st-marg & CL<ed+marg) ;
      dc = diff(CL(kdi)) ;
      dc(find(dc>MAXICI)) = NaN ;
      plot(CL(kdi(2:end)),dc,'.-'),grid
      hold on
      kdi = find(CL>st & CL<ed) ;
      dc = diff(CL(kdi)) ;
      dc(find(dc>1)) = NaN ;
      plot(CL(kdi(2:end)),dc,'r*')

      figure(1)
      pause(0) ;        % to force a draw
      [gx gy button] = ginput(1) ;

      if button==3 | button=='q',
         CL = sort(CL) ;
         return ;

      elseif button=='x' & gx>xax(1) & gx<xax(2) & ~isempty(kkk),
         [mm nn] = min(abs(CL(kkk)-gx)) ;
         CL = CL([1:kkk(nn)-1 kkk(nn)+1:end]) ;
         kkk = find(CL>st & CL<ed) ;
         set(doth,'XData',CL(kkk,1),'YData',0.9*MX+0*kkk) ;
         save(RECFILE,'CL') ;

      elseif button=='r' & ~isempty(kkk),
         CL = CL([1:kkk(1)-1 kkk(end)+1:end]) ;
         kkk = find(CL>st & CL<ed) ;
         set(doth,'XData',CL(kkk),'YData',0.9*MX+0*kkk) ;
         save(RECFILE,'CL') ;
         
      elseif button=='f',
         k = k+1 ;
         if k>length(gaps),
            done = 2 ;
         else
            done = 1 ;
         end

      elseif button=='F',
         FORCE = 1 ;
         st = ed-1 ;
         ed = ed+4 ;
         done = 1 ;

      elseif button=='g',
         FORCE = 1 ;
         len = max([2*WIN/afs ed-st]) ;
         st = ed-0.1*len ;
         ed = ed+0.9*len ;
         done = 1 ;

      elseif button=='b',
         k = max([1 k-1]) ;
         done = 1 ;

      elseif button=='B',
         FORCE = 1 ;
         ed = st+1 ;
         st = st-4 ;
         done = 1 ;
         
      elseif button=='n',
         FORCE = 1 ;
         len = max([2*WIN/afs ed-st]) ;
         ed = st+0.1*len ;
         st = st-0.9*len ;
         done = 1 ;

      elseif button=='s',
         if gy<0 | gy>max(xx) | gx<xax(1) | gx>xax(2)
            fprintf('Click inside the envelope plot to select a threshold\n') ;
         else
            kss = round(afs*(gx-st)+(-afs*SWIN:afs*SWIN)) ;
            % find first crossing of the relative threshold 
            nn = min(find(xx(kss)>gy)) ;
            if ~isempty(nn),
               cc = gx-SWIN + (nn-1)/afs ;
               CL = sort([CL;cc]) ;
               kkk = find(CL>st & CL<ed) ;
               set(doth,'XData',CL(kkk),'YData',0.9*MX+0*kkk) ;
               save(RECFILE,'CL') ;
            end
         end

      elseif button=='t',
         if gy<0 | gy>max(xx) | gx<xax(1) | gx>xax(2)
            fprintf('Click inside the envelope plot to select a threshold\n') ;
         else
            % find first crossing of the relative threshold 
            opts.env = 1 ;
            opts.protocol = 'first' ;
            opts.fh = [] ;
            opts.blanking = 1e-3 ;
            cc = getclickx(xx,gy,afs,opts) ;
            if ~isempty(cc),
               CL = sort([CL;cc+st]) ;
               kkk = find(CL>st & CL<ed) ;
               set(doth,'XData',CL(kkk),'YData',0.9*MX+0*kkk) ;
               save(RECFILE,'CL') ;
            end
         end
         
      elseif button==1,
         if gx<xax(1) | gx>xax(2)
            fprintf('Click inside the figure to select a click\n') ;
         else
            cc = gx ;
            kss = round(afs*(gx-st))+(-WIN:WIN) ;
            tt = (-WIN:WIN)/afs ;
            figure(2),clf
            subplot(212)
            plot(tt,xf(kss)),grid,set(gca,'XLim',[tt(1) tt(end)]) ;
            subplot(211)
            hh = xx(kss) ;
            plot(tt,hh),grid,set(gca,'XLim',[tt(1) tt(end)]) ;
            % find first crossing of the relative threshold 
            nn = min(find(hh>RELTH*max(hh))) ;
            hold on
            hline = plot(tt(nn)*[1;1],get(gca,'YLim')','r') ;
            [gx gy button] = ginput(1) ;
            if button=='s',
               cc = cc+gx ;
               set(hline,'XData',gx*[1;1]) ;
               pause(0.5) ;
            elseif button=='x',
               cc = [] ;
            else
               cc = cc+tt(nn) ;
            end
            figure(1) ;
            if ~isempty(cc),
               CL = sort([CL;cc]) ;
               kkk = find(CL>st & CL<ed) ;
               set(doth,'XData',CL(kkk),'YData',0.9*MX+0*kkk) ;
               save(RECFILE,'CL') ;
            end
            
         end

      else
         fprintf('Invalid click: commands are f b F B g n q r s t x and left button\n')
      end   % if button
   end      % while done==0
end         % while ~done
return


function gaps = findgaps(cl,TH,cue)
%
% make gap list
dcl = diff([0;cl;cl(end)+1000]) ;
ddcl = abs(diff(dcl)) ;
mdcl = 0.5*(dcl(1:end-1)+dcl(2:end)) ;
mndcl = min([dcl(1:end-1) dcl(2:end)]')' ;
gaps = find(mdcl>TH(1) & ddcl>TH(2)*mndcl)  ;
kg = find(cl(gaps)>cue) ;
gaps(:,2) = mndcl(gaps) ;
if isempty(kg),
   gaps = [] ;
else
   gaps = gaps(kg,:) ;
end
return
