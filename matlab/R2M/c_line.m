function [p] = c_line(x, y, z, color_vector)
% Plots a line at points specified by inputs x and y, and colored according
%   to factor input z (with one color for each level of z).
% 
% Inputs:
%   x: x positions of points to be plotted
%   y: y positions of points to be plotted
%   z: a factor, the same length as x and y. Line segments in the resulting 
%     plot will be colored according to the levels of z.
%   color_vector: a list of colors to use (length should match the number
%     of levels in z). This must be in the form of a cell array.
%
% Outputs:
%   p: plot of x and y with the color changes specified by color_vector
%     between levels of z

%find places where colors will change
pe = [find(diff(z) ~= 0), length(x)];
%find places where new colors start
pe_end = pe(1:(end - 1)) + 1;
ps = [1, pe_end]; 

for s = 1:length(ps)
    if s < length(ps),
        p = plot(x(ps(s):ps(s+1)), y(ps(s):ps(s+1)));
        set(p, 'Color', color_vector{s});
        hold on
    else
        p = plot(x(ps(s):pe(s)), y(ps(s):pe(s)));
        set(p, 'Color', color_vector{s});
        hold on
    end 
end

hold off

end
