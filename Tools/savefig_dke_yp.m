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
function  [] = savefig_dke_yp(figname,dirfig)
%
% Save current figure to different format
%
if nargin == 1,
    dirfig = '';
end
if isempty(dirfig),%local saving
    eval(['print -depsc -loose -tiff -r600 ',figname,'.eps'])
    saveas(gcf,figname,'fig')
else    
    if ~exist(dirfig),%Create directory for figures
        mkdir(dirfig);
    end
%
    dir_old = pwd;
    cd(dirfig)
    eval(['print -depsc -loose -tiff -r600 ',figname,'.eps'])
    saveas(gcf,figname,'fig')
    cd(dir_old)
end
        

