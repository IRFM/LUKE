function output = metis2luke(post,it,auto_mode)
%
% function for running LUKE at a given time in the METIS profil0d time grid
%
% by J. Decker et J.-F. Artaud, 02/01/2011
%
output = '';
%
profil0d = post.profil0d;
zerod = post.zerod;
%exp0d = post.z0dinput.exp0d;
cons = post.z0dinput.cons;
geo = post.z0dinput.geo;
option = post.z0dinput.option;
tokamak = post.z0dinput.machine;
shotnum = num2str(fix(abs(post.z0dinput.shot)));
%
clear post
%
% test inputs and set calculation time
%
if nargin < 3,
    auto_mode = 0;
end
%
if nargin < 2,
    trange = [min(profil0d.temps);max(profil0d.temps)];
    t = input_dke_yp(['Please enter the discharge time at which LUKE is to be called (s) [',num2str(trange.'),']'],mean(trange),trange);
    it = find(abs(t - profil0d.temps) == min(abs(t - profil0d.temps)),1,'first');
    if profil0d.temps(it) ~= t,
        t = profil0d.temps(it);
        disp(['Closest METIS profiles time selected : t = ',num2str(t),' s.']);
    end
else
    if ~isscalar(it) || it ~= round(it) || it < 1 || it > length(profil0d.temps),
        error('Invalid METIS profiles time index selected')
    else
        t = profil0d.temps(it);
        disp(['METIS profiles time selected : t = ',num2str(t),' s.']);
    end
end
%
shotime = num2str(t,'%6.4f');
%
% extract METIS data at computation time
%
profil0d = structindex(profil0d,length(profil0d.temps),it,{'xli'});
%
itzerod = find(abs((zerod.temps - t)/t) < 10*eps,1,'first');
if isempty(itzerod),
    error('profil0d time not found in exp0d time grid.')
else
    zerod = structindex(zerod,length(zerod.temps),itzerod);
end
%
% itexp = find(abs((exp0d.temps - t)/t) < 10*eps,1,'first');
% if isempty(itexp),
%     error('profil0d time not found in exp0d time grid.')
% else
%     exp0d = structindex(exp0d,length(exp0d.temps),itexp);
% end
%
itcons = find(abs((cons.temps - t)/t) < 10*eps,1,'first');
if isempty(itcons),
    error('profil0d time not found in cons time grid.')
else
    ntcons = length(cons.temps);
    cons = structindex(cons,ntcons,itcons);
    geo = structindex(geo,ntcons,itcons);
end
%
% LUKE parameters structure
%
lukeparam = make_lukeparam_metis2luke(cons,option,auto_mode);
dkeparam = lukeparam.dkeparam;
%
% LUKE display structure
%
dkedisplay = make_display_cronos;
dkedisplay.rho_display  = lukeparam.rho_display;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.display_mode = lukeparam.display_mode;%Display mode: (0): no, (1): partial, (2): full
%
% LUKE equilibrium structure
%
equil_id = [tokamak,'_',shotnum,'_',shotime];
%
[equil,profil0d_out] = make_equil_metis2luke(equil_id,profil0d,zerod,geo,option,lukeparam.equilparam);
%
prho = equil.ptx(:,1).'/equil.ptx(end,1);%rho grid in LUKE definition
%
% LUKE wavestructs structure
%
launchs_lh = make_wavelaunchs_metis2luke_lh(option,lukeparam.lhparam);
launchs_ec = make_wavelaunchs_metis2luke_ec(option,lukeparam.ecparam,equil);
%    
launchs = [launchs_lh,launchs_ec];
%
nw = length(launchs);
%
wavestructs = cell(1,nw);
%
dkeparam.w_mask = [];% waves to be accounted for in radial grid optimization: EC only or LH if no EC present
%
simul_wid = '';
%
for iw = 1:nw,
    wavestructs{iw} = make_wavert_cronos(launchs{iw});%parameter for ray-tracing are adapted to the selected wave
    %
    wavestructs{iw}.equil_id = equil.id;
    %
    if strcmp(launchs{iw}.type,'EC')
        %
        dkeparam.w_mask = [dkeparam.w_mask,iw];
        disp(['wave :',int2str(iw),' type :',launchs{iw}.type])
        %
    else
        disp(['wave :',int2str(iw),' type :',launchs{iw}.type,'; n// = ',num2str(wavestructs{iw}.launch.bNpar0,4),...
            '; Plh = ',num2str(wavestructs{iw}.launch.bPlhtot/1e6,4),' MW'])
    end
    %
    simul_wid = [simul_wid,'_',wavestructs{iw}.id];
    %
end
if isempty(dkeparam.w_mask)
    dkeparam.w_mask = 1:length(launchs);
end
%
% LUKE ohm structure
% 
ohm.id = 'EPAR';
ohm.rho = prho;
ohm.epsi = - profil0d_out.epar;%in V/m (the minus sign is for the electron charge)
%
% LUKE radial transport structure
%
if lukeparam.transpfaste.Dr0 == 0 && lukeparam.transpfaste.Vr0 == 0% cas sans transport, structure vide
    transpfaste = '';
    transpfaste_id = '';
else
    transpfaste = lukeparam.transpfaste;
    transpfaste_id = ['_',transpfaste.id];
end
%
% LUKE ripple structure
%
ripple = '';
%
if lukeparam.luke_mode == 2,% save input then exit
    %  
    if auto_mode == 0,
        workdir = uigetdir(pwd,'Select save directory');
        if ~ischar(workdir)
            workdir = pwd;
        end
    else 
        workdir = pwd;
    end
    %
    save([workdir,'/before_luke@',equil_id,'.mat']);
    %
    return
    %
end
%
% LUKE path structure
%
dkepath = getappdata(0,'DKEPATH');
dkepath.temppath = [dkepath.temppathroot,filesep,'CRONOS',filesep,timeid_jd(clock)];%Temporary subdirectory in scratch folder
%
% RUN LUKE with RF waves
%
simul_id = ['METIS_',equil.id,simul_wid,ohm.id,transpfaste_id];
%
if lukeparam.batch_mode == 1 && isfield(dkepath,'remote') && ~isempty(dkepath.remote),% batch calculation of run_lukert
    %
    % BATCH LUKE RUN
    %
    remote = dkepath.remote(1);
    dkeparam.psin_S = [];
    %
    luke_input.id_simul = simul_id;
    luke_input.dkeparam = dkeparam;
    luke_input.dkepath = dkepath;
    luke_input.dkedisplay = dkedisplay;
    luke_input.equil = equil;
    luke_input.waves = [];
    luke_input.wavestructs = wavestructs;
    luke_input.ohm = ohm;
    luke_input.transpfaste = transpfaste;
    luke_input.ripple = ripple;
    luke_input.Zf0_interp = [];
    %
    [timeid,jobid] = runluke_remote_jd(luke_input,remote);
    %
    %w_opt = input_dke_yp('Waiting for remote LUKE results... enter time out (minutes)',60,0:7*24*60);
    w_opt = 240;disp('LUKE time out : 4 hours')
    %
    tic
    %
    output = '';
    %
    while isempty(output) && toc/60 < w_opt,
        %
        disp(['LUKE Still running , elapsed time (minutes) ',num2str(round(toc/60)),'/',num2str(w_opt)])
        %
        pause(30);
        %
        output = getluke_remote_jd(timeid,jobid,remote);
        %
    end
    %
    if isempty(output),
        error(['Stop waiting , elapsed time (minutes) ',num2str(round(toc/60)),'/',num2str(w_opt)])
    elseif isfield(output,'err'),
        error('Remote LUKE run failed, aborted.')
    else
        %
        Znorm_RF = output.Znorm;
        Zcurr_RF = output.Zcurr;
        ZP0_RF = output.ZP0;
        dke_out = output.dke_out;
        radialDKE = output.radialDKE;
        equilDKE = output.equilDKE;
        momentumDKE = output.momentumDKE;
        gridDKE = output.gridDKE;
        Zmomcoef = output.Zmomcoef;
        Zbouncecoef = output.Zbouncecoef;
        Zmripple = output.Zmripple;
        mksa = output.mksa;
        %
        clear output
        %
    end
    %
else
    %
    % INTERACTIVE LUKE RUN
    %
    [Znorm_RF,Zcurr_RF,ZP0_RF,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = run_lukert(simul_id,wavestructs,[],[],dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
    %
end
%
clear raytracing_yp alphaphimex_jd trapz_dke_yp dmumpsmex
%
signe_out = option.signe;
%
j_TOT_c = signe_out*Zcurr_RF.x_0_vcfsav*mksa.j_ref;
I_TOT_c = sum(signe_out*Zcurr_RF.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
p_TOT_c = (ZP0_RF.x_rf_fsav.' + ZP0_RF.x_e_fsav)*mksa.P_ref;
p_RF_c = ZP0_RF.x_rf_fsav.'*mksa.P_ref;
P_TOT_c = sum(p_TOT_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
P_RF_c = sum(p_RF_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
%
% RUN LUKE without RF waves
%
if sum(abs(ohm.epsi)) ~= 0,%Calculate the Ohmic electric field contribution to the plasma current
    %
    simul_id = ['METIS_',equil.id,ohm.id,transpfaste_id];
    %
    [void,Zcurr,ZP0] = run_lukert(simul_id,[],[],[],radialDKE.xrho_S_dke,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
    %
    j_OHM_c = signe_out*Zcurr.x_0_vcfsav*mksa.j_ref;
    I_OHM_c = sum(signe_out*Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
    p_OHM_c = ZP0.x_e_fsav*mksa.P_ref;
    P_OHM_c = sum(p_OHM_c.*equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp);
else
    j_OHM_c = zeros(1,length(j_TOT_c));
    I_OHM_c = 0;
    p_OHM_c = zeros(1,length(p_TOT_c)); 
    P_OHM_c = 0;
end
%
%j_RF_c = j_TOT_c - j_OHM_c;
I_RF_c = I_TOT_c - I_OHM_c;
%p_OHMsyn_c = p_TOT_c - p_OHM_c - p_RF_c;% synergistic power spent on electric field, already accounted for in E.J
P_OHMsyn_c = P_TOT_c - P_OHM_c - P_RF_c;% synergistic power spent on electric field, already accounted for in E.J
%
disp('-----------------');
disp('   LUKE OUTPUT   ');
disp('-----------------');
disp(' ');
disp(['RF + OHM current  : I_TOT = ',num2str(I_TOT_c,3), 'MA']) 
disp(['OHM current       : I_OHM = ',num2str(I_OHM_c,3), 'MA']) 
disp(['RF current (+syn) : I_RF = ',num2str(I_RF_c,3), 'MA']) 
disp(' ');
disp(['RF + OHM power    : P_TOT = ',num2str(P_TOT_c,3), 'MW']) 
disp(['RF power          : P_RF  = ',num2str(P_RF_c,3), 'MW']) 
disp(['OHM power         : P_OHM = ',num2str(P_OHM_c,3), 'MW']) 
disp(['OHM power (+syn)  : P_OHM = ',num2str(P_OHM_c + P_OHMsyn_c,3), 'MW']) 
%
% interpolation onto metis grid
%
psin = (profil0d.psi - profil0d.psi(1))./(profil0d.psi(end) - profil0d.psi(1));
rho_S = [0,(profil0d.xli(1:end-1) + profil0d.xli(2:end))/2,1];
psin_S = interp1(profil0d.xli,psin,rho_S,'linear');
%
psin_S(1) = 0;% to avoid roundoff errors
psin_S(end) = 1;% to avoid roundoff errors
%
psin_S_mix = unique([psin_S,radialDKE.xpsin_S_dke]);
equilDKE_mix = equilibrium_jd(equil,psin_S_mix);
%
nx = length(equilDKE_mix.xpsin);
nr = length(equilDKE.xpsin);
nm = length(psin);
%
pxpsin_S = ones(nx,1)*radialDKE.xpsin_S_dke;
pxpsin_mix = equilDKE_mix.xpsin.'*ones(1,nr);
%
pxprojmat = (pxpsin_mix > pxpsin_S(:,1:nr)) & (pxpsin_mix < pxpsin_S(:,2:nr+1));
if any(sum(pxprojmat.') ~= ones(1,nx)),
    warning('Problem in result interpolation grids')
    keyboard
end
%
pppsin_S = ones(nx,1)*psin_S;
pppsin_mix = equilDKE_mix.xpsin.'*ones(1,nm);
%
ppprojmat = (pppsin_mix > pppsin_S(:,1:nm)) & (pppsin_mix < pppsin_S(:,2:nm+1));
if any(sum(ppprojmat.') ~= ones(1,nx)),
    warning('Problem in result interpolation grids')
    keyboard
end
%
j_TOT_mix = pxprojmat*j_TOT_c.';
j_OHM_mix = pxprojmat*j_OHM_c.';
%
p_TOT_mix = pxprojmat*p_TOT_c.';
p_RF_mix = pxprojmat*p_RF_c.';
p_OHM_mix = pxprojmat*p_OHM_c.';
%
pj_TOT = (ppprojmat.'*(j_TOT_mix.*equilDKE_mix.xdA_dke.'))./(ppprojmat.'*equilDKE_mix.xdA_dke.');
pj_OHM = (ppprojmat.'*(j_OHM_mix.*equilDKE_mix.xdA_dke.'))./(ppprojmat.'*equilDKE_mix.xdA_dke.');
%
pp_TOT = (ppprojmat.'*(p_TOT_mix.*equilDKE_mix.xdV_2piRp_dke.'))./(ppprojmat.'*equilDKE_mix.xdV_2piRp_dke.');
pp_RF = (ppprojmat.'*(p_RF_mix.*equilDKE_mix.xdV_2piRp_dke.'))./(ppprojmat.'*equilDKE_mix.xdV_2piRp_dke.');
pp_OHM = (ppprojmat.'*(p_OHM_mix.*equilDKE_mix.xdV_2piRp_dke.'))./(ppprojmat.'*equilDKE_mix.xdV_2piRp_dke.');
%
output.j_TOT = pj_TOT.'*1e6;
output.j_OHM = pj_OHM.'*1e6;
%
output.I_TOT = I_TOT_c*1e6;
output.I_OHM = I_OHM_c*1e6;
%
output.p_TOT = pp_TOT.'*1e6;
output.p_RF = pp_RF.'*1e6;
output.p_OHM = pp_OHM.'*1e6;
%
output.P_TOT = P_TOT_c*1e6;
output.P_RF = P_RF_c*1e6;
output.P_OHM = P_OHM_c*1e6;
%
output.waves = dke_out.waves;
%
if lukeparam.luke_mode == 1,% save output
    %  
    if auto_mode == 0,
        workdir = uigetdir(pwd,'Select save directory');
        if ~ischar(workdir)
            workdir = pwd;
        end
    else 
        workdir = pwd;
    end
    %
    save([workdir,'/last_luke@',equil_id,'.mat']);
    %
end
%


