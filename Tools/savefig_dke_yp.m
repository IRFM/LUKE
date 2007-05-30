function  [] = savefig_dke_yp(figname,dirfig)
%
% Save current figure to different format
%
%   By J. Decker <jodecker@mit.edu> and Y. Peysson <yves.peysson@cea.fr>
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
    cd(dirfig)
    eval(['print -depsc -loose -tiff -r600 ',figname,'.eps'])
    saveas(gcf,figname,'fig')
    cd ..
end
        

