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
dkepath = load_structures_yp('dkepath','','');
%
[a,b] = system(['TERM=ansi;git --git-dir ',dkepath.luke_root,'.git log -n 1']);
b = deblank(strrep(strrep(strrep(b,'[33m',''),'[m',''),'[K',''));
list_returns = strfind(b,char(13));
hash_commit = ['Last git commit: ',strtrim(deblank(b(strfind(b,'commit')+7:strfind(b,'(')-3)))];
author_commit = strtrim(deblank(b(list_returns(2):list_returns(3))));
date_commit = strtrim(deblank(b(list_returns(3):list_returns(4))));
%
lukeversion = [hash_commit,', ',author_commit,', ',date_commit];
%
[matlabversion,matlabrelease] = matversion_yp;
%
if str2double(matlabversion) < 705;
	error('Version of MatLab prior to R2007B (7.5) are no longer supported');
end