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
	nproc = max(2,param.nproc);%2 processors enforced on Saturne cluster
end   
%
% Dynamic evaluation of the cluster charge
%
if display_mode >=1,
	unix([dkepath.luke_root,'Project_DKE/Packages/mcharge 1']);
else
	unix([dkepath.luke_root,'Project_DKE/Packages/mcharge 0']);
end
%
fid = fopen('.machines','r');
listactivenodes = fread(fid,'uint8=>char')';
fclose(fid);
proc = listactivenodes(strfind(listactivenodes,':')+1);
nprocmax = sum(str2num(proc(:)));%Maximum number of available processors (usually nprocmax = nproc, except if nproc is too large or the computing charge is too heavy)
if nprocmax <= nproc,
    if display_mode >=1,info_dke_yp(2,['Number of processors requested : ',int2str(nproc),', number of processors available: ',int2str(nprocmax)]);end;%less processors are available
	nproc = nprocmax;
end   


