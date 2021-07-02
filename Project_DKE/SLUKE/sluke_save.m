function sluke_save(basestr,id_simul,lukestructs)
%
if isfield(lukestructs,'job')
    %
    save(['SLUKE_RESULTS/LUKE_DATA_',id_simul,'.mat'],'lukestructs');
    %
else
    %
    if isfield(lukestructs,'output') && ~isempty(lukestructs.output)
        status.output = 1;
        output = lukestructs.output;
    else
        status.output = 0;
        output = '';
    end
    %
    if isfield(lukestructs,'dkeparam') && ~isempty(lukestructs.dkeparam)
        status.dkeparam = 1;
        fileids.dkeparam = '';
        dkeparam = lukestructs.dkeparam;
    else
        status.dkeparam = 0;
        fileids.dkeparam = '';
        dkeparam = '';
    end
    %
    if isfield(lukestructs,'equil') && ~isempty(lukestructs.equil)
        status.equil = 1;
        fileids.equil = '';
        equil = lukestructs.equil;
    else
        status.equil = 0;
        fileids.equil = '';
        equil = '';
    end
    %
    if isfield(lukestructs,'ohm') && ~isempty(lukestructs.ohm)
        status.ohm = 1;
        fileids.ohm = '';
        ohm = lukestructs.ohm;
    else
        status.ohm = 0;
        fileids.ohm = '';
        ohm = '';
    end
    %
    if isfield(lukestructs,'waves') && ~isempty(lukestructs.waves)
        status.waves = 1;
        fileids.waves = '';
        waves = lukestructs.waves;
    else
        status.waves = 0;
        fileids.waves = '';
        waves = '';
    end
    %
    if isfield(lukestructs,'transpfaste') && ~isempty(lukestructs.transpfaste)
        status.transpfaste = 1;
        fileids.transpfaste = '';
        transpfaste = lukestructs.transpfaste;
    else
        status.transpfaste = 0;
        fileids.transpfaste = '';
        transpfaste = '';
    end
    %
    if isfield(lukestructs,'ripple') && ~isempty(lukestructs.ripple)
        status.ripple = 1;
        fileids.ripple = '';
        ripple = lukestructs.ripple;
    else
        status.ripple = 0;
        fileids.ripple = '';
        ripple = '';
    end
    %
    dkedisplay = lukestructs.dkedisplay;
    %
    status.external = 0;
    fileids.external = '';
    %
    status.data = 2;
    %
    save(['SLUKE_RESULTS/LUKE_DATA_',id_simul,'.mat'],'id_simul','basestr','lukestructs','status','fileids','output','dkeparam','dkedisplay','equil','ohm','waves','transpfaste','ripple');
    %
end

