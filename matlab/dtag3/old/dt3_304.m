function    CAL = dt3_304(date)
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

CAL.TAG = 304 ;

CAL.TREF = 20 ;                     % temperature of calibration
CAL.TCAL = [-90 53] ;               % temperature sensor calibration

CAL.PCAL = [33.3975 3182.5825 -108.39] ;
CAL.PTC = 0 ;
CAL.Pi0 = 0.45e-3 ;                        % pressure bridge current
CAL.Pr0 = 200 ;                             % current sensing resistor

CAL.ACAL = [-4.97235 2.46855
            4.984075 -2.503625
            5.0067 -2.552125] ;

CAL.MCAL = [753.62 -254.3425
            774.8875 -267.83
            771.295 -256.305] ;

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

