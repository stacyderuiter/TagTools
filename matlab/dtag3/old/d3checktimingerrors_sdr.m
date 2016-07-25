function    V = d3checktimingerrors(recdir, prefix)
%
%    V = d3checktimingerrors(recdir)
%
%     Example: d3checktimingerrors('e:/by09/29oct')

[fn,dm,recn,recdir]=getrecfnames(recdir,prefix);
C = NaN*ones(length(dm),2) ;
for k = 1:length(dm),
   cc = getxmlcue([recdir fn{k}]) ;
   if isempty(cc), continue, end
   [ss,fs]=wavread16([recdir fn{k}],'size') ;
   C(k,:) = [cc(1) ss(1)/fs] ;
end

TE = [] ;
ids = unique(dm) ;
for k=1:length(ids),
   kk = find(dm==ids(k)) ;
   TE = [TE;[k*ones(length(kk)-1,1) kk(1:end-1) C(kk(2:end),1)-C(kk(1:end-1),1)-C(kk(1:end-1),2)]] ;
end

V = [ids(TE(:,1)) TE(:,3)*1000] ;
for k=1:size(TE,1),
   fprintf('D3 %08x: files %s to %s timing error %3.1f ms\n',V(k,1),fn{TE(k,2)},fn{TE(k,2)+1},V(k,2)) ;
end

