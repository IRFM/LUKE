%
% script iluke_run to run and check luke runs
%
if lukeobj.remote.timeout.value == 1,
    dkepath.remtimout = 0;
else
    dkepath.remtimout = 60*24;
end
%
dkepath.rempause = 1;
dkepath.debugmode = 0;
dkepath.clean = 2;
%
if strcmp(action,'lukestart'),
    %
    lukestructs = struct;
    %
    lukestructs.simul.id = lukeobj.lukeid.string;
    lukestructs.dkeparam = dkeparam;
    lukestructs.dkedisplay = dkedisplay;
    %
    lukestructs.equil = equil;
    lukestructs.ohm = ohm;
    lukestructs.transpfaste = transpfaste;
    lukestructs.ripple = ripple;
    lukestructs.waves = waves;
    %
    dkepath.remnum = lukeobj.remote.select.value - 1;
    %
    if dkepath.remnum == 0,% local calculation
        lukestructs.simul.path = workdir;
    end        
    %
    if dkepath.remnum == 0 || dkepath.remtimout > 0,
        lukeobj.lukechecktext.string = 'LUKE started. Please wait for result.';
        iluke_update_state(lukeobj);
    end
    %
    status.data = 2;
    %
elseif strcmp(action,'runcheck'),
    %
    nrem = length(dkepath.remote);
    %
    flag = false(1,nrem);
    %
    for irem = 1:nrem,
        if comp_struct_jd(dkepath.remote(irem),job.remote,0,{},{'host','cmd'}),
            flag(irem) = true;
        end
    end
    %
    if sum(flag) == 0,
        error('Remote profile from job cannot be found in dkepath. aborted.')
    elseif sum(flag) > 1,
        disp('WARNING : more than one remote profile from dkepath found to be compatible with job.remote. First choice selected.')
    end
    %
    dkepath.remnum = find(flag,1,'first');
    %
    lukeobj.remote.select.value = dkepath.remnum + 1;
    %
    lukestructs.job = job;
    %
    job = '';
    %
    clear flag irem nrem
    %
end
%    
% run or check luke
%
set(lukeobj.busy.handle,'Visible','on');drawnow;
%
lukestructs = run_lukert(lukestructs,dkepath);
%
set(lukeobj.busy.handle,'Visible','off');drawnow;
%
% manange output
%
if isfield(lukestructs,'job'),
    %
    job = lukestructs.job;
    %
    action = 'lukerun';iluke_callbacks;
    %
elseif isfield(lukestructs,'err'),
    %
    lukeobj.infotext.string = {'Error running LUKE : ',lukestructs.err};
    %
    lukeobj = iluke_info(lukeobj,'text');% enable info display
    %    
elseif isfield(lukestructs,'output'),
    %
    output = lukestructs.output;
    %
    status.output = 1;
    status.data = 2;
    %
    lukeobj.luke.text.string = lukestructs.simul.id;
    %
    opt.save = 0;
    opt.nr_dep = 0;
    opt.spec = 0;
    opt.its_rf = 0;
    opt.peak = 'n';
    opt.wave = 'n';
    opt.rho = 't'; 
    opt.blist = [];
    opt.diaryname = '';
    opt.peakmode = 1;
    %
    data_proc = proc_luke_jd(output,-1,-1,0.1,NaN,'',opt);
    %
    flag_rf = data_proc.scalar.p0_rf_2piRp ~= 0;
    %
    output.info.txt = {...
            ['Total current       : ',num2str(data_proc.scalar.I_tot),' MA (positive for co-current)'],...
            ['Current peak r/a    : ',num2str(data_proc.scalar.jrhoT),' (square root of toroidal flux)'],...
            ['Current FWHM        : ',num2str(data_proc.scalar.jdrhoT),' (square root of toroidal flux)']};
    if flag_rf,
        output.info.txt = [output.info.txt,...
            ['RF conv. param.    : ',num2str(data_proc.simul.residue_rf)]];
    end
    %
    if isinf(data_proc.scalar.Rp),
        if flag_rf,
            output.info.txt = [output.info.txt,...
            ['Launched RF power   : ',num2str(data_proc.scalar.p0_rf_2piRp),' MW/m (P/2piRp)'],...
            ['Absorbed RF power   : ',num2str(data_proc.scalar.p_rf_2piRp),' MW/m ---> ',num2str(100*data_proc.scalar.p_rf_2piRp/data_proc.scalar.p0_rf_2piRp),' %. (P/2piRp)']];
            for in_rf = 1:length(data_proc.scalar.n_rf_list),
                output.info.txt = [output.info.txt,...
            ['RF power on harm. ',num2str(data_proc.scalar.n_rf_list(in_rf)),' : ',num2str(data_proc.scalar.np_rf_2piRp(in_rf)),' MW/m ---> ',num2str(100*data_proc.scalar.np_rf_2piRp(in_rf)/data_proc.scalar.p0_rf_2piRp),' %. (P/2piRp)']];
            end
            if opt.nr_dep >= 0,
                output.info.txt = [output.info.txt,...
            ['Linear RF power     : ',num2str(data_proc.scalar.p_rf_2piRp_lin),' MW/m ---> ',num2str(100*data_proc.scalar.p_rf_2piRp_lin/data_proc.scalar.p0_rf_2piRp),' %. (P/2piRp)']];
            end
        end
        %
        output.info.txt = [output.info.txt,...
            ['Ohmic power         : ',num2str(data_proc.scalar.p_e_2piRp),' MW/m (P/2piRp)'],...
            ['Total power         : ',num2str(data_proc.scalar.p_tot_2piRp),' MW/m (P/2piRp)'],...
            ['CD efficiency       : ',num2str(data_proc.scalar.EtaRp),' A.m/W (I*Rp/P)']];
    else
        if flag_rf,
            output.info.txt = [output.info.txt,...
            ['Launched RF power   : ',num2str(data_proc.scalar.p0_rf_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'],...
            ['Absorbed RF power   : ',num2str(data_proc.scalar.p_rf_2piRp*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.p_rf_2piRp/data_proc.scalar.p0_rf_2piRp),' %.']];
            for in_rf = 1:length(data_proc.scalar.n_rf_list),
                output.info.txt = [output.info.txt,...
            ['RF power on harm. ',num2str(data_proc.scalar.n_rf_list(in_rf)),' : ',num2str(data_proc.scalar.np_rf_2piRp(in_rf)*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.np_rf_2piRp(in_rf)/data_proc.scalar.p0_rf_2piRp),' %.']];
            end
            if opt.nr_dep >= 0,
                output.info.txt = [output.info.txt,...
            ['Linear RF power     : ',num2str(data_proc.scalar.p_rf_2piRp_lin*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.p_rf_2piRp_lin/data_proc.scalar.p0_rf_2piRp),' %.']];
            end
        end
        %
        output.info.txt = [output.info.txt,...
            ['Ohmic power         : ',num2str(data_proc.scalar.p_e_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'],...
            ['Total power         : ',num2str(data_proc.scalar.p_tot_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'],...
            ['CD efficiency       : ',num2str(data_proc.scalar.EtaRp/data_proc.scalar.Rp),' A/W (I/P)']];
    end
    %
    if flag_rf,
        output.info.txt = [output.info.txt,...
                ['RF efficiency       : ',num2str(data_proc.scalar.EtaRFRp),' 10^19 A/(W.m^2) (n_19*I*Rp/PRF)']];
    end
    %
    action = 'lukedisp';iluke_callbacks;
    %
    lukeobj = iluke_info(lukeobj,'text');% enable info display
    %
end
%
clear lukestructs
%
    
    






