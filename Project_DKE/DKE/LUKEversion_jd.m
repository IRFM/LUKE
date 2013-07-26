function [lukeversion,matlabversion,matlabrelease] = LUKEversion_jd
%LUKE - This function specifies the tag of the current LUKE version and the corresponding supported MatLab version
%
% This function specifies the tag of the current LUKE version and the
% corresponding supported MatLab version and release
%
% Input: none
%
% Output:
%
%   - lukeversion: CVS version on LUKE [1,p]
%   - matlabversion: Matlab version of LUKE (must be greater or equal to 705) [1,p]
%   - matlabrelease: Matlab release (Ryyyya or Ryyyyb, where yyyy is the year) [1,p]
%
% Warning: none
%
%by Y.Peysson CEA/DSM/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/DSM/IRFM (joan.decker@cea.fr)
%
lukeversion = 'LUKE 1.11.0';
%
[matlabversion,matlabrelease] = matversion_yp;
%
if str2double(matlabversion) < 705;
	error('Version of MatLab prior to R2007B (7.5) are no longer supported');
end