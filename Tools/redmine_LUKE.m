function redmine_LUKE(opts)
%	LUKE - Access the on-line LUKE redmine
%
%	Access the LUKE redmine.
%
%	Input:
%
%       - opts: web options, like '-browser' (cell or 1 single chain of characters)
%           (default: none)
%
%	Output: None
%
%
%by Y.PEYSSON CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM <joan.decker@cea.fr>
%
if nargin == 0,
	web('http://tolbachik.hd.free.fr:8080/redmine', '-new');
else
    if ischar(opts) & size(opts,1) == 1
        opts = {opts};
    end
    %
    if ~iscell(opts),
        error('Inputs in redmine_LUKE must have a cell type.');
    else
        webstr = ['''http://tolbachik.hd.free.fr:8080/redmine'', ', '''-new'''];
        for iopts = 1:length(opts),
            webstr = [webstr,', ''',opts{iopts},''''];
        end
        %
        webstr = ['web(',webstr,');'];
        %
        eval(webstr);
    end
    
end

