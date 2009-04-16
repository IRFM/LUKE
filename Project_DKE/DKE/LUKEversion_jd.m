function [lukeversion,matlabversion] = LUKEversion_jd;
%LUKE - This function specifies the tag of the current LUKE version and the corrsonding supported MatLab version
%
% This function specifies the tag of the current LUKE version and the corrsonding supported MatLab version
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
lukeversion = 'LUKE 1.7.1';
ver = version;
matlabversion = ver([1,3]);
if str2num(ver(1:3)) < 7.5;error('Version of MatLab prior to R2007B (7.5) are not supported');end
