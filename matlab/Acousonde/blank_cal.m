DEV = struct ;
DEV.ID='acousonde';
DEV.NAME='D000';
DEV.BUILT=[0000 1 1];
DEV.BUILDER='XX';
DEV.HAS={'stereo audio'};
%fprintf(' No bad block file\n') ;


TEMPR = struct ;
TEMPR.TYPE='acousonde thermistor';
TEMPR.USE='conv_ntc';
TEMPR.UNIT='degrees Celsius';
TEMPR.METHOD='none';

BATT = struct ;
BATT.POLY=[1 0] ;
BATT.UNIT='Volt';

PRESS=struct;
PRESS.POLY=[0 1 0];
PRESS.METHOD='none';
PRESS.LASTCAL=[0 1 1];
PRESS.TREF = 20 ;
PRESS.UNIT='meters H20 salt';
PRESS.TC.POLY=[0];
PRESS.TC.SRC='BRIDGE';
PRESS.BRIDGE.NEG.POLY=[0];
PRESS.BRIDGE.NEG.UNIT='Volt';
PRESS.BRIDGE.POS.POLY=[0];
PRESS.BRIDGE.POS.UNIT='Volt';
PRESS.BRIDGE.RSENSE=200;
PRESS.BRIDGE.TEMPR.POLY=[0 0] ;
PRESS.BRIDGE.TEMPR.UNIT='degrees Celsius';

ACC=struct;
ACC.TYPE='MEMS accelerometer';
ACC.POLY=[1 0;1 0;1 0] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0; 0; 0]; % Added colons
ACC.PC.POLY=[0; 0; 0]; % Added colons
ACC.PC.SRC = 'PRESS';  % Added
ACC.XC=zeros(3);
ACC.MAP=[1 0 0; 0 1 0; 0  0  -1] ; % acousonde data comes in NED (rigth handed) orientation but dtag tools want it to be NEU (left handed)
ACC.MAPRULE='front-right-down'; %this means nothing for acousonde. I think for dtags it means "the sensor itself is in NED orientation"
ACC.METHOD='flips';
ACC.LASTCAL=[0 1 1];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[1 0; 1 0; 1 0] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0]; % Correct
MAG.TC.SRC='BRIDGE';
MAG.PC.POLY=[0;0;0]; % Correct
MAG.PC.SRC='PRESS' ;
MAG.XC=zeros(3);
MAG.MAP=[1 0 0; 0 1 0; 0  0  -1] ; % acousonde data comes in NED (rigth handed) orientation but dtag tools want it to be NEU (left handed)
MAG.MAPRULE='front-right-down'; %this means nothing for acousonde. I think for dtags it means "the sensor itself is in NED orientation"
MAG.METHOD='';
MAG.LASTCAL=[];
MAG.BRIDGE.NEG.POLY=[0];
MAG.BRIDGE.NEG.UNIT='Volt';
MAG.BRIDGE.POS.POLY=[0];
MAG.BRIDGE.POS.UNIT='Volt';
MAG.BRIDGE.RSENSE=20;
MAG.BRIDGE.TEMPR.POLY=[1 0] ;
MAG.BRIDGE.TEMPR.UNIT='degrees Celsius';

CAL=struct ;
CAL.TEMPR=TEMPR;
CAL.BATT=BATT;
CAL.PRESS=PRESS;
CAL.ACC=ACC;
CAL.MAG=MAG;

DEV.CAL = CAL ;
%writematxml(DEV,'DEV','acousonde_blank_cal.xml')

