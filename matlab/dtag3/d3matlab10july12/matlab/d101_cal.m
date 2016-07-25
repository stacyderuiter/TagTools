DEV = struct ;
DEV.ID='a303202b';
DEV.NAME='D101';
DEV.BUILT=[2011 7 1];
DEV.BUILDER='th';
DEV.HAS={'stereo audio'};

BBFILE = ['badblocks_' DEV.ID(1:4) '_' DEV.ID(5:8) '.txt'] ;
try,
   DEV.BADBLOCKS = readbadblocks(['/tag/projects/d3/private/badblocks/' BBFILE]) ;
catch
   fprintf(' No bad block file\n') ;
end

TEMPR = struct ;
TEMPR.TYPE='ntc thermistor';
TEMPR.USE='conv_ntc' ;
TEMPR.UNIT='degrees Celcius';
TEMPR.METHOD='none';

BATT = struct ;
BATT.POLY=[6 0] ;
BATT.UNIT='Volt';

PRESS=struct;
PRESS.POLY=[-19.21 3127.07 -102.62];
PRESS.METHOD='WHOI';
PRESS.LASTCAL=[2011 9 15];
PRESS.TREF = 20 ;
PRESS.UNIT='meters H20 salt';
PRESS.TC.POLY=[-0.0271 0];
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
ACC.POLY=[4.9549 -2.4596;4.9539 -2.5011;4.9967 -2.5315] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0;0;0];
ACC.TC.SRC='TEMPR';
ACC.PC=[0;0;0];
ACC.XC=zeros(3);
ACC.MAP=[1 0 0;0 -1 0;0 0 1];
ACC.MAPRULE='front-right-down';
ACC.METHOD='flips';
ACC.LASTCAL=[2012 7 5];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=672*[1 0.0062;1.0359 0.0032;1.0242 0.0151] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0];
MAG.TC.SRC='BRIDGE';
MAG.PC=[0;0;0];
MAG.XC=[0 0.0016 0.0297;0.0016 0 -0.0126;0.0297 -0.0126 0] ;
MAG.MAP=[0 1 0;1 0 0;0 0 -1];
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
% writematxml(DEV,'DEV','/tag/tag3/hardware/d101.xml')

