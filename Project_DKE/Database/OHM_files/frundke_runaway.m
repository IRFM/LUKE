function [RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,tacc,pmhucrit,ZXXS] = frundke_runaway(id_simul,alpha,betath2,wpr,Zi,opt,varargin)
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
if ~isfield(opt,'keyboard'),
    opt.keyboard = false;
end
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
if imag(wpr) ~= 0,%bhat or taurinv provided - ne has to be calculated iteratively because of the coulomb logarithm
    %
    tol = 1e-6;
    nitmax = 20;
    if imag(wpr) > 0,% input wpr is bhat
        bhat2 = imag(wpr)^2;
    elseif imag(wpr) < 0,% wpr is taurinv
        bhat2 = -imag(wpr)*betath2^(3/2);
    end
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
%         lnc_e_ref = 17.6825;
        wpr = bhat2*(3/2)*lnc_e_ref/betath2^(3/2);
        %
        ne20_old = ne20;
        ne20 = (B*qe/me)^2*me*e0/(qe^2*wpr)/1e20;
        %
        convpar = abs(ne20 - ne20_old)/ne20_old;
        %
        if (isfield(opt,'adjustB') && opt.adjustB) || convpar <= tol,
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
dkeparam.keyboard = opt.keyboard;% give hand if negative density (1) or return (0)
%
equil.pTe = betath2*mc2*ones(size(equil.pTe));
%
epsi = alpha*betath2;
ohm = ohm_flat(equil,epsi);
%
[Znorm,~,~,dke_out,~,~,momentumDKE,~,Zmomcoef,~,~,mksa] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,'','',[],[]);
%
Ec = Zmomcoef.Ec_ref/1e3;% energy in MeV
%
fgrid = selectfields_jd(momentumDKE,{'pn','pnp','pn_S','dpn','mhu','mhu_S','dmhu'});
ZXXS = dke_out.ZXXS;
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
    tacc = dke_out.XXRintmask(end);
    %
else
    %
    tn = [0,dke_out.FPtime];
    dtn = diff(tn);
    ntn = length(dtn);
    %
    if isempty(dke_out.xRRp_fsav{end}),% the calculation stopped before the end (negative norm at some point)
        RR = NaN;
    elseif dkeparam.norm_mode_f == 0,
        RR = dke_out.xRRp_fsav{end}/Znorm(end).x_0_fsav;
    else
        RR = dke_out.xRRp_fsav{end};
    end
    %
    f = [dke_out.XXfM,dke_out.XXf0];
    %
    tnorm.re = zeros(1,ntn+1);
    tnorm.ri = NaN(1,ntn+1);
    tnorm.i = ones(1,ntn+1);
    %
    tacc = dke_out.XXRintmask;
    %
    for itn = 1:ntn,
        if length(Znorm) >= itn,% the calculation ran to this point
            tnorm.re(itn+1) = dke_out.xnorm_rem{itn} + dke_out.xnorm_rep{itn};
            tnorm.ri(itn+1) = Znorm(itn).x_Rfrac_0_fsav;
            tnorm.i(itn+1) = Znorm(itn).x_0_fsav;
        else% the calculation stopped before the end (negative norm at some point)
            tnorm.re(itn+1) = NaN;
            tnorm.ri(itn+1) = NaN;
            tnorm.i(itn+1) = NaN;
            %
            f{itn+1} = NaN(size(f{1}));
            %
            tacc{itn} = NaN(size(f{1}));
        end            
    end
    %
    tnorm.b = tnorm.i - tnorm.ri;
    tnorm.tot = tnorm.i + tnorm.re;% to check particle conservation
    %
    tRR.re = diff(tnorm.re)./dtn./tnorm.b(2:end);
    tRR.ri = diff(tnorm.ri)./dtn./tnorm.b(2:end);
    %        
end
%
XXFp_ij = dke_out.ZXXF_c.p_ij + dke_out.ZXXF_e.p_ij + dke_out.ZXXF_s.p_ij;
np = length(fgrid.pn);
pmhucrit = NaN(1,np);
for ipn = 1:np,
    imhucrit = find(XXFp_ij(ipn,1:end-1).*XXFp_ij(ipn,2:end) < 0);
    if isempty(imhucrit),
        if XXFp_ij(ipn,end) > 0,
            pmhucrit(ipn) = -1;
        elseif XXFp_ij(ipn,end) < 0,
            pmhucrit(ipn) = 1;
        end
    elseif length(imhucrit) == 1,% linear fit
        pmhucrit(ipn) = fgrid.mhu(imhucrit) + (fgrid.mhu(imhucrit + 1) - fgrid.mhu(imhucrit))*XXFp_ij(ipn,imhucrit)/(XXFp_ij(ipn,imhucrit) - XXFp_ij(ipn,imhucrit + 1));
    end
end


