function sluke_save(sparams,ii,lukestructs)
%
simul_id = sluke_id(sparams,ii);
%
if isfield(lukestructs,'job')
    %
    save(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'lukestructs');
    %
else
    %
    lukestructs_properties = whos('lukestructs');
    %
    if isfield(sparams.simul,'output') && (sparams.simul.output{ii} == 0 || sparams.simul.output{ii} == 3)
        %
        if isfield(lukestructs,'output') && ~isempty(lukestructs.output)
            status.output = 1;
            output = lukestructs.output;
            %
            if ~exist('waves','var') || isempty(waves)
                %
                if isfield(lukestructs.output,'dke_out') && isfield(lukestructs.output.dke_out,'waves') && ~isempty(lukestructs.output.dke_out.waves)
                    %
                    status.waves = 1;
                    fileids.waves = '';
                    waves = output.dke_out.waves;
                    output.dke_out = rmfield(output.dke_out,'waves');
                    %
                else
                    status.waves = 0;
                    fileids.waves = '';
                    waves = '';
                end
            else
                %
                status.waves = 1;
                fileids.waves = '';
                %
            end
            %
        else
            status.output = 0;
            output = '';
            status.waves = 0;
            fileids.waves = '';
            waves = '';
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
        if isfield(lukestructs,'dkedisplay') && ~isempty(lukestructs.dkedisplay)
            status.dkedisplay = 1;
            fileids.dkedisplay = '';
            dkedisplay = lukestructs.dkedisplay;
        else
            status.dkedisplay = 0;
            fileids.dkedisplay = '';
            dkedisplay = '';
        end
        %
        status.external = 0;
        fileids.external = '';
        %
        status.data = 2;
        %
        basestr = sparams.machine{ii};
        %
        save(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'basestr','simul_id','sparams','status','fileids','output','dkeparam','dkedisplay','equil','ohm','waves','transpfaste','ripple');
        %
        cprintf('*green',['---> is completed. Full simulation data are saved (',num2str(round(lukestructs_properties.bytes/1e9*100)/100),' GBytes)']);disp(' ')
        %
    else
        %
        cprintf('*green',['---> is completed and processed results are saved.']);disp(' ')
        %
        if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'file')
            %
            delete(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
            %
        end
        %
    end
    %
    %Save data for looping if needed
    nit = length(sparams.simul.initial_distribution);
    if sparams.simul.initial_distribution{ii} < 0 && ii < nit && ...
            sparams.simul.initial_distribution{ii} == sparams.simul.initial_distribution{ii+1};
        % Current distribution is part of a loop (1st condition), is not the last
        % simulation (2nd condition) and is not the last of a series (3th
        % condition) %RS
        radialDKE = lukestructs.radialDKE;
        momentumDKE = lukestructs.momentumDKE;
        gridDKE     = lukestructs.gridDKE;
        equilDKE    = lukestructs.gridDKE;
        XXf0        = lukestructs.XXf0;
        save(['SLUKE_RESULTS/ITER_LUKE_DATA_',simul_id,'.mat'],'radialDKE',...
            'momentumDKE','gridDKE','equilDKE','XXf0');
    end
end



