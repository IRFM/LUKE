function [lukeversion,matlabversion] = LUKEversion_jd
%LUKE - This function specifies the tag of the current LUKE version and the corrsonding supported MatLab version
%
% This function specifies the tag of the current LUKE version and the corrsonding supported MatLab version
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
lukeversion = 'LUKE 1.9.1';
ver = version;
[iver] = strfind(ver,'.');
if iver(2)-iver(1) == 2,
	ver = [ver(1:iver(1)-1),'0',ver(iver(1)+1:iver(2)-1)];
else
	ver = [ver(1:iver(1)-1),ver(iver(1)+1:iver(2)-1)];
end
matlabversion = ver;
if str2double(ver) < 705;
	error('Version of MatLab prior to R2007B (7.5) are no longer supported');
end
