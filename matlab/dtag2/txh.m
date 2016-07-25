function X = txh(yvar,fs)
%make a vector for the x-axis of a dtag data plot in units of hours instead
%of dtag samples
%inputs:
%yvar is the variable you want to plot as a function of time (e.g. p, roll,
%head, etc.)
%fs is the sampling rate at which yvar is sampled
X = (1:length(yvar))./fs./3600;