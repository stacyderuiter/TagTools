function ptrack3D

%Plots the 3D psuedotrack for a given record in a colormap cooresponding to
%depth. You must already have the prh file and set the correct tag and
%path for each record.  

%by Ann Allen, Woods Hole Oceanographic Inst., 2008

settagpath('audio','C:/Dtag/data','cal','C:/Dtag/data/cal', 'raw','C:/Dtag/data/raw','prh','C:/Dtag/data/prh','audit','C:/Dtag/data/audit');
tag='zc08_164a';
loadprh(tag,'p','fs','pitch','head','roll');

T=ptrack(pitch,head,-p,fs);  %Generates the psuedotrack coordinates.  

tx=T(:,2)/1000;
ty=T(:,1)/1000;
tz=T(:,3);

clf
plotwhale(tx,ty,tz)  
xlabel('Easting [km]');
ylabel('Northing [km]');
zlabel('Depth [m]');
title('zc08 164a');
zlim([0 1200]); %sets the limits of the z axis so that it starts at the surface
view([-85 28]);  %This sets the camera azimuth and elevation.

%Changes to the colorbar or any other plot features must be made in
%plotwhale.m