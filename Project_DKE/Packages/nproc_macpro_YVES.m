function [nproc] = nproc_macpro_YVES(display_mode,param,dkepath)
%
% Calculate the optimal number of processors for the macpro Core i7 of Yves Peysson
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
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if param.nproc > 12, 
	nproc = 12;
	info_dke_yp(2,'The number of processors has been enforced to 12 !');
else
    nproc = param.nproc;%
end   
%
fid = fopen('.machines','w');
fclose(fid);
