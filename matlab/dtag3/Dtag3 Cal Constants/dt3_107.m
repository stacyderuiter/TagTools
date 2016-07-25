function    CAL = dt3_107(date)
%
%     CAL = dt3_107([date])
%     Calibration file for dtag3 107
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 08 Oct 2011
%     modified so tag3 can work with tag2 tools

CAL.TAG = 107 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [-90 53] ;               % temperature sensor calibration

CAL.PCAL = [8.55 3185.47 -102.61] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.45e-3 ;                        % pressure bridge current
CAL.Pr0 = 200 ;                             % current sensing resistor

CAL.ACAL = [-5.048 2.466
            4.971 -2.474
            5.025 -2.485] ;

CAL.MCAL = [672.27 -235.86
            678.32 -148.14
            731.01 -302.21] ;

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

CAL.VB = [6 0] ;           % battery voltage conversion to volts
CAL.PB = [2.5 2.5] ;       % pb conversion to volts
CAL.PBTREF =  3.29;        % pb value in volts at TREF
CAL.MB = [2.5 2.5] ;       % mb conversion to volts
CAL.MBTREF =  2.82;        % mb value in volts at TREF

