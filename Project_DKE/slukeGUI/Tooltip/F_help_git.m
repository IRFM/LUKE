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
function varargout = F_help_git(key)
%   F_help_git()
%   help = F_help_git(key)
%
%plot help for git substruct or find help for specific field of git
%defined in key

tp.projects = "Git list of projects that may be updated remotely from repository (git pull) prior a simulation.";
tp.pull     = "Git pull remote projects (1), no git pull (0).";
tp.display  = "(0) : no display, (1) : display results";
        
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end