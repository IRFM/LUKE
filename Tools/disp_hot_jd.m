function [smask_ht,sNperp_ht,sepol_pmz_ht,sPflow_pmz_ht,sPabs_at,...
        smask_ft,sNperp_ft,sepol_pmz_ft] = ...
    disp_hot_jd(ss,sB,sne,sTe,sNpar,omega,sNperp,rel_opt,tol_ht,nd_ht,guess_ES,nn_nr);
%
% Hot plasma dispersion solver R2D2 
%
% by J. Decker and A.K. Ram
%
nnpar = 50;%number of points to continuously raise Npar when Npar = 1.
%
if nargin < 12
    nn_nr = 50;
end
if nargin < 11
    guess_ES = 10;
end
if nargin < 10
    nd_ht = 11;
end
if nargin < 9
    tol_ht = 0.2;
end
if nargin < 8
    rel_opt = 0;%non-relativistic calculations
end
%
if nargin < 7
    sNperp = NaN*sNpar;%electrostatic root 
end
%
ns = length(ss);
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
if sum(isnan(sNperp)) == ns% look for electrostatic root 
    %
    % Cut-Offs location in cold plasma
    %
    swpe = sqrt(sne*qe^2/e0/me);
    swce = qe*sB/me;
    %
    iOco_app = min(find(omega < swpe));
    %
    if sNpar(iOco_app) < 1,
        swR = sqrt(swce.^2/4 + swpe.^2./(1-sNpar.^2)) + swce/2;
        swL = sqrt(swce.^2/4 + swpe.^2./(1-sNpar.^2)) - swce/2; 
        %
        iRco_app = min(find(omega < swR));
        iLco_app = min(find(omega < swL));
        iCmin_app = max([iRco_app,iLco_app,iOco_app]);
        %mask_npar = [];
    else % in this case, we continously search roots going from Npar = Npar_0 to the final value
        %sNpar_guess = 1/sqrt(1 + omega/swce(iOco_app));%Npar_0
        %mask_npar = [iOco_app]*ones(1,nnpar);
        iCmin_app = iOco_app;
    end    
    %
    % ES approximation - guess for hot plasma calculations
    %
    gn = 1 - round(omega/swce(iCmin_app))*swce(iCmin_app)/omega;
    if gn > 0,
        guess_Nperp = 50;%LFR approach
    else
        guess_Nperp = -50*gn;%HFR approach
    end
    %
    fac_root = 1.1;
    fac_exp = -1.5;
    fac_lim = 20;
    GNperp = NaN;
    %
    while (isnan(GNperp) | real(GNperp) < 1) & fac_root < fac_lim
        [GNperp] = disp_ebwES_jd(sB(iCmin_app),sTe(iCmin_app),sne(iCmin_app),omega,NaN,guess_Nperp*fac_root);
        fac_root = fac_root^fac_exp;
    end
    %
    % Determines ESW propagation range
    %
    mask_in = iCmin_app:ns;
    %
else% look for electromagnetic root - closest from input Nperp
    %
    GNperp = sNperp(1);
    %
    mask_in = 1:ns;
end
%    
ns_in = length(mask_in);
ss_in = ss(mask_in);
sNpar_in = sNpar(mask_in);
sB_in = sB(mask_in);
sTe_in = sTe(mask_in);
sne_in = sne(mask_in);
%    
knr = 1-rel_opt;
nrt_nr = 1;
nrt_fr = 1;
kflag = 1;
%
[ss_out_ft,sMNperp_ft,sM3eps_pmz_ft,ss_out_ht,sMNperp_ht,sM3eps_pmz_ht,sM3Pflow_xyz_ht,sMPabs_at,sM3Pflow_pmz_ht] = ...
    disp_jd(ss_in,sB_in,sTe_in,sne_in,sNpar_in,omega,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr,tol_ht,nd_ht);
ns_out_ft = length(ss_out_ft);
ns_out_ht = length(ss_out_ht);
if ns_out_ht ~= ns_in
    diff_ns = num2str(100 - ns_out_ht*100/ns_in);
    disp(['Warning: disp. calc. have been truncated by ',diff_ns(1:2),' %'])
end
%
for is = 1:ns_out_ht,
    smask_ht(1,is) = find(abs(ss_out_ht(is) - ss) == min(abs(ss_out_ht(is) - ss))); 
end
for is = 1:ns_out_ft,
    smask_ft(1,is) = find(abs(ss_out_ft(is) - ss) == min(abs(ss_out_ft(is) - ss))); 
end
sNperp_ht = sMNperp_ht';%since nrt=1
sepol_pmz_ht = reshape(sM3eps_pmz_ht,[ns_out_ht,3])';
%sPflow_xyz_ht = reshape(sM3Pflow_xyz_ht,[ns_out_ht,3])';
sPflow_pmz_ht = reshape(sM3Pflow_pmz_ht,[ns_out_ht,3])';
sPabs_at = sMPabs_at';
sNperp_ft = sMNperp_ft';
sepol_pmz_ft = reshape(sM3eps_pmz_ft,[ns_out_ft,3])';
%

