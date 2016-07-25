function    [B,BH,H] = d3readbin(fname,blk)
%
%    [B,BH,H]=d3readbin(fname,blk)
%     Read data from a D3 bin file.
%     fname is the full path and filename of the file to read
%     blk is the block number to read or 
%     blk = [start_block, number_of_blocks] or
%     blk = [] to read all blocks.
%
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
%     byte 5-8    block number (first block is 0)
%     byte 9-12   rtime (Unix seconds)
%     byte 13-16  mticks (microseconds)
%     byte 17-20  number of 16-bit words in the block

B = [] ; BH = [] ; H = [] ;
if nargin<1,
   help d3readbin
   return
end

BY2LN = 2.^[24 16 8 0]' ;

f = fopen(fname,'rb') ;

% read in the file header
h = fread(f,28,'uint8') ;
H.nblks = h(9:12)'*BY2LN ;
H.fs = h(17:20)'*BY2LN ;
H.nbits = h(21:24)'*BY2LN ;
H.nchs = h(25:28)'*BY2LN ;
H.s = h ;
if nargin<2,
   B = H ;
   return
end

if isempty(blk),
   blk = [1 H.nblks] ;
end

if any(blk<=0) | sum(blk)>H.nblks+1,
   fprintf('Block number(s) must be between 1 and %d\n',H.nblks) ;
   return
end

if length(blk)==1,
   blk(2) = 1 ;
end

% skip the blocks up to the first requested one
for k=1:blk(1)-1,
   h = fread(f,20,'uint8') ;
   n = h(17:20)'*BY2LN ;
   x = fread(f,n,'uint16') ;
end

for k=1:blk(2),
   h = fread(f,20,'uint8') ;
   n = h(17:20)'*BY2LN ;
   x = fread(f,n*2,'uint8') ;
   BH(k).n = n/H.nchs ;
   BH(k).rtime = h(9:12)'*BY2LN ;
   BH(k).mticks = h(13:16)'*BY2LN ;
   B{k} = reshape(x(1:2:end)*256+x(2:2:end),H.nchs,[])' ;
end

fclose(f) ;
if blk(2)==1,
   B = B{1} ;
end

