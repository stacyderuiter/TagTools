function    CAL = dt3_101(date)
%
%     CAL = dt3_1XX([date])
%     Calibration file for dtag3 101
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 21 May 2006
%     Calibration 6/17/09 by Jeremy Winn

CAL.TAG = 101 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [-90 53] ;               % temperature sensor calibration

CAL.PCAL = [-19.21 3127.07 -102.62] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.45e-3 ;                        % pressure bridge current
CAL.Pr0 = 200 ;                             % current sensing resistor

CAL.ACAL = [-4.964 2.457
            4.97 -2.51
            5.035 -2.553] ;

CAL.MCAL = [755.46	-253.2
            780.01	-254.27
            770.7	-253.23] ;

CAL.APC = [0 0 0] ;  % pressure sensitivity on ax,ay,az
CAL.ATC = [0 0 0] ;                  % temperature sensitivity on ax,ay,az
CAL.AXC = [1 0 0 ;                     % cross-axis sensitivity on A
           0 1 0 ;
           0 0 1] ;

CAL.MMBC = [0 0 0] ;             % mbridge sensitivity on mx,my,mz
CAL.MPC = [0 0 0] ;                    % pressure sensitivity on mx,my,mz
CAL.MXC = [1 0 0 ;           % cross-axis sensitivity on M
           0 1 0 ;
           0 0 1] ;

CAL.VB = [6 0] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.29;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF

