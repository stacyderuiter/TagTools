function    [B,BH,H] = d3readbin(fname,blk)
%
%    B=d3readbin(fname,blk)
%     Read data from a D3 bin file. bin files have
%     a header of 20 bytes containing:
%     byte 1-8    8-byte data source name
%     byte 9-12   number of blocks in the file
%     byte 13-16  sampling rate
%     byte 17-20  ?
%     Blocks of data follow the header. Each block has
%     a 20 byte block header containing:
%     byte 1-8    ?
%     byte 9-12   rtime (Unix seconds)
%     byte 13-16  mticks (microseconds)
%     byte 17-20  number of bytes in the block

BY2LN = 2.^[24 16 8 0]' ;

f = fopen(fname,'rb') ;

% read in the file header
h = fread(f,20,'uint8') ;
H.nblks = h(9:12)'*BY2LN ;
H.fs = h(13:16)'*BY2LN ;
H.s = h ;
if blk>H.nblks,
   fprintf('File only has %d blocks\n',H.nblks) ;
   return
end

% read in the block header
for k=1:blk,
   h = fread(f,20,'uint8') ;
   n = h(17:20)'*BY2LN ;
   x = fread(f,n*2,'uint8') ;
end

BH.n = n ;
BH.rtime = h(9:12)'*BY2LN ;
BH.mticks = h(13:16)'*BY2LN ;
%B = x(1:2:end)*256+x(2:2:end) ;
xx = dec2bin(x,8)>48 ; 
B = (xx(:,2:2:8)+j*xx(:,1:2:7)).' ;
B = B(:) ;
B = 2*B-(1+j) ;
fclose(f) ;

