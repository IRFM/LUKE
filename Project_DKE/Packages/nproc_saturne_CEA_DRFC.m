function [nproc] = nproc_saturne_CEA_DRFC(display_mode,param)
%
% Calculate the optimal number of processors for SATURNE cluster @ CEA-DRFC
%
% INPUTS: 
%
%  - display_mode: display some results [1,1]
%  - param: Structure for controling program. 
%
% OUTPUTS:
%
%   - nproc: number of processor [1,1]
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if param.nproc > 15, 
	nproc = 15;
	info_dke_yp(2,'The number of processors has been enforced to 15 !');
else
	nproc = PETSCparam.nproc;
end   
%
% Dynamic evaluation of the cluster charge
%
if display_mode >=1,
	unix('mcharge 1');
else
	unix('mcharge 0');
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


