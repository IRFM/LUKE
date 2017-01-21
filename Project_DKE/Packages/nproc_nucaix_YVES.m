function [nproc] = nproc_nucaix_YVES(display_mode,param,dkepath)
%
% Calculate the optimal number of processors fornuc Aix Core i3 of Yves Peysson
%
% INPUTS: 
%
%  - display_mode: display some results [1,1]
%  - param: Structure for controling program. 
%  - dkepath: Structure of the paths 
%
% OUTPUTS:
%
%   - nproc: number of processor [1,1]
%
%By Joan Decker (SPC/EPFL, joan.decker@epfl.ch) and Yves Peysson (IRFM/CEA, yves.peysson@cea.fr)
%
if param.nproc > 4, 
	nproc = 4;
	info_dke_yp(2,'The number of processors has been enforced to 4 !');
else
    nproc = param.nproc;%
end   
%
fid = fopen('.machines','w');
fclose(fid);
