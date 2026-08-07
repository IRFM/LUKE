% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
if nargin == 0,
	web('http://82.227.179.204:8080', '-new');
else
    if ischar(opts) & size(opts,1) == 1
        opts = {opts};
    end
    %
    if ~iscell(opts),
        error('Inputs in redmine_LUKE must have a cell type.');
    else
        webstr = ['''http://82.227.179.204:8080'', ', '''-new'''];
        for iopts = 1:length(opts),
            webstr = [webstr,', ''',opts{iopts},''''];
        end
        %
        webstr = ['web(',webstr,');'];
        %
        eval(webstr);
    end
    
end

