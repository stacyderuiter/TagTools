%calibration for Dtag3-106
CAL.TAG = 106 ;

CAL.TREF = 20 ;                     % temperature of calibration
%##########DANGER!  these tcal values are from tag2!!!!!
CAL.TCAL = [125 75] ;               % temperature sensor calibration

%CAL.PCAL = [2979 -84];
CAL.PCAL = [45.33 	3347.99 	-127.64]; %from Tom Hurst 9/24/11

CAL.PTC = 0 ;
CAL.Pi0 = [] ;                        % pressure bridge current
CAL.Pr0 = [] ;                             % current sensing resistor

CAL.ACAL = [5.03, -2.52                     %accelerometer calibration
    4.97,-2.48
    5.14,-2.61];

CAL.MCAL = [1 1
    1 1
    1 1] ;  %NEED REAL CAL VALUES!

CAL.APC = [];  % pressure sensitivity on ax,ay,az
CAL.ATC = [] ;                    % temperature sensitivity on ax,ay,az
CAL.AXC = [] ;                    % cross-axis sensitivity on A

CAL.MMBC = [];          % mbridge sensitivity on mx,my,mz
CAL.MPC = [] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC =[] ;           % cross-axis sensitivity on M

CAL.VB = [];           % battery voltage conversion to volts
CAL.PB = [] ;       % pb conversion to volts
CAL.PBTREF = [] ;        % pb value in volts at TREF
CAL.MB = [];       % mb conversion to volts
CAL.MBTREF = [] ;        % mb value in volts at TREF


%run accelerometer calibration
ax = polyval(CAL.ACAL(1,:),s(:,1));
ay = polyval(CAL.ACAL(2,:),s(:,2));
az = polyval(CAL.ACAL(3,:),s(:,3));
A = [ax, ay, az];

%run accelerometer calibration
mx = polyval(CAL.MCAL(1,:),s(:,4));
my = polyval(CAL.MCAL(2,:),s(:,5));
mz = polyval(CAL.MCAL(3,:),s(:,6));
M = [mx, my, mz];

%run pressure calibration (conversion to meters)
p = polyval(CAL.PCAL,s(:,7));

%temperature (NEED CORRECT CONSTANTS!)
tempr = polyval(CAL.TCAL,s(:,8)) ;




