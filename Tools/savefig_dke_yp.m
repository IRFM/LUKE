function  [] = savefig_dk_yp(figname)
%
% Save current figure to different format
%
%   By J. Decker <jodecker@mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%
eval(['print -depsc -loose -tiff -r600 ',figname,'.eps'])
saveas(gcf,figname,'fig')
