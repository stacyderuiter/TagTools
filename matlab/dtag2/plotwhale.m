function g = plotwhale(L1,L2,L3,c,marker,nlabels)
% Plot values in the color vector c at the locations in X,Y,Z:
%
%    g = plotwhale(X,Y,Z,c,marker,nlabels)
%
% Generates a 3D point plot of a whale track given as X,Y,Z using the values in the vector c to
% determine the color of each point.  If c is empty, then Z is used to
% color the plot.  The data points are sorted so that plotwhale is only called
% once for each group of points that map to the same color.  A handle to
% the figure is returned optionally.
%
%%%%% INPUT %%%%
%    X,Y,Z    x,y,z location vectors,                     n x 1
%    c        color vector (optional),      default = z,  n x 1
%    marker   marker character (opt.),      default = '.'
%    nlabels  number of cbar labels (opt),  default = 10
%%%% Output %%%%
%    g        figure handle for the plot (optional)
%
% Where z is automatically inverted (i.e. *-1)
%
% Example
% plotwhale(tx ty tz);
%
% Modified version of plot3k by Ken Garrard, North Carolina State
% University, 2005 which was Based on plot3c by Uli Theune, University of
% Alberta
%
% Version 0.1 by Ann Allen, Woods Hole Oceanographic Inst., 2008

L=[L1 L2 L3]; % Create location vector.
clear L1 L2 L3; % free up memory.

L(:,3)=-L(:,3); % Reverse the 3rd dimension (depth) to get positive depths.
error(nargchk(1,4,nargin)); % More than 4 inputs? return an error.
if nargin < 4 || isempty(c),       c       = -L(:,3); end    % color by z values
if nargin < 5 || isempty(marker),  marker  = '.';    end    % '.' marker
if nargin < 6 || isempty(nlabels), nlabels = 10;     end    % 10 colorbar labels

% check for errors in input arguments
if size(L,2) ~= 3
    error('Location vector must have 3 columns');
end
if length(L) ~= length(c)
    error('Location vector and color vector must be the same length');
end
marker_str = '+o*.xsd^v><ph';
if (length(marker) ~= 1) || isempty(strfind(marker_str,marker))
    error('Invalid marker character, select one of ''%s''', marker_str);
end

% find color limits and range, get colormap and find length
min_c   = min(c);
max_c   = max(c);
range_c = max_c - min_c;
cmap = colormap;
clen = length(cmap);

% calculate color map index for each point
L(:,4) = min(max(round((c-min_c)*(clen-1)/range_c),1),clen);

% sort by color map index
L = sortrows(L,4);

% build index vector of color transitions (last point for each color)
dLix = [find(diff(L(:,4))>0); length(L)];

% plot data points in groups by color map index
hold on;                           % add points to one set of axes
s = 1;                             % index of 1st point in a color group
for k = 1:length(dLix)             % loop over each non-empty color group
    plot3(L(s:dLix(k),1), ...      % call plot3 once for each color group
        L(s:dLix(k),2), ...
        L(s:dLix(k),3), ...
        marker,         ...
        'MarkerEdgeColor',cmap(L(s,4),:), ... % same marker color from cmap
        'MarkerFaceColor',cmap(L(s,4),:) );   %   for all points in group
    s = dLix(k)+1;                  % next group starts at next point
end
hold off;

% set plot characteristics
view(3);                           % use default 3D view, (-37.5,30)
grid on;
%set(gca,'FontName','Arial','FontSize',10,'FontWeight','bold');

% format the colorbar
h = colorbar;
nlabels = abs(nlabels);                    % number of labels must be pos.
set(h,'YLim',[1 clen]);                    % set colorbar limits
set(h,'YTick',linspace(1,clen,nlabels));   % set tick mark locations
% create colorbar tick labels based on color vector data values
tick_vals = -linspace(min_c,max_c,nlabels);

% create cell array of color bar tick label strings
warning off MATLAB:log:logOfZero;
for i = 1:nlabels
    if abs(min(log10(abs(tick_vals)))) <= 4, fm = '%-4.0f';   % fixed
    else                                     fm = '%-4.2E';   % floating
        % Use floating point labels (10E5 and the like) if values get too
        % big.
    end
    labels{i} = sprintf(fm,tick_vals(i));
end
warning on MATLAB:log:logOfZero;

% set tick label strings
set(h,'YTickLabel',labels);
set(gca,'ZDir','reverse')
% Reverse the Z-axis to take into account depth.
set(get(h,'ylabel'),'String','Depth (m)');
%label the colorbar 
if nargout>0
    g = gcf;
end
% return figure handle