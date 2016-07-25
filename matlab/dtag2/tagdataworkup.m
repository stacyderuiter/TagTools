function    tag = tagdataworkup(pathonly);
%ENTER THE FOLLOWING DATA FOR THE DEPLOYMENT DESIRED
%enter deployment to be worked
%tag = 'bt07_283a';
tag = 'mn06_197a';
%enter path to data directory, including data
path = 'd:\tag\data';
%enter tag on time
tagontime = [2006 7 16 18 04 11];
%enter the GMT offset
hours = -5;
%enter the tag on position
position = [42.2513 70.3034];
%enter local declination anglequit
decl = -15;  %Stellwagon bank
%decl = -7.1; %AUTEC Bahamas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1
    pathonly = 0;
end

settagpath('audio',path,'cal',[path '\cal'], 'raw',[path '\raw'],'prh',[path '\prh']);

if pathonly == 1
    return
end

[N,chips] = makecuetab(tag);
input('\n Log makecuetab data then hit enter to continue'); 
savecal(tag,'CUETAB',N);
savecal(tag,'CHIPS',chips);
savecal(tag,'TAGON',tagontime);
savecal(tag,'GMT2LOC',hours);
savecal(tag,'TAGLOC',position);
savecal(tag,'DECL',decl*pi/180);
[s,fs] = swvread(tag);
saveraw(tag,s,fs)

'done!'

%%% To generate prh follow below %%%%%%%%%%%%%%

%calibrate tag
%  [s,fs] = loadraw(tag);
%  CAL = tagXXX
%  [p,tempr,CAL] = calpressure(s,CAL,'full');
%  [M,CAL] = autocalmag(s,CAL);
%  [A,CAL] = autocalacc(s,p,tempr,CAL);

%when good with results
%  savecal(tag,'CAL',CAL)
%  saveprh(tag,'p','tempr','fs','A','M')

%tag orientations
%  loadprh(tag)
%  T = prhpredictor(p,A,fs,mindive);
%  OTAB = []; (watch radians vs degrees)
%    leave OTAB in radians to run tag2whale
%    use prhpredictor indeces in OTAB
%        1000     0   p  r  h  ; to initialize prh
%        5000  5000   p  r  h  ; instant move
%        7000  9500   p  r  h  ; slide
%when happy (have OTAB values)
%  [Aw,Mw] = tag2whale(A,M,OTAB,fs);
%       must be run with radians
%  savecal(tag,'OTAB',OTAB)
%  makeprhfile(tag)


%P = ptrack(pitch(k),head(k),p(k),fs);              generate the track of this dive
%plot3(P(:,2),P(:,1),P(:,3)),grid                   3D plot of the track
%clf,colline3(P(:,2),P(:,1),P(:,3),P(:,3)),grid;    nicer colour plot of the track
%set(gca,'ZDir','reverse')                          reverse the z-axis for a dive-profile look

%try colouring by abs(roll) instead
%clf,colline3(P(:,2),P(:,1),P(:,3),abs(roll(k))*180/pi),grid,colorbar;
