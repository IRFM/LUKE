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
% 
if dkeparam.pnmax_S < 0,
	dkeparam.pnmax_S = -dkeparam.pnmax_S;
end
%
if ~isfield(dkeparam,'method'),
    dkeparam.method = 'spline';%For the pitch-angle interpolation in the prjectioon of the electron velocity distribution on the Legendre polynomial basis
    dkeparam.n_gauleg = 35;%Number of Legendre polynomials for projections of the electron velocity distribution
    dkeparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
end
%
if ~isfield(dkeparam,'finitabs'),
    dkeparam.finitabs = 0;%The initial distribution is used to first estimate the ray absorption
end
%
if ~isfield(dkeparam,'finsert'),
    dkeparam.finsert = 0;%The initial distribution is used to first estimate the ray absorption
end
%
if ~isfield(dkeparam,'tn'),
    dkeparam.tn = dkeparam.dtn;
end
if dkeparam.dtn > dkeparam.tn,
    dkeparam.dtn = dkeparam.tn;
end
%
if ~isfield(dkeparam,'timevol'),
    dkeparam.timevol = 0;
end
%
if ~isfield(dkeparam,'redfac'),
    dkeparam.redfac = 0;
end
%
