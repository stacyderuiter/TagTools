DEV = struct ;
DEV.ID=upper('2903082c'); % Needs upper case
DEV.NAME='D135';
DEV.BUILT=[2013 7 30];
DEV.BUILDER='SF';
DEV.HAS={'stereo audio'};
BBFILE = ['badblocks_' DEV.ID(1:4) '_' DEV.ID(5:8) '.txt'] ;
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
PRESS.POLY=[-148.7 3022.5 -125.4];
PRESS.METHOD='rough';
PRESS.LASTCAL=[2013 7 30];
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
ACC.POLY=[5.014 -2.464; 4.980 -2.507; 4.963 -2.463] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0; 0; 0];
ACC.PC.POLY=[0; 0; 0];
ACC.XC=zeros(3);
ACC.MAP=[1 0 0;0 1 0;0 0 1];
ACC.MAPRULE='front-right-down';
ACC.METHOD='flips';
ACC.LASTCAL=[2013 7 30];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[648.087 -217.474; 652.979 -233.818; 683.986 -235.187] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0];
MAG.TC.SRC='BRIDGE';
MAG.PC.POLY=[0;0;0];
MAG.XC=zeros(3);
MAG.MAP=[0 1 0;1 0 0;0 0 1];
MAG.MAPRULE='front-right-down';
MAG.METHOD='';
MAG.LASTCAL=[2013 7 30];
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
writematxml(DEV,'DEV','d135.xml')

