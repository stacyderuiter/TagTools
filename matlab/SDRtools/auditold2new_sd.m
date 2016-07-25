function        R = auditold2new_sd(tag)

%       R = auditold2new(tag)
%
%

% work up audio filename
global TAG_PATHS

if ~isempty(TAG_PATHS) && isfield(TAG_PATHS,'AUDIT'),
   cpath = pwd ;
   cd(TAG_PATHS.AUDIT) ;
end

eval(sprintf('%saud',tag)) ;
if exist('cpath','var')
   cd(cpath) ;
end

R.cue = [] ; R.duration = [] ; R.stype = {} ;

if exist('CST','var'),
   n = size(CST,1) ;
   R.cue(end+(1:n)) = CST(:,1) ;
   R.duration(end+(1:n)) = CST(:,2) ;
   [R.stype{(end+(1:n))}] = deal(['buzz']) ;
   if size(CST,2)==3,
      k = find(CST(:,3)>0 & CST(:,3)<1000) ;
      n = length(k) ;
      if n>0,
         R.cue(end+(1:n)) = CST(k,1)+CST(k,2) ;
         R.duration(end+(1:n)) = CST(k,3) ;
         [R.stype{(end+(1:n))}] = deal(['pause']) ;
      end
   end
end

if exist('PSE','var'),
   PAUSES = PSE ;
end

if exist('PAUSES','var'),
   n = size(PAUSES,1) ;
   R.cue(end+(1:n)) = PAUSES(:,1) ;
   R.duration(end+(1:n)) = PAUSES(:,2) ;
   [R.stype{(end+(1:n))}] = deal(['pause']) ;
end
if exist('PAUSE','var'),
   n = size(PAUSE,1) ;
   R.cue(end+(1:n)) = PAUSE(:,1) ;
   R.duration(end+(1:n)) = PAUSE(:,2) ;
   [R.stype{(end+(1:n))}] = deal(['pause']) ;
end

if exist('RASP','var'),
   n = size(RASP,1) ;
   R.cue(end+(1:n)) = RASP(:,1) ;
   R.duration(end+(1:n)) = RASP(:,2) ;
   [R.stype{(end+(1:n))}] = deal('rsp') ;
   if size(RASP,2)==3,
      k = find(RASP(:,3)>0 & RASP(:,3)<1000) ;
      n = length(k) ;
      if n>0,
         R.cue(end+(1:n)) = RASP(k,1)+RASP(k,2) ;
         R.duration(end+(1:n)) = RASP(k,3) ;
         [R.stype{(end+(1:n))}] = deal('p') ;
      end
   end
end

if exist('CLICKING','var'),
   n = size(CLICKING,1) ;
   R.cue(end+(1:n)) = CLICKING(:,1) ;
   R.duration(end+(1:n)) = 0 ;
   [R.stype{(end+(1:n))}] = deal(['soc']) ;
   R.cue(end+(1:n)) = CLICKING(:,2) ;
   R.duration(end+(1:n)) = 0 ;
   [R.stype{(end+(1:n))}] = deal(['eoc']) ;
end

R.cue = [R.cue(:), R.duration(:)] ;

if nargout==0,
   saveaudit(tag,R) ;
end
