function    [sseq,sch,n,nbase] = make_sseq(fname,HEX,dev)
%    [sseq,sch,n,nbase] = make_sseq(fname,HEX,dev)
%     Generate a D3 tag sensor sequence from a CSV file
%     containing a sensor sequence plan. Use sensseq.csv 
%     as a template for the plan.
%
%     Channel select codes for dtag3 are:
%      'ecg1','ecg2','m','p','ax','ay','az','v','gx','gy','gz','gax',
%      'gay','gaz','gaux','gv'
%
%     MSEL and GSEL codes for dtag3 are:
%      'mb','pb+','therm','cal','mb-','pb-','ext1','ext2','gr1','gr2',
%      'gth1','gth2','m0','mx+','my+','mz+','m5','mx-','my-','mz-','p'
%
%     Channel select codes for ctag are:
%      'X0','p','pb+','therm','cal','pb-','X6','X7','gx','gy','gz','gax',
%      'gay','gaz','gaux','gv'
%
%     MSEL and GSEL codes for ctag are:
%      'gr1','gr2','gth1','gth2'
%
%     Available devices are 'dtag3' and 'ctag'.
%     Note: make sure that all ECOs are made on the circuit board and that
%     the correct defines are selected in the C code.
%
%     mark johnson
%     6 may 2012

if nargin<2 | isempty(HEX),
   HEX = 0 ;
end

if nargin<3 | isempty(dev),
   dev = 'dtag3' ;
end

[S,hdr]=readcsv(fname);
nb = stripquotes({S.next_brd}) ;
cw0 = abs(vertcat(S.mbon_gpwr))-'0' + (vertcat(nb{:})=='g') ;
n = length(cw0) ;
nbase = n/(length(nb)-n+1) ;
ch = stripquotes({S.ch_req}) ;
ch = strvcat(ch{:}) ;
msel = stripquotes({S.msel_gsel}) ;
msel = strvcat(msel{:}) ;

cw1 = zeros(n,1) ;
cw2 = cw1 ;

% convert strings to channel numbers using a lookup table
switch lower(dev)
   case 'dtag3'
      CHS = {'ecg1','ecg2','m','p','ax','ay','az','v','gx','gy','gz','gax','gay','gaz','gaux','gv'} ;
      CHN = 64*[0:7,0:7] ;
      SELS = {'mb','pb+','therm','cal','mb-','pb-','ext1','ext2','gr1','gr2','gth1','gth2',...
      'm0','mx+','my+','mz+','m5','mx-','my-','mz-','p'} ;
      SELN = [8*(0:7),16*(0:3),8*(0:7),8*7] ;
   case 'ctag'
      CHS = {'X0','p','pb+','therm','cal','pb-','X6','X7','gx','gy','gz','gax','gay','gaz','gaux','gv'} ;
      % channel codes for CTAG include the ECO change in SEL lines
      CHN = [[0 0 4 4 8 8 12 12]+256*rem(0:7,2) 64*(0:7)] ;
      SELS = {'0','gr1','gr2','gth1','gth2'} ;
      SELN = [0 16*(0:3)] ;
   otherwise
      fprintf('Unknown device %s - unable to convert sequence\n',dev) ;
      return
end

for k=1:n,
   v = strtok(ch(k,:)) ;
   kk = find(ismember(CHS,v)) ;
   if isempty(kk) | length(kk)>1,
      fprintf(' ambiguous channel name %s\n',v) ;
      continue
   end
   cw2(k) = CHN(kk(1)) ;
end

% convert msel/gsel strings to select numbers using a lookup table
for k=1:n,
   v = strtok(msel(k,:)) ;
   kk = find(ismember(SELS,v)) ;
   if isempty(kk) | length(kk)>1,
      fprintf(' ambiguous select name %s\n',v) ;
      continue
   end
   cw1(k) = SELN(kk(1)) ;
end

sseq = cw2+cw1+cw0 ;
sch = stripquotes({S.sensor_id}) ;
sch = strvcat(sch{:}) ;
sname = fname(1+find(ismember(fname,'/\'),1,'last'):find(fname=='.')-1) ;
fprintf('Sequence %s n=%d, nbase=%d\n\n',sname,n,nbase) ;
for k=1:nbase:n,
   if HEX,
      fprintf('0x%03x,',sseq(k+(0:nbase-1))) ;
   else
      fprintf('%d,',sseq(k+(0:nbase-1))) ;
   end
   fprintf('\n');
end

fprintf('\n');

for k=1:nbase:n,
   for kk=1:nbase,
      fprintf('%s,',strtok(sch(k+kk-1,:))) ;
   end
   fprintf('\n');
end
