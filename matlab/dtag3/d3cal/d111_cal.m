DEV = struct ;
DEV.ID=upper('5D031F02'); %Needs to be upper case
DEV.NAME='D111';
DEV.BUILT=[2012 5 1];
DEV.BUILDER='TH';
DEV.HAS={'stereo audio'};
BBFILE = ['badblocks_' DEV.ID(1:4) '_' DEV.ID(5:8) '.txt'] ;
% The next loop changed
DEV.BADBLOCKS = readbadblocks(['c:/tag/d3/host/d3usb/' BBFILE]) ;
if isempty(DEV.BADBLOCKS)
   fprintf(' No bad block file\n') ;
end

TEMPR = struct ;
TEMPR.TYPE='ntc thermistor';
TEMPR.USE='conv_ntc';
TEMPR.UNIT='degrees Celcius';
TEMPR.METHOD='none';

BATT = struct ;
BATT.POLY=[6 0] ;
BATT.UNIT='Volt';

PRESS=struct;
PRESS.POLY=[-27.01 3268.02 -111.38];
PRESS.METHOD='rough';
PRESS.LASTCAL=[2012 5 3];
PRESS.TREF = 20 ;
PRESS.UNIT='meters H20 salt';
PRESS.TC.POLY=[0];
PRESS.TC.SRC='BRIDGE';
PRESS.BRIDGE.NEG.POLY=[3 0];
PRESS.BRIDGE.NEG.UNIT='Volt';
PRESS.BRIDGE.POS.POLY=[6 0];
PRESS.BRIDGE.POS.UNIT='Volt';
PRESS.BRIDGE.RSENSE=200;
PRESS.BRIDGE.TEMPR.POLY=[314.0 -634.7] ;
PRESS.BRIDGE.TEMPR.UNIT='degrees Celcius';

ACC=struct;
ACC.TYPE='MEMS accelerometer';
ACC.POLY=[4.945 2.423; 4.896 -2.483; 4.934 -2.461] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0; 0; 0]; % Added colons
ACC.PC.POLY=[0; 0; 0]; % Added colons
ACC.PC.SRC = 'PRESS';  % Added
ACC.XC=zeros(3);
ACC.MAP=[-1 0 0;0 1 0;0 0 1]; % Corrected
ACC.MAPRULE='front-right-down';
ACC.METHOD='flips';
ACC.LASTCAL=[2012 5 3];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[680.232 -230.513; 695.433 -186.217; 736.583 -227.405] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0];
MAG.TC.SRC='BRIDGE';
MAG.PC.POLY=[0;0;0]; % Added .poly
MAG.PC.SRC = 'PRESS'; % Added
MAG.XC=zeros(3);
MAG.MAP=[0 1 0;1 0 0;0 0 1]; % Corrected
MAG.MAPRULE='front-right-down';
MAG.METHOD='';
MAG.LASTCAL=[2012 5 3];
MAG.BRIDGE.NEG.POLY=[3 0];
MAG.BRIDGE.NEG.UNIT='Volt';
MAG.BRIDGE.POS.POLY=[6 0];
MAG.BRIDGE.POS.UNIT='Volt';
MAG.BRIDGE.RSENSE=20;
MAG.BRIDGE.TEMPR.POLY=[541.91 -459.24] ;
MAG.BRIDGE.TEMPR.UNIT='degrees Celcius';

CAL=struct ;
CAL.TEMPR=TEMPR;
CAL.BATT=BATT;
CAL.PRESS=PRESS;
CAL.ACC=ACC;
CAL.MAG=MAG;

DEV.CAL = CAL ;
writematxml(DEV,'DEV','d111.xml')

