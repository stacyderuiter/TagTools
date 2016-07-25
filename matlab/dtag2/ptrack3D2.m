function ptrack3D2(tag)

%Plots the 3D psuedotrack for a given record in a colormap cooresponding to
%depth. You must already have the prh file and set the correct tag and
%path for each record.  
%tag is the tag id string, e.g. 'gm08_266a'

%by Ann Allen, Woods Hole Oceanographic Inst., 2008
%teensy modification by stacy deruiter, sept. 2008

loadprh(tag,'p','fs','pitch','head','roll');

T=ptrack(pitch,head,-p,fs);  %Generates the psuedotrack coordinates.  

tx=T(:,1)/1000;
ty=T(:,2)/1000;
tz=T(:,3);

clf
plotwhale(tx,ty,tz)  
xlabel('Easting [km]');
ylabel('Northing [km]');
zlabel('Depth [m]');
title([tag(1:4) ' ' tag(6:9)]);
zlim([0 max(p)+0.2*max(p)]); %sets the limits of the z axis so that it starts at the surface
%view([-70 15]);  %This sets the camera azimuth and elevation.

%Changes to the colorbar or any other plot features must be made in
%plotwhale.m