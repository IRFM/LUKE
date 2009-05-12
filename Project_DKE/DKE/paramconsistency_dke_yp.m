function [dkeparam] = paramconsistency_dke_yp(dkeparam,equil,psin_S,rho_S)
%
% Cross-check input parameter consistency
%
%by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (MIT/RLE) <joan.decker@cea.fr>
%
if isinf(equil.Rp),
    dkeparam.bounce_mode = 0;
end
if dkeparam.bounce_mode == 0,dkeparam.dke_mode = 0;end
if dkeparam.dke_mode == 0, dkeparam.syn_mode =0;end
if dkeparam.rt_mode == 0,dkeparam.nit_rf = 1;end
%
if (dkeparam.invproc == -1), dkeparam.luproc = -1;end,%MUMPS performs direct inversion only
%
if isempty(psin_S) == 1 & isempty(rho_S) == 1,%No iteration if one radial point
    error('No input radial flux grid is specified !');
end
if length(rho_S) + length(psin_S) == 1,%No iteration if one radial point
    dkeparam.rt_mode = 0;
	dkeparam.nit_rf = 1;
else
    if (dkeparam.ref_mode == 1),dkeparam.ref_mode = 0;end
end
%
if strcmp(equil.id,'LOCAL'),%local calculations, assume flux surface is circular
    dkeparam.equil_mode = 0;
end
%
if ~isfield(dkeparam,'clustermode'),
	dkeparam.clustermode = '';
end
%
if ~isfield(dkeparam,'mfactor'),
    dkeparam.mfactor = 10;
end