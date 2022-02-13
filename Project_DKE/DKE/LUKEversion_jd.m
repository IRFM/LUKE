function [lukeversion,matlabversion,matlabrelease] = LUKEversion_jd
%LUKE - This function specifies the last Git commit of the current LUKE version
%
% This function specifies the last git commit date of the current LUKE version
%
% Input: none
%
% Output:
%
%   - lukeversion: git last commit date LUKE [1,p]
%   - matlabversion: Matlab version of LUKE (must be greater or equal to 705) [1,p]
%   - matlabrelease: Matlab release (Ryyyya or Ryyyyb, where yyyy is the year) [1,p]
%
% Warning: none
%
%by Y.Peysson CEA/DSM/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/DSM/IRFM (joan.decker@cea.fr)
%
luke_root = which('LUKEversion_jd.m');
luke_root = luke_root(1:strfind(luke_root,'Project_DKE')-1);
%
fileID = fopen([luke_root,'lastgithash.txt'],'r');
fprintf(fileID,'%s',lukeversion);
fclose(fileID);
%
lukeversion = deblank(strrep(strrep(strrep(lukeversion,'[33m',''),'[m',''),'[K',''));
%
[matlabversion,matlabrelease] = matversion_yp;
%
if str2double(matlabversion) < 705;
	error('Version of MatLab prior to R2007B (7.5) are no longer supported');
end