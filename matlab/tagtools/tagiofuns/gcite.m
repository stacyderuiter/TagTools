function [cite,bibf]=gcite(doi,opage)
% gcite(doi)
%		or
%		[cite,bibf]=gcite(doi)
%       or
%       [cite,bibf]=gcite(doi,opage)
%
%       Get citation (gcite) information from the web using an 'objects'
%       doi number (digital object identifier).
%
%       Inputs:
%       doi number as a string. The doi number can be entered as a url
%       ('https://doi.org/10.1109/JOE.2002.808212') or as a number
%       ('10.1109/JOE.2002.808212'). The function checks for the mssing
%       host address and appends it to the doi number.
%
%       opage is an optional argument to open the  project archive / webpage.
%       1 (true) open webpage or 0 (false). This option uses the web
%       function in Matlab, available since release 2006a, but which is not
%       currently implemented in Octave. ** Looking for alternative methods
%       that work with all operating systems.
%
%       Outputs:
%       cite APA formtted citation
%       bibf bibtex citationd information file that can easily be imported
%       into any reference manager.
%
%       Examples
%       gcite('https://doi.org/10.1109/JOE.2002.808212') returns:
%       cite =
%        'Johnson, M. P., & Tyack, P. L. (2003). A digital acoustic
%        recording tag for measuring the response of wild marine mammals to
%        sound. IEEE Journal of Oceanic Engineering, 28(1), 3–12.
%        doi:10.1109/joe.2002.808212'
%
%      [cite,bibf]=gcite('10.1109/JOE.2002.808212') returns:
%
%      cite =
%        'Johnson, M. P., & Tyack, P. L. (2003). A digital acoustic
%        recording tag for measuring the response of wild marine mammals to
%        sound. IEEE Journal of Oceanic Engineering, 28(1), 3–12.
%        doi:10.1109/joe.2002.808212'
%
%      bibf =
%        '@article{Johnson_2003,
%      	    doi = {10.1109/joe.2002.808212},
%      	    url = {https://doi.org/10.1109%2Fjoe.2002.808212},
%      	    year = 2003,
%      	    month = {jan},
%      	    publisher = {Institute of Electrical and Electronics Engineers ({IEEE})},
%      	    volume = {28},
%      	    number = {1},
%      	    pages = {3--12},
%      	    author = {M.P. Johnson and P.L. Tyack},
%      	    title = {A digital acoustic recording tag for measuring the response of wild marine mammals to sound},
%      	    journal = {{IEEE} Journal of Oceanic Engineering}
%        }'
%
%     Valid: Matlab & Octave. Note to Octave users the optional argument
%     'opage' is currently available in Octave. ** Looking for a cross
%     platform alternative.
%     rjs30@st-andrews.ac.uk
%     last modified: 08 April 2020


if isempty(doi)
    return
end

if ~exist('opage','var')
    opage=0;
end

% Check the function web exists yes for matlab no for octave
if ~exist('web') && opage==1
    opage=0;
end

% Check for missing host address
if ~(contains(doi,'https://doi.org/'))
    doi=['https://doi.org/' doi];
end

% Get formatted citation (APA style)
pcite=['curl -LH "Accept: text/x-bibliography; style=apa" ' doi];
[~,cite]=system(pcite);

% Get bibtex formatted citation info
bibf=['curl -LH "Accept: application/x-bibtex" ' doi];
[~,bibf]=system(bibf);

% Open webpage
if opage >0
    web(doi)
end

end
