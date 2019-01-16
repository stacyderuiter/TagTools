function    [y,fs] = show_specgram(t,fmax)

%     show_specgram(t)
%		or
%     show_specgram(t,fmax)
%		or
%     [y,fs] = show_specgram(t,fmax)
%
%		Record sound from the computer audio input device and display
%		the waveform, spectrum, and spectrogram. Optionally, return the
%		recorded sound so you can process or plot it in other ways.
%
%		Inputs:
%		t is the amount of time to record in seconds.
%		fmax is an optional upper frequency limit for the spectrum and
%		  spectrogram display. If fmax is not give, the full spectrum is
%	     shown (i.e., up to the Nyquist frequency).
%
%		Outputs:
%		If required, the recorded audio and its sampling rate can be returned.
%		y is a vector of the sound recording.
%		fs is the sampling rate in Hz.
%
%		GNU Public License: you are free to use, share and modify this code.
%		markjohnson@st-andrews.ac.uk
%		last modified: 3 Feb 2018

fs = 32e3 ;				% sampling rate to use in Hz. This should be one supported by
							% your PC e.g., 32, 44.1, 48 or 96 kHz
if nargin<2,			% fmax is the upper frequency to show in the spectral plot
   fmax=fs/2;			% default is fs/2, i.e., the Nyquist frequency
end
fmax = min(fmax,fs/2);

t = max(min(t,20),0) ;		% make sure t is a reasonable number (0..20 seconds)

% make blank axes for the three plots
figure(1),clf
ax1=axes('Position',[0.1 0.3 0.6 0.6]);
set(gca,'FontSize',14,'LineWidth',1.5)
axis([0 t 0 fmax])
box on
ylabel('Frequency (Hz)')
ax2=axes('Position',[0.1 0.1 0.6 0.15]);
set(gca,'FontSize',14,'LineWidth',1.5)
xlabel('Time (seconds)')
axis([0 t -1 1])
box on
ax3=axes('Position',[0.75 0.3 0.15 0.6]);
set(gca,'FontSize',14,'LineWidth',1.5,'YAxisLocation','right','XDir','reverse')
axis([0 30 0 fmax])
box on
ylabel('Frequency (Hz)')
xlabel('Level (dB)')

% initialize the audio input device
REC = audiorecorder(fs,16,1) ;

disp('Click on the plot whenever you are ready to record some sound.')
disp('Press q to exit.')

while(1)							% do the loop until a break instruction
   [clickx,clicky,but]=ginput(1);	% wait for a click on the plot
   if but == 'q',							% if a q, exit from the loop
      break
   end
   recordblocking(REC,t+0.3);			% request t+0.3 seconds of audio
   y = getaudiodata(REC,'double');	% actually read the data
	
   axes(ax2)								% update the plots with the new data
   h1=plot((0:length(y)-1)/fs-0.1,y);grid
   axis([0 t 1.2*max(abs(y))*[-1 1]])
   set(h1,'LineWidth',1.5)
   xlabel('Time (seconds)')
   [S,f]=spectrum_level(y,2048,fs,2048,1024);
   axes(ax3)
   k=find(f<fmax);
   h2=plot(S,f);grid,axis([min(S(k))-5 max(S(k))+5 0 fmax])
   set(gca,'YAxisLocation','right','XDir','reverse')
   ylabel('Frequency (Hz)')
   xlabel('Level (dB)')
   set(h2,'LineWidth',1.5)
   axes(ax1)
   [S,f,T,P] = spectrogram(y,2048,2048-256,2048,fs,'yaxis');
   P=10*log10(abs(P));
   imagesc(T-0.1,f,P);
   axis xy;
   caxis(max(max(P))+[-60 0])
   axis([0 t 0 fmax])
   ylabel('Frequency (Hz)')
end

if nargout == 0,
	y = [] ;
end
