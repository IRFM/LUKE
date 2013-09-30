function id_launch = make_launchid_jd(launch)
    %
    if isfield(launch,'id'),
        id_launch = launch.id;
        return
    end
    %
    % create launch id
    %
    id_launch = 'LH';
    %
    id_launch = [id_launch,'_nrZ0_',num2str(length(launch.rZ0))];
    %
    % spectrum
    %
    if isfield(launch,'param_tor'),
        %
        id_launch = [id_launch,'_nl_',num2str(launch.param_tor.nlobes),'_dir_',num2str(launch.param_tor.dir),'_md_',num2str(launch.param_tor.mode)];
        %
    else
        bNpar0str = '';
        bdNpar0str = '';
        bPlhtotstr = '';
        for ib = 1:length(config.bNpar0),
            bNpar0str = [bNpar0str,'_',num2str(real(launch.bNpar0(ib)))];
            bdNpar0str = [bdNpar0str,'_',num2str(launch.bdNpar0(ib))];
            bPlhtotstr = [bPlhtotstr,'_',num2str(launch.bPlhtot(ib)/1e6)];
        end
        %
        id_launch = [id_launch,'_N0',bNpar0str,'_dN0',bdNpar0str,'_PMW',bPlhtotstr];
    end
    %
    % tail
    %
    if isfield(launch,'tail'),
        locid_simul_tail = make_tail_simulid_jd(launch.tail);
        if ~isempty(locid_simul_tail),
            id_launch = [id_launch,'_',locid_simul_tail];
        end
    end
    %
    % local id
    %
    if isfield(launch,'locid') && ~isempty(launch.locid),
        id_launch = [id_launch,'_',launch.locid];
    end
    %
end


