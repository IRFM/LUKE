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
[dkepath,equil,dkeparam,dkedisplay,waves] = fprep_runaway(wpr,Zi,opt,varargin{:});
%
dkeparam.timevol = opt.timevol;% time evolution (1) or steady-state solution (0)
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
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


