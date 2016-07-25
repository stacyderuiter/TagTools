function    y = conv2eng(x,df,CAL,ch)
%
%    y = conv2eng(x,df,CAL,ch)
%     NOTE: This is an idea only - do not use!!!

ch = lower(ch) ;
if strcmp(ch,'press'),
   y = x{CAL.PCH} ;
   if df>1, y = decdc(y,df) ; end
   y = polyval(CAL.PCAL,y) ;   % nominal pressure scaling
end

if strcmp(ch,'tempr'),
   y = x{CAL.TCH} ;
   if df>1, y = decdc(y,df) ; end
   y = polyval(CAL.TCAL,y) ;      % temperature calibration
end

if strcmp(ch,'vb'),
   y = x{CAL.VCH} ;
   if df>1, y = decdc(y,df) ; end
   y = polyval(CAL.VCAL,y) ;      % temperature calibration
end

if strcmp(ch,'acc'),
   y = horzcat(x{CAL.ACH}) ;
   if df>1, y = decdc(y,df) ; end
   for k=1:size(y,2),
   	y(:,k) = polyval(CAL.ACAL(k,:),y(:,k)) ;
   end
end

if strcmp(ch,'mag'),
   y = horzcat(x{CAL.MCH}) ;
   if df>1, y = decdc(y,df) ; end
   for k=1:size(y,2),
   	y(:,k) = polyval(CAL.MCAL(k,:),y(:,k)) ;
   end
end
