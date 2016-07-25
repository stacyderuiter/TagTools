function    [RL,f,RTI] = d3psd(x,fs,nfft,gain,device)
%
%    [RL,f,RTI] = d3psd(x,fs,nfft,gain,device)
%     RL is in dB re uPa/root-Hz
%     RTI is in nV/sqrt-Hz

[SL,f]=speclev(x,nfft,fs) ;

% SL is in dB re U/root-Hz where U is 1.0 in Matlab
% convert U to V using the gain of the audio chain and ADC
% preamp gain = 10x
% pga gain = 1.4x or 5.5x
% driver gain = 1.26x
% differential driver = 2x
% adc sensitivity = 1/3    (3V peak in gives 1 U in matlab)

if strcmp(device,'DMON'),     % for DMON
   if gain,
      g = 5.5 ;
   else
      g = 1.4 ;
   end
   VtoU = 10*g*1.26*2/3 ;     % total gain of 21.4 / 33.3 dB
else                          % for DTAG-3
   if gain,
      g = 7.3 ;
   else
      g = 1.8 ;
   end
   VtoU = 7.7*g*1.26*2/3 ;    % total gain of 21.3 / 33.5 dB
end

% RTI is now in dB re V/root-Hz at the preamp input
RTI = SL - 20*log10(VtoU) ;

% convert to pressure using the nominal sensitivity of the hydrophone.
% for a cylindrical phone it is about -203 dB re V/uPa

sens = -203 ;
RL = RTI-sens ;

% RL is now in dB re uPa/root-Hz at the hydrophone input
