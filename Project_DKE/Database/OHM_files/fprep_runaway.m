function [dkepath,equil,dkeparam,dkedisplay,waves] = fprep_runaway(wpr,Zi,opt,grid,id_equil,id_wave,rho_S)
%
if nargin < 7,
   rho_S = 0.5;
end
%
if nargin < 6,
   id_wave = '';
end
%
if nargin < 4,
   grid = struct;
end
%
if nargin < 3,
   opt = struct;
end
%
if nargin < 2,
   Zi = 1;
end
%
if nargin < 1,
   wpr = 0;
end
%
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
    opt.tn = 10000;% typical time for asymptotic solution
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
end
%
if ~isfield(opt,'avalanche_mode'),
    opt.avalanche_mode = 0;
end
if ~isfield(opt,'pnmin0_KO'),% low threshold on initial primary electrons for the knock-on operator
    opt.pnmin0_KO = NaN;% NaN to enforce to pnmax_S
end
if ~isfield(opt,'pnmax1_KO'),% high threshold on initial secondary electrons for the knock-on operator
    opt.pnmax1_KO = 0;% NaN to enforce to pnmin2_KO
end
if ~isfield(opt,'pnmin2_KO'),% low threshold on final secondary electrons for the knock-on operator
    opt.pnmin2_KO = 1i;% 1i is the "natural" limit as for lower energies it is then merges with FP collisions
end
if ~isfield(opt,'pnmax2_KO'),% high threshold on final secondary electrons for the knock-on operator
    opt.pnmax2_KO = NaN;% NaN to enforce to pnmin0_KO
end
%
if nargin < 5 || isempty(id_equil),
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
path_wave = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,waves] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'waves',{id_wave},path_wave);
%
equil.pne = equil.pne/2;
%
%**************************************************************************
%**************************************************************************
%
% luke parameters
%
if exist('dmumpsmex','file') == 3,
    dkeparam.invproc = -2;
end
%
dkeparam.coll_mode = opt.coll_mode;% mode for the collision operator
dkeparam.bounce_mode = opt.bounce_mode;% bounce averaging option
%
dkeparam.boundary_mode_f = opt.boundary_mode_f;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = opt.norm_mode_f;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if isfield(opt,'pnmin_S'),
    dkeparam.pnmin_S = opt.pnmin_S;
end
%
% time grid
%
if opt.tnmin == 0,%linear time grid
    dkeparam.tn = opt.tn;% time grid (if array) or maximum time
    dkeparam.dtn = opt.dtn;% time grid (if array) or time step
end
if opt.tnmin > 0,%log time grid
    dkeparam.tn = logspace(log10(opt.tnmin),log10(opt.tn(1)),opt.dtn(1));
    if length(opt.tn) > 1,%log + lin
        tnlin = linspace(opt.tn(1),opt.tn(2),1+opt.dtn(2));        
        dkeparam.tn = [dkeparam.tn,tnlin(2:end)];
    end
    dkeparam.dtn = NaN;
end
%
% momentum space grid
%
dkeparam.grid_uniformity = 0;
if isfield(grid,'nmhu_S'),
    dkeparam.nmhu_S = grid.nmhu_S;
end
if isfield(grid,'sfac1'),
    dkeparam.sfac1 = grid.sfac1;
end
if isfield(grid,'snmhu1'),
    dkeparam.snmhu1 = grid.snmhu1;
end
if isfield(grid,'pn_S'), 
    dkeparam.pn_S = grid.pn_S;
    dkeparam.pnmax_S = max(grid.pn_S);%used for dNparmin, etc
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
    if ~isfield(grid,'np_bulk'),
        grid.np_bulk = 0;
    end
    %
    if grid.np_bulk == 0,
        pn_S_bulk = [];
    else
        pn_S = pn_S(pn_S > 1);
        pn_S_bulk = linspace(0,1,grid.np_bulk + 1);
    end
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
        if isfield(grid,'opt') && grid.opt > 0,
            pn_S_tail = (linspace(grid.pnmax_S^(1/grid.opt),grid.pnmax_S_tail^(1/grid.opt),grid.np_tail + 1)).^grid.opt;
        else
            pn_S_tail = linspace(grid.pnmax_S,grid.pnmax_S_tail,grid.np_tail + 1);
        end
    end
    dkeparam.pn_S = [pn_S_bulk,pn_S,pn_S_tail];
    dkeparam.pnmax_S = grid.pnmax_S;%used for dNparmin, etc
end
%
% avalanche modelling : 
%
% dkeparam.pnmin0_KO is the low threshold on initial primary electrons for the knock-on operator
% The condition pnmin0_KO <= pnmax_S is enforced so that the source can be calculated
% - For pnmin0_KO = NaN, the limit is set to pnmax_S
%
% dkeparam.pnmax1_KO is the high threshold on initial secondary (bulk) electrons for the knock-on operator
% in principle, pnmax1_KO <= pnmin2_KO so that secondary electrons can only 'lose energy'
% - For pnmax1_KO = 0, the bulk population is taken as f(1)/fM(1), a logical estimate considering the sink term
% - For pnmax1_KO = NaN, the limit is set to pnmin2_KO
% 
% dkeparam.pnmin2_KO is the low threshold on final secondary electrons for the knock-on operator
% - If pnmin2_KO == NaN, the current value of pc (or pnmin_S) is used
% - If pnmin2_KO is imaginary, it is normalized to the actual thermal momentum (instead of reference)
%
% dkeparam.pnmax2_KO is the high threshold on final secondary electrons for the knock-on operator
% in principle, as rosenbluth assumes p0 > p1 we must separate the domain of source runaways (ex : 1MeV) from that of secondary electrons.
% Therefore, we should ensure pnmax2_KO <= pnmin0_KO
% - For pnmax2_KO = NaN, the limit is set to pnmin0_KO
% - If pnmax2_KO > pnmax_S (which violate the principle described above), the source between pnmax_S and pnmax2_KO is calculated as a "number"
%
dkeparam.avalanche_mode = opt.avalanche_mode;% knock on operator option
dkeparam.pnmin0_KO = opt.pnmin0_KO;
dkeparam.pnmax1_KO = opt.pnmax1_KO;
dkeparam.pnmin2_KO = opt.pnmin2_KO;
dkeparam.pnmax2_KO = opt.pnmax2_KO;
%
[qe,me,~,~,e0] = pc_dke_yp;%Universal physics constants
%
% synchrotron reaction force
%
dkeparam.synchro_mode = opt.synchro_mode;% synchrotron reaction force option
if wpr > 0,
    if isfield(opt,'adjustB') && opt.adjustB, % adjust magnetic field amplitude  to have correct wp2/wc2 - synchrotron reaction force only
        pB = sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2).';
        pBfac = sqrt(equil.pne*qe^2*wpr/(me*e0))*me/qe./pB;
        ptBfac = repmat(pBfac.',[1,length(equil.theta)]);
        equil.ptBx = equil.ptBx.*ptBfac;
        equil.ptBy = equil.ptBy.*ptBfac;
        equil.ptBPHI = equil.ptBPHI.*ptBfac;
    else% adjust density to have correct wp2/wc2 - synchrotron reaction force only
        pB = sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2).';
        equil.pne = (pB*qe/me).^2*me*e0./(qe^2*wpr);
    end
end
%
% equilibrium
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));% cold ions
%
equil.zZi = [1,1,1,Zi];
equil.pzni = [0;0;0;1/Zi]*equil.pne;% single ion species
%
if isfield(opt,'heavyions') && opt.heavyions,
    equil.zmi = 1e10*[1,1,1,1];
end
