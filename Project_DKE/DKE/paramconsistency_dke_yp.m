function [dkeparam] = paramconsistency_dke_yp(dkeparam,equil)
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
if isempty(dkeparam.psin_S) && isempty(dkeparam.rho_S),%No iteration if one radial point
    error('No input radial flux grid is specified !');
end
if length(dkeparam.rho_S) + length(dkeparam.psin_S) == 1,%No iteration if one radial point
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
if ~isfield(dkeparam,'avalanche_mode'),
    dkeparam.avalanche_mode = 0;
end
%
if ~isfield(dkeparam,'nit_ohm'),
    dkeparam.nit_ohm = 1;
elseif dkeparam.nit_ohm > 1,
    %
    if ~isfield(dkeparam,'tol_ohm'),
        dkeparam.tol_ohm = 1e-3;
    end
    if ~isfield(dkeparam,'vloop_ohm'),
        dkeparam.vloop_ohm = 1e-1;
    end
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
if ~isfield(dkeparam,'postest_rf'),
    dkeparam.postest_rf = true;%Test that the power absorbed is positive everywhere, or continue convergence process
end
%
if ~isfield(dkeparam,'finsert'),
    dkeparam.finsert = 0;%The initial distribution is used to first estimate the ray absorption
end
%
% FP time management
%
if ~isfield(dkeparam,'tn'),
    dkeparam.tn = NaN;
end
if ~isfield(dkeparam,'dtn'),
    dkeparam.dtn = NaN;
end
%
if isscalar(dkeparam.tn),
    if isnan(dkeparam.tn),
        if isscalar(dkeparam.dtn) && isnan(dkeparam.dtn),
            dkeparam.tn = 100000;%asymptotic calculation - quasi steady-state
        elseif isscalar(dkeparam.dtn) && imag(dkeparam.dtn) > 0,%number of ierations fixed by imag(dtn)
            nit = imag(dkeparam.dtn);
            dkeparam.tn = 100000.*(1:nit)/nit;% 
        else
            dkeparam.tn = cumsum(dkeparam.dtn);%tn fixed by scalar or vector dtn
        end
    else
        if ~isscalar(dkeparam.dtn),
            info_dke_yp(2,'Warning : dkeparam.dtn prescription overridden by dkeparam.tn');
            dkeparam.dtn = NaN;
        end
        if isnan(dkeparam.dtn),% automatic time step
            nit = min([100,max([1,ceil(60./dkeparam.tn.^(3/8))])]);%number of internal iterations, fitted result from TS/32299 analysis
            dkeparam.tn = dkeparam.tn.*(1:nit)/nit;% 
        elseif imag(dkeparam.dtn) > 0,%number of ierations fixed by imag(dtn)
            nit = imag(dkeparam.dtn);
            dkeparam.tn = dkeparam.tn.*(1:nit)/nit;% 
        else% time step determined by dtn
            if dkeparam.dtn > dkeparam.tn,
                info_dke_yp(2,['Warning : the prescribed time step (',num2str(dkeparam.dtn),...
                ') is reduced to tn = ',num2str(dkeparam.tn)]);
            end
            dkeparam.tn = unique([dkeparam.dtn:dkeparam.dtn:dkeparam.tn,dkeparam.tn]);
            if length(dkeparam.tn) > 1 && dkeparam.tn(end) - dkeparam.tn(end-1) < dkeparam.dtn,
                info_dke_yp(2,['Warning : the last time step (',num2str(dkeparam.tn(end) - dkeparam.tn(end-1)),...
                ') is shorter than dtn = ',num2str(dkeparam.dtn)]);
            end
        end
    end
else%time steps determined by tn vector
    if ~isscalar(dkeparam.dtn) || ~isnan(dkeparam.dtn),
        info_dke_yp(2,'Warning : dkeparam.dtn prescription overridden by dkeparam.tn');
    end
end
%
dkeparam = rmfield(dkeparam,'dtn');%dtn determined from tn in main_dke_yp
%
if dkeparam.coll_mode ~= 2,
    dkeparam.nit_f = 1;%no Legendre iterations without RHS
end
%
if dkeparam.nit_f == 1,
    dkeparam.prec0_f = -1;%no residue comparison with only one iteration
end
%
if ~isfield(dkeparam,'timevol'),
    dkeparam.timevol = 0;
end
%
if dkeparam.avalanche_mode == 1 || dkeparam.nit_ohm > 1 || imag(dkeparam.norm_mode_f) > 0
    dkeparam.timevol = 1;
end
%
if dkeparam.avalanche_mode == 1 && ~isfield(dkeparam,'f_pmax')
    dkeparam.f_pmax = 1;
end
%
if ~isfield(dkeparam,'redfac'),
    dkeparam.redfac = 0;
end
%
if dkeparam.bounce_mode == 1 && isfield(dkeparam,'mhu_S') && ~isempty(dkeparam.mhu_S),
     info_dke_yp(2,'Warning : the pitch angle grid cannot be externally enforced with bounce_mode = 1.');
     dkeparam = rmfield(dkeparam,'mhu_S');
end
%
if ~isfield(dkeparam,'opt_load'),
    dkeparam.opt_load = 0;
end
%
if ~isfield(dkeparam,'opt_struct'),
    dkeparam.opt_struct = 0;
end
% 
