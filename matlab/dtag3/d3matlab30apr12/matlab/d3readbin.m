function    [B,BH,H] = d3readbin(fname,blk)
%
%    B=d3readbin(fname,blk)
%     Read data from a D3 bin file. 
%     BIN files have a header of 28 bytes containing:
%     byte 1-8    8-byte data source name
%     byte 9-12   number of blocks in the file
%     byte 13-16  configuration number
%     byte 17-20  sampling rate in Hz
%     byte 21-24  number of bits per word
%     byte 25-28  number of channels per sample
%
%     Blocks of data follow the header. Each block has
%     a 20 byte block header containing:
%     byte 1-4    4-byte flag ("blck")
%     byte 5-8   block number (first block is 0)
%     byte 9-12   rtime (Unix seconds)
%     byte 13-16  mticks (microseconds)
%     byte 17-20  number of bytes in the block

BY2LN = 2.^[24 16 8 0]' ;

f = fopen(fname,'rb') ;

% read in the file header
h = fread(f,28,'uint8') ;
H.nblks = h(9:12)'*BY2LN ;
H.fs = h(17:20)'*BY2LN ;
H.nbits = h(21:24)'*BY2LN ;
H.s = h ;
if isempty(blk) | any(blk<=0),
   fprintf('block number must be greater than 0\n') ;
   return
end
if any(blk>H.nblks),
   fprintf('File only has %d blocks\n',H.nblks) ;
   return
end

% read in the block header
for k=1:blk(1),
   h = fread(f,20,'uint8') ;
   n = h(17:20)'*BY2LN ;
   x = fread(f,n,'uint8') ;
end

if length(blk)==1,
   BH.n = n ;
   BH.rtime = h(9:12)'*BY2LN ;
   BH.mticks = h(13:16)'*BY2LN ;
   B = x(1:2:end)*256+x(2:2:end) ;
else
   for k=1:blk(2),
      BH(k).n = n ;
      BH(k).rtime = h(9:12)'*BY2LN ;
      BH(k).mticks = h(13:16)'*BY2LN ;
      B{k} = x(1:2:end)*256+x(2:2:end) ;
      h = fread(f,20,'uint8') ;
      n = h(17:20)'*BY2LN ;
      x = fread(f,n,'uint8') ;
   end
end

fclose(f) ;
