function    x = d3fio(fname,x,u)
%
%    x = d3fio(fname,x,u)
%     File-based data exchange with a JTAG-connected D3 device.
%     This function is an interface to the FIO module in the D3
%     API.
%     To create a data file to send to a D3 device, use:
%        d3fio(fname,x)
%     where fname is the filename (use the same name in the FIO
%     open call in the D3 code). x is the variable to send. The
%     number of columns in x should match the number of channels
%     in the FIO open call. The values in x should be between
%     -32768 and 32767 or 0 and 65536 if a value of 1 is given for
%     the optional 3rd argument.
%
%     To read a data file produced by FIO, use:
%        x = d3fio(fname,nch)
%     where nch is the number of channels in the FIO open call.
%     A third argument of 1 treats incoming data as unsigned.
%
%     mark johnson, 2010

if nargin>=2 && length(x)>1,
   f = fopen(fname,'wb') ;
   x = floor(x) ;
   if nargin==3 & u==1,
      fwrite(f,x','ushort') ;
   else
      fwrite(f,x','short') ;
   end
else
   if nargin>=2 && length(x)==1,
      nch = x ;
   else
      nch = 1 ;
   end
   f = fopen(fname,'rb') ;
   if nargin==3 & u==1,
      x = fread(f,Inf,'ushort')' ;
   else
      x = fread(f,Inf,'short')' ;
   end
   ns = floor(length(x)/nch) ;
   x = reshape(x(1:nch*ns),nch,ns)' ;
end

fclose(f) ;
