function    BZ = buzzici(BZ)
%
%    BZ = buzzici(BZ)
%     Adds the following fields to the BZ structure based
%     on computations in the BZ.clicks fields
%     BZ.start           absolute time of first click in buzz
%     BZ.end             absolute time of last click in buzz
%     BZ.duration        0.1-0.1s buzz duration
%     BZ.meanici         mean ICI over buzz
%     BZ.minici          minimum ICI in buzz
%     BZ.nclicks         number of buzz clicks
%     BZ.initialici      mean ICI clicks 6-25
%     BZ.click6_25       time of clicks 6 and 25 since start of buzz
%     BZ.initialicitime  absolute mean time of clicks 6-25
%     BZ.ngood           number of buzzes without gaps in ICI
%     BZ.prebzici        ICI of the last clicks before the buzz
%     BZ.prebz2ici        ICI of the last clicks before the buzz
%     BZ.prebz3ici        ICI of the last clicks before the buzz

M = NaN*ones(length(BZ.clicks),13) ;
if ~isfield(BZ,'initicibad'),
   BZ.initicibad = [] ;
end

for k=1:length(BZ.clicks),
   if ~isempty(BZ.clicks{k}) & ~isnan(BZ.clicks{k}(1)) & ~ismember(k,BZ.initicibad),
      cl = BZ.clicks{k}(:,1) ;
      dcl = diff(cl) ;
      st = min(find(dcl<0.1)) ;
      if BZ.gap(k),
         ed = max(find(dcl<0.1))+2 ;
      else
         ed = st+min(find(dcl(st:end)>0.1)) ;
      end
      if isempty(ed) | ed>length(cl),
         ed = length(cl) ;
      end
      if st>2,
         M(k,11) = diff(cl(st+(-2:-1))) ;
      end
      if st>3,
         M(k,12) = mean(diff(cl(st+(-3:-1)))) ;
      end
      if st>4,
         M(k,13) = mean(diff(cl(st+(-4:-1)))) ;
      end
      cl = cl(st:ed-1) ;
      ici = diff(cl) ;
      M(k,1) = min(cl) ;
      M(k,2) = max(cl) ;
      M(k,4) = mean(ici) ;
      M(k,5) = min(ici) ;
      M(k,6) = length(cl) ;
      M(k,7) = mean(ici(6:25)) ;
      M(k,8:9) = cl([6 25])'-cl(1) ;
      M(k,10) = mean(cl([6 25])) ;
   end
end

BZ.start = M(:,1) ;
BZ.end = M(:,2) ;
BZ.meanici = M(:,4) ;
BZ.minici = M(:,5) ;
BZ.nclicks = M(:,6) ;
BZ.initialici = M(:,7) ;
BZ.click6_25 = M(:,8:9) ;
BZ.initialicitime = M(:,10) ;
BZ.duration = BZ.end-BZ.start ;
BZ.ngood = sum(BZ.gap==0) ;
BZ.prebzici = M(:,11) ;
BZ.prebz2ici = M(:,12) ;
BZ.prebz3ici = M(:,13) ;
