function [p] = cline(x, y, z, color_vector)
% Add a line to an existing plot. Line segments are colored according to a factor input.
%
% This function adds colored line segments to an existing plot.  The line 
%   is plotted at points specified by inputs x and y, and colored according
%   to factor input z (with one color for each level of z).
% 
% Inputs:
%   x: x positions of points to be plotted
%   y: y positions of points to be plotted
%   z: a factor, the same length as x and y. Line segments in the resulting 
%     plot will be colored according to the levels of z.
%   color_vector: a list of colors to use (length should match the number of levels in z).
%
% Outputs:
%   p: plot of x and y with the color changes specified by color_vector
%     between levels of z

p = plot(x,y);

hold on

%find places where colors will change
pe = [find(diff(z) ~= 0), length(x)];
%find places where new colors start
pe_end = pe(1:(end - 1)) + 1;
ps = [1, pe_end]; 

%set colors to line segments between the determined color change locations
for k = 1:length(ps)
    for c = color_vector(1):color_vector(end)
        pc = ps(k):ps(k+1)-1;
        set(p, 'color', 'c')
    end
end

hold off

end

