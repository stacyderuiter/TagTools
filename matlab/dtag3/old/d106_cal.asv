DEV = struct ;
DEV.ID='00000000';
DEV.NAME='D106';
DEV.BUILT=[];
DEV.BUILDER='';
DEV.HAS={'stereo audio'};

BBFILE = ['badblocks_' DEV.ID(1:4) '_' DEV.ID(5:8) '.txt'] ;
try,
   DEV.BADBLOCKS = readbadblocks(['/tag/projects/d3/private/badblocks/' BBFILE]) ;
catch
   fprintf(' No bad block file\n') ;
end

TEMPR = struct ;
TEMPR.POLY =[-90 53] ;  
TEMPR.TYPE='ntc thermistor';
TEMPR.USE='conv_ntc' ;
TEMPR.UNIT='degrees Celcius';
TEMPR.METHOD='none';

BATT = struct ;
BATT.POLY=[6 0] ;
BATT.UNIT='Volt';

PRESS=struct;
PRESS.POLY=[45.33 3347.99 -127.64] ;
PRESS.METHOD='WHOI';
PRESS.LASTCAL=[2011 10 8];
PRESS.TREF = 20 ;
PRESS.UNIT='meters H20 salt';
PRESS.TC.POLY=[0];
PRESS.TC.SRC='BRIDGE';
PRESS.BRIDGE.NEG.POLY=[3 0]; %copied from tag 101!!!
PRESS.BRIDGE.NEG.UNIT='Volt';
PRESS.BRIDGE.POS.POLY=[6 0]; %copied from tag 101!!!
PRESS.BRIDGE.POS.UNIT='Volt';
PRESS.BRIDGE.RSENSE=200;
PRESS.BRIDGE.TEMPR.POLY=[314.0 -634.7] ;%copied from tag 101!!!
PRESS.BRIDGE.TEMPR.UNIT='degrees Celcius';

ACC=struct;
ACC.TYPE='MEMS accelerometer';
ACC.POLY=[-4.984, 2.528; 5.010, -2.528; 5.042, -2.611] ;
ACC.UNIT='g';
ACC.TREF = 20 ;
ACC.TC.POLY=[0;0;0];
ACC.TC.SRC='TEMPR';
ACC.PC=[0;0;0];
ACC.XC=zeros(3);
ACC.MAP=[1 0 0;0 -1 0;0 0 1];
ACC.MAPRULE='front-right-down';
ACC.METHOD='flips';
ACC.LASTCAL=[2011 10 8];

MAG=struct;
MAG.TYPE='magnetoresistive bridge';
MAG.POLY=[756.47 -285.04
            772.23 -245.80
            761.65 -251.79] ;
MAG.UNIT='Tesla';
MAG.TREF = 20 ;
MAG.TC.POLY=[0;0;0];
MAG.TC.SRC='BRIDGE';
MAG.PC=[0;0;0];
MAG.XC=[1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;
MAG.MAP=[0 1 0;1 0 0;0 0 -1];
MAG.MAPRULE='front-right-down';
MAG.METHOD='';
MAG.LASTCAL=[2011 10 8];
MAG.BRIDGE.NEG.POLY=[3 0];%copied from tag 101!!!
MAG.BRIDGE.NEG.UNIT='Volt';
MAG.BRIDGE.POS.POLY=[6 0];%copied from tag 101!!!
MAG.BRIDGE.POS.UNIT='Volt';
MAG.BRIDGE.RSENSE=20;
MAG.BRIDGE.TEMPR.POLY=[541.91 -459.24] ;%copied from tag 101!
MAG.BRIDGE.TEMPR.UNIT='degrees Celcius';

CAL=struct ;
CAL.TEMPR=TEMPR;
CAL.BATT=BATT;
CAL.PRESS=PRESS;
CAL.ACC=ACC;
CAL.MAG=MAG;

DEV.CAL = CAL ;
% writematxml(DEV,'DEV','/tag/tag3/hardware/d101.xml')

