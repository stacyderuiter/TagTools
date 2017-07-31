function F1 = plot_acf(lags,ac,N)
% Plot output from acf(). This is a utility function called by acf.m
%
% Inputs: 
%   lags -      numbers of lags to be plotted (output of acf())
%   ac   -      autocorrelation function values (output of acf())
%   N    -      number of observations in the original dataset for which
%               ACF was computed.
%
% Returns:
%   F1 -        (optional) a handle to the resulting figure

if nargin < 3
    error('plot_acf requires 3 inputs: lags, ac, and N')
end

CI = [-1.96/sqrt(N), 1.96/sqrt(N)];
stem(lags,ac, '-k', 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 3) ;
xlabel('Lag'); ylabel('ACF')
hold on
for k=1:2
    plot(get(gca,'xlim'), repmat(CI(k),2,1) , 'Color', [0.663, 0.663, 0.663], 'LineStyle', '--');
end
hold off
