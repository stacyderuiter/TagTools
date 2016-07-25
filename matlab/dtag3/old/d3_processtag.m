%matlab commands for initial analysis of a dtag3 dataset - making a prh file.

%**************************************************************************
%START tagout-specific info (change this as needed for each new tag)
%**************************************************************************
tag = 'zc11_267a'; %enter the tag ID string
tagcal = dt3_105; %calibration info for the tag used for this deployment
hours = -7; %offset between GMT and local time. GMT + hours = local time at experiment site
decl = 12+40/60; %local declination angle - in degrees. 4.8 is approx for Sarasota. 
%you can get precise decl info from NOAA: http://www.ngdc.noaa.gov/geomagmodels/Declination.jsp
mindive = 500; %for prhpredictor -- tells it to use dives > mindive m to calibrate prh.
% %enter path to data directory
% path = 'E:\SoCal11\dtag\data';
% %enter tag on time - [year month day hour minute second] NOW IN UTC TIME!!!
tagontime = [2011 9 24 15.00 49.00 56.00]; %UTC for tag3
%enter the tag on position [lat, lon] in decimal degrees (use +/- for E/W and N/S)
position = [33+30.63/60,-(119+16.83/60)]; %
% tag = 'gg11_266a';
% tagcal = dt3_106;
% hours = -7;
% decl = 12.6652;
% mindive = 100;
% path = 'E:\SoCal11\dtag\data'; 
% tagontime = [2011 9 24 14 49 42];
% position = [33.5167	-119.2404];
% tag = 'gg11_269a';
% tagcal = dt3_106;
% hours = -7;
% mindive = 200;
% tagontime = [2011 9 26 18 30 56]; %this is UTC
% position = [33+34.31/60 -(118+27.08/60)];
% decl = 12.52;
%**************************************************************************
%END tagout-specific info 
%**************************************************************************


%1. set the path so that scripts can locate dtag related data files.
%----------------------------------------------------------
settagpath('audio',path,'cal',[path '\cal'], 'raw',[path '\raw'],'prh',[path '\prh']);


%2. Make the raw decimated sensor data file:
%------------------------------------------------
[s,fs] = d3makeraw_xy(tag, 1) ; % read the .swv files and save a raw file
%use d3makeraw(tag,0) if you don't want to save the raw file
%NOTE!!!!!!!!! in the current version of makeraw, the d3 data are imported
%into a raw file with the OLD DTAG2 coordinate system (x-y compass axes
%switched wrt the real, new tag3 standard).

%3. Apply calibrations and make the tag frame prh file:
%---------------------------------------------------------
%[s,fs] = loadraw(tag) ; % if workspace was cleared after step 5
CAL = tagcal ; % run the calibration for the dtag used (rough cal using calibration constants)

%************************************************************************
%the following is to account for the switch of x-y compass axes between
%dtag2 and d3.  the d3 cal file uses the d3 axis system.  In this case we
%want the data to be in the old dtag2 coordinate system.
%************************************************************************
mcal = [CAL.MCAL(2,:);CAL.MCAL(1,:); -CAL.MCAL(3,:)];
CAL.MCAL = mcal;
mmbc = [CAL.MMBC(2),CAL.MMBC(1), -CAL.MMBC(3)];
CAL.MMBC = mmbc;
mpc = [CAL.MPC(2),CAL.MPC(1), -CAL.MPC(3)];
CAL.MPC = mpc;
%*************************************************************************
%end of the axis business
%*************************************************************************

%NOTE: This calibration is rough & incomplete (as of 7/11).  
%It will be improved with time as the
%new tag3 sensors are properly calibrated in the lab, and as new
%autocalibration scripts are developed for the new sensors.

%Add location dependent information to the cal file:
%------------------------------------------------------
savecal(tag,'GMT2LOC',hours) ; % add the GMT time offset to the cal file
%You will be prompted to enter the tagon time as a 6 element vector of:
%[year month day hour minute second], as well as your initials
savecal(tag,'TAGLOC',position) ; % add the tag-on position to the cal file
savecal(tag,'DECL',decl) ; % add the local magnetic field declination


[p,tempr,CAL] = d3calpressure(s,CAL,'full');
%NOTE:  these routines may need to be tweaked for d3 datasets.
[M,CAL] = autocalmag_sd(s,CAL) ; % accept or reject test results 
[A,CAL] = autocalacc_sd(s,p,tempr,CAL) ; % accept or reject test results


savecal(tag,'CAL',CAL) % save calibration results
saveprh(tag,'p','tempr','fs','A','M') % save tag frame results

%note:  accelerometer and magnetometer calibration for dtag 3 remains to be
%worked out, as of Nov 2011

%4. Determine the tag orientations on the whale:
%----------------------------------------------------------------
%loadprh(tag) % if workspace was cleared
T = prhpredictor(p,A,fs,mindive,2) ; % estimate tag orientations
% where mindive is an optional argument restricting attention to the edges of dives deeper
% than mindive. If you want to focus attention on deep dives (which tend to provide the best
% tag orientation estimates), use a value for mindive that is just lower than the shallowest
% dive you want to analyse. 
% Use method 2 in prhpredictor if the % animal actively swims at the surface.
% If the animal predominantly logs at the surface, use method 1.
% at each dive edge analyzed, look for COND and RMS values <0.05.  Also,
% unless you suspect the tag has moved, look for p, r, h values that are
% relatively constant (=consistent over time).

%5. Produce the orientation table. 
%--------------------------------------------------------------------------
% By examining the prhpredictor results, decide on the
% orientation(s) of the tag and whether it slides during the deployment. If you suspect that
% the tag moves during a dive, plot the A matrix (or it's 2-norm norm2(A)) to see if there is
% any indication of an impact or rub consistent with a sudden move. Using the tag
% orientation worksheet, construct the orientation table:
OTAB = [move1;move2;move3...]
% where each row corresponds to a move of the tag and has the form:
% moveN = [t1,t2,p0,r0,h0]
% where t1 and t2 are the start and end times of the move (in seconds-since-tagon), and p0,
% r0, h0 are the new orientation angles after the move (in radians). If the move is
% instantaneous, use t2=t1. If you are not sure if there was a move or you simply want to
% notify a time at which the tag was at a certain orientation, use t2=0. If the move time is
% uncertain, note this on the orientation worksheet.

%Test the OTAB by creating the whale frame acceleration signals:
[Aw Mw] = tag2whale(A,M,OTAB,fs) ;
% Inspect Aw graphically or using prhpredictor to assure that all moves are handled
% correctly. 
% if you run plot(Aw)
% BLUE  = pitch
% GREEN = roll
% RED   = heading
% if orientation is correct...
% heading (red trace) should vary around 1, while pitch and roll (blue and green traces) should vary around 0.
% When you are done, save the OTAB to the cal file using:
savecal(tag,'OTAB',OTAB) % save orientation table


%6. Produce the prh file:
%--------------------------------------------------------------------------
d3makeprhfile(tag)
% This function implements the full calibration from raw to tag- and whale-frame taking
% values from the cal file. 

%##########################################################################
%  Useful Notes:
%##########################################################################
% p depth vector. Unit is meters of H2O (salt).
% tempr temperature vector. Unit is degrees Celsius
% A tag frame accelerometer matrix (nx3). Unit is g=9.81ms-2.
% M tag frame magnetometer matrix (nx3). Unit is micro Tesla.
% fs sampling rate of all derived sensor time series. Unit is Hz.
% Aw whale frame accelerometer matrix (nx3). Unit is g=9.81ms-2.
% Mw whale frame magnetometer matrix (nx3). Unit is micro Tesla.
% pitch whale frame pitch angle. Unit is radians.
% roll whale frame roll angle. Unit is radians.
% head whale frame heading angle. Unit is radians True (i.e., a heading
% of 0 implies that the whale is pointing to true north, not magnetic north).

%if you are getting error messages, make sure you have correctly set the
%tag path - if it seems correct and still gives an error try reversing the
%slashes (e.g. \ to / ).