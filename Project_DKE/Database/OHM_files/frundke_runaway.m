function [RR,mksa,Ec,f,tn,tRR,tnorm] = frundke_runaway(id_simul,alpha,betath2,wpr,Zi,opt,varargin)
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
if nargin < 6,
   opt = struct;
end
%
if ~isfield(opt,'timevol'),
    opt.timevol = 0;
end
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
if imag(wpr) > 0,%bhat provided - ne has to be calculated iteratively because of the coulomb logarithm
    %
    tol = 1e-6;
    nitmax = 20;
    bhat = imag(wpr)^2;
    %
    [~,equil,dkeparam] = fprep_runaway(0,Zi,opt,varargin{:});% magnetic field and ne20 first guess
    pB = sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2).';
    pne20 = equil.pne/1e20;
    prho = equil.ptx(:,1)/equil.ptx(end,1);
    %
    B = interp1(prho,pB,dkeparam.rho_S);
    ne20 = interp1(prho,pne20,dkeparam.rho_S);
    %
    for it = 1:nitmax,
        lnc_e_ref = 31.3 - 0.5*log(ne20*1e20) + log(mc2*1000) + log(betath2);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
        wpr = bhat*(3/2)*lnc_e_ref/betath2^(3/2);
        %
        ne20_old = ne20;
        ne20 = (B*qe/me)^2*me*e0/(qe^2*wpr)/1e20;
        %
        convpar = abs(ne20 - ne20_old)/ne20_old;
        %
        if convpar <= tol,
            break
        end
    end
    %
    if convpar > tol,
        disp('WARNING : no convergence found for ne calculation from bhat')
    end
end
%
[dkepath,equil,dkeparam,dkedisplay,waves] = fprep_runaway(wpr,Zi,opt,varargin{:});
%
dkeparam.timevol = opt.timevol;% time evolution (1) or steady-state solution (0)
%
equil.pTe = betath2*mc2*ones(size(equil.pTe));
%
epsi = alpha*betath2;
ohm = ohm_flat(equil,epsi);
%
[Znorm,~,~,dke_out,~,~,~,~,Zmomcoef,~,~,mksa] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,'','',[],[]);
%
Ec = Zmomcoef.Ec_ref/1e3;% energy in MeV
%
if opt.timevol == 0,
    %
    if dkeparam.norm_mode_f == 0,
        RR = dke_out.xRRp_fsav/Znorm.x_0_fsav;
    else
        RR = dke_out.xRRp_fsav;
    end
    %
    f = [dke_out.XXfM,dke_out.XXf0(end)];
    %
    tn = dke_out.FPtime(end);
    tnorm = '';
    tRR = '';
    %
else
    %
    if dkeparam.norm_mode_f == 0,
        RR = dke_out.xRRp_fsav{end}/Znorm(end).x_0_fsav;
    else
        RR = dke_out.xRRp_fsav{end};
    end
    %
    f = [dke_out.XXfM,dke_out.XXf0];
    %
    tn = [0,dke_out.FPtime];
    dtn = diff(tn);
    ntn = length(dtn);
    %
    tnorm.re = zeros(1,ntn+1);
    tnorm.ri = NaN(1,ntn+1);
    tnorm.i = ones(1,ntn+1);
    %
    for itn = 1:ntn,
        tnorm.re(itn+1) = dke_out.xnorm_rem{itn} + dke_out.xnorm_rep{itn};
        tnorm.ri(itn+1) = Znorm(itn).x_Rfrac_0_fsav;
        tnorm.i(itn+1) = Znorm(itn).x_0_fsav;
    end
    %
    tnorm.b = tnorm.i - tnorm.ri;
    tnorm.tot = tnorm.i + tnorm.re;% to check particle conservation
    %
    tRR.re = diff(tnorm.re)./dtn./tnorm.b(2:end);
    tRR.ri = diff(tnorm.ri)./dtn./tnorm.b(2:end);
    %
end


