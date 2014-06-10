function [RR,mksa,Ec,f,tn,tRR,tnorm] = frundke_runaway(id_simul,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S)
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
if nargin < 5,
   error('Not enough arguments in frundke_runaway')
end
%
if nargin < 9,
   rho_S = 0.5;
end
%
if nargin < 6,
   opt = struct;
end
if ~isfield(opt,'timevol'),
    opt.timevol = 0;
end
if ~isfield(opt,'coll_mode'),
    opt.coll_mode = 0;
end
if ~isfield(opt,'bounce_mode'),
    opt.bounce_mode = 0;
end
if ~isfield(opt,'boundary_mode_f'),
    opt.boundary_mode_f = 0;
end
if ~isfield(opt,'norm_mode_f'),
    opt.norm_mode_f = 0;
end
if ~isfield(opt,'tn'),
    opt.tn = 10000;%time for asymptotic solution with norm_mode_f = 1
end
if ~isfield(opt,'dtn'),
    opt.dtn = 1000;%10 time steps required for accurate runaway solution - see rundke_dtn
end
if ~isfield(opt,'tnmin'),
    opt.tnmin = 0;
end
if ~isfield(opt,'synchro_mode'),
    if wpr > 0,
        opt.synchro_mode = 1;
    else
        opt.synchro_mode = 0;
    end
elseif wpr == 0,
    disp('WARNING : synchro_mode = 0 enforced as the ratio wc2/wp2 was not specified')
    disp(' ')
    opt.synchro_mode = 0;
end
%
if nargin < 8,
    if opt.bounce_mode == 0,
        id_equil = 'TScyl';%For plasma equilibrium
    else
        id_equil = 'TScirc_e1';%For plasma equilibrium
    end 
end
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display);
%
%**************************************************************************
%**************************************************************************
%
if exist('dmumpsmex','file') == 3,
    dkeparam.invproc = -2;
end
%
dkeparam.timevol = opt.timevol;% time evolution (1) or steady-state solution (0)
dkeparam.synchro_mode = opt.synchro_mode;% synchrotron reaction force option
dkeparam.coll_mode = opt.coll_mode;% mode for the collision operator
dkeparam.bounce_mode = opt.bounce_mode;% bounce averaging option
%
dkeparam.boundary_mode_f = opt.boundary_mode_f;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = opt.norm_mode_f;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
% time grid
%
if opt.tnmin == 0,%linear time grid
    dkeparam.tn = opt.tn;% time grid (if array) or maximum time
    dkeparam.dtn = opt.dtn;% time grid (if array) or time step
end
if opt.tnmin > 0,%log time grid
    dkeparam.tn = logspace(log10(opt.tnmin),log10(opt.tn),opt.dtn);
    dkeparam.dtn = NaN;
end
%
% momentum space grid
%
if nargin >= 7,
    %    
    if isfield(grid,'nmhu_S'),
        dkeparam.nmhu_S = grid.nmhu_S;
    end
    if isfield(grid,'pn_S'), 
        dkeparam.pn_S = grid.pn_S;
    else
        if ~isfield(grid,'pnmax_S'),
            grid.pnmax_S = dkeparam.pnmax_S;
        end
        if ~isfield(grid,'np_S'),
            grid.np_S = dkeparam.np_S;
        end
        %
        pn_S = linspace(0,grid.pnmax_S,grid.np_S);
        %
        if ~isfield(grid,'np_tail') || ~isfield(grid,'pnmax_S_tail') || grid.pnmax_S_tail == 0,
            grid.np_tail = 0;
        end
        %
        if grid.np_tail == 0,
            pn_S_tail = [];
        else
            pn_S = pn_S(1:end-1);
            if imag(grid.pnmax_S_tail) > 0,
                grid.pnmax_S_tail = imag(grid.pnmax_S_tail)*grid.pnmax_S;
            end
            pn_S_tail = linspace(grid.pnmax_S,grid.pnmax_S_tail,grid.np_tail + 1);
        end
        dkeparam.pn_S = [pn_S,pn_S_tail];
    end
end
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));% cold ions
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath2*mc2*ones(size(equil.pTe));
%
if wpr > 0,% adjust density to have correct wp2/wc2 - synchrotron reaction force only
    pB = sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2).';
    equil.pne = (pB*qe/me).^2*me*e0/(qe^2*wpr);
end
%
equil.zZi = [1,1,1,Zi];
equil.pzni = [0;0;0;1/Zi]*equil.pne;% single ion species
%
epsi = alpha*betath2;
ohm = ohm_flat(equil,epsi);
%
[Znorm,~,~,dke_out,~,~,~,~,Zmomcoef,~,~,mksa] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,'','','',[],[]);
%
Ec = Zmomcoef.Ec_ref/1e3;% energy in MeV
%
if dkeparam.norm_mode_f == 0,
    RR = dke_out.xRRp_fsav{end}/Znorm(end).x_0_fsav;
else
    RR = dke_out.xRRp_fsav;
end
%
if opt.timevol == 0,
    %
    f = [dke_out.XXfM,dke_out.XXf0(end)];
    %
    tn = dke_out.FPtime(end);
    tnorm = '';
    tRR = '';
    %
else
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


