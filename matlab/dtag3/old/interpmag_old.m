function    [Mi,Md,fs] = interpmag(M,mfs)
%
%    [M,Md,fs] = interpmag(M,mfs)
%     Process D3 magnetometer data to produce a 2xfs
%     matrix and a dc offset vector.
%
%     mark johnson
%     26 june 2010

df = 16 ;
fc = 0.1 ;
Moffs = decdc(sum(M,2),df)/6 ;
[b,a] = butter(4,fc/(mfs/2/df)) ;
Mf = filtfilt(b,a,Moffs) ;
Md = reshape(repmat(Mf',df,1),[],1) ;
if size(Md,1)<size(M,1),
   Md(end+(1:size(M,1)-size(Md,1))) = Md(end) ;
end
Z = repmat(Md,1,6) ;
M = M-Z ;
Mi = zeros(size(M,1)*2,3) ;
Mi(:,1) = reshape([M(:,1) -M(:,4)]',[],1) ;
Mi(:,2) = reshape([M(:,2) -M(:,5)]',[],1) ;
Mi(:,3) = reshape([M(:,3) -M(:,6)]',[],1) ;
fs = [2*mfs mfs/df] ;
