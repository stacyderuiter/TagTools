function    CAL = tag230(date)
%
%     CAL = tag230([date])
%     Calibration file for tag230
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006

%Last calibration: 6/2/08, thurst
%6/25/08, thurst	corrected accel and mag signs

CAL.TAG = 230 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [125 75] ;               % temperature sensor calibration

CAL.PCAL = [-17.55 1358.51 1248.96] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.877e-3 ;                        % pressure bridge current
CAL.Pr0 = 130 ;                             % current sensing resistor

CAL.ACAL = [4.01 -1.11
            -3.95 1.11
            3.97 -1.01] ;
%meancheck = 1.00, stdev = 0.02

CAL.MCAL = [-85.95 -4.99
            -90.87 13.85
            89.55 17.42] ;
%meancheck = 54.46, stdev = 5.10

CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;  % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;   % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [5 5] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.296;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF

