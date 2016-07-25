DEV = struct ;
DEV.ID='9D03220A';
DEV.NAME='D102';
DEV.BUILT=[2011 9 13];
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
PRESS.POLY=[59.7 2993.9 -78.5];
PRESS.METHOD='rough';
PRESS.LASTCAL=[2011 9 13];
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
ACC.POLY=[4.948 -2.451;4.972 -2.478;4.999 -2.549] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0; 0; 0]; % Added colons
ACC.PC.POLY=[0; 0; 0]; % Added colons
ACC.PC.SRC = 'PRESS';  % Added
ACC.XC=zeros(3);
ACC.MAP=[-1 0  0; 0 1 0; 0  0  1] ; % Correct
ACC.MAPRULE='front-right-down';
ACC.METHOD='flips';
ACC.LASTCAL=[2011 9 13];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[697.5 -220.1; 717.0 -252.3; 718.8 -226.1] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0]; % Correct
MAG.TC.SRC='BRIDGE';
MAG.PC.POLY=[0;0;0]; % Correct
MAG.PC.SRC='PRESS' ;
MAG.XC=zeros(3);
MAG.MAP=[ 0  1  0 ; 1  0  0 ; 0  0  1] ; % Correct
MAG.MAPRULE='front-right-down';
MAG.METHOD='';
MAG.LASTCAL=[];
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
writematxml(DEV,'DEV','d102.xml')

