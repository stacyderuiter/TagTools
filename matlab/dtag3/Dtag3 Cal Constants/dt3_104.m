function    CAL = dt3_104(date)
%
%     CAL = dt3_1XX([date])
%     Calibration file for dtag3 1XX
%     Use date=[yr mon day] in case calibration constants
%     changed over time.
%
%     mark johnson and tom hurst
%     thurst@whoi.edu
%     last modified: 08 Oct 2011
%     modified so tag3 can work with tag2 tools

CAL.TAG = 104 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [-90 53] ;               % temperature sensor calibration, default values

CAL.PCAL = [15.65 3170.8 -97.3] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.45e-3 ;                        % pressure bridge current
CAL.Pr0 = 200 ;                             % current sensing resistor

CAL.ACAL = [-4.96 2.42
            4.99 -2.48
            5.02 -2.53] ;

CAL.MCAL = [781.2 -301.5
            785.5 -225.2
            760.5 -276] ;

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

