function    [Mi,Md,fs] = interpmag(M,mfs)
%
%    [M,Md,fs] = interpmag(M,mfs)
%     Process D3 magnetometer data to produce a 2xfs
%     matrix and a dc offset vector.
%
%     mark johnson
%     26 june 2010

df = 16 ; %why is this 16?
fc = 0.1 ; %cutoff for lowpass filter used during determination of dcoffset
Moffs = decdc(sum(M,2),df)/6 ; %/6 because there are 6 input channels being summed, then decimated.  why decimated by factor of 16 though?
[b,a] = butter(4,fc/(mfs/2/df)) ; %lowpass filter coeffs
Mf = filtfilt(b,a,Moffs) ; %lowpass filter the decimated, summed +/- mag data
Md = reshape(repmat(Mf',df,1),[],1) ; % de-decimate the data, but now lp filtered
if size(Md,1)<size(M,1),
   Md(end+(1:size(M,1)-size(Md,1))) = Md(end) ; %fill in the last entries of if Md has a few less than M (rounding error)
end
Z = repmat(Md,1,6) ; % make a version of the DC offset vector w/6 identical columns (to subtr from orig data)
M = M-Z ; %subtr dc offset from mag data
Mi = zeros(size(M,1)*2,3) ; %preallocate space
Mi(:,1) = reshape([M(:,1) -M(:,4)]',[],1) ; %these 3 lines intersperse dc-offset-subtracted, all-positive-signified + and - mag data points
Mi(:,2) = reshape([M(:,2) -M(:,5)]',[],1) ;
Mi(:,3) = reshape([M(:,3) -M(:,6)]',[],1) ;
fs = [2*mfs mfs/df] ;  %since there is a + and a - data point for each timepoint we are saying that fs = double the original fs for the combined data in Mi.  Md was decimated by a factor of df (=16) so has a sampling rate of mfs/df, in a way, but I don't know...it seems like it gets repmatted up to being the same size/fs as M again, but just with a lp filter on it. ??? 

