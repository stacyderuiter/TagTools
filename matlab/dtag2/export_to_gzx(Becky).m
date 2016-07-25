function export_to_gzx(tag,P)
% export_to_gzx(tag)
% tag - deployment name (e.g. 'pw04_297i')
%
% notes: currently Pi is added to all heading values so that animal is 
%   correctly headed in TrackPlot and GeoZui
%   Pitch is negated to fit GeoZui convention

% added by CEW
loadprh(tag);
loadcal(tag);
timeon = TAGON;
%xo = UTMLOC(1);
%yo = UTMLOC(2);
xo = 0;
yo = 0;
%ptrack = 1/fs*cumsum((cos(pitch)*[1 1]).*[cos(head+pi) sin(head+pi)]) ;
ptrack = P;

n = size(p);

startTime = (datenum(timeon(1),timeon(2),timeon(3),timeon(4)+4,timeon(5),timeon(6)) - datenum(1970,1,1,0,0,0))*24*3600;

fname=sprintf('%s.gzx',tag);
file1=fopen(fname,'w');

fprintf(file1,'<?xml version="1.0"?>\n');
fprintf(file1,'<GZ georef="%9f %9f %9f">\n',ptrack(1,2)+xo, ptrack(1,1)+yo, -p(1));
fprintf(file1,' <Object type="Vessel" label="%s" path="on">\n',tag);
fprintf(file1,'     <Object filename="../dxf/Humpback-whale.dxf"></Object>\n');

todeg = 360.0/(2*pi);

for i= 1:n(1)
    fprintf(file1,'     <Position position="%9f %9f %9f" time="%9f" orientation="%9f %9f %9f"></Position>\n', -(ptrack(i,2)+xo), -(ptrack(i,1)+yo),-p(i),startTime+i/5.0,roll(i)*todeg,-pitch(i)*todeg,(head(i))*todeg);
    %fprintf(file1,'     <Position position="%9f %9f %9f" time="%9f" orientation="%9f %9f %9f"></Position>\n', ptrack(i,2)+xo, ptrack(i,1)+yo,-p(i),startTime+i/5.0,roll(i)*todeg,-pitch(i)*todeg,(pi+head(i))*todeg);
end
fprintf(file1,' </Object>\n');
fprintf(file1,'</GZ>\n');
fclose('all');
