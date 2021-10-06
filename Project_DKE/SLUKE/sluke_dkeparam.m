function dkeparam = sluke_dkeparam(sparams,ii)
%

%
dkeparam_id = sluke_id(sparams,ii,'dkeparam');
%
if exist(['SLUKE_KINETICS/DKEPARAM_',dkeparam_id,'.mat'])
    %
    load(['SLUKE_KINETICS/DKEPARAM_',dkeparam_id,'.mat']);
    %
else
    %
    if strcmp(sparams.kinetics.dkeparam.source{ii},'preset')
        %
        load(which(['DKEPARAM_',sparams.kinetics.dkeparam.preset{ii},'.mat']));
        %
    elseif strcmp(sparams.kinetics.dkeparam.source{ii},'file')
        %
        dkeparam_file = sparams.kinetics.dkeparam.file{ii};
        dkeparam_path = sparams.kinetics.dkeparam.path{ii};
        %
        if strcmp(sparams.kinetics.dkeparam.path{ii},'.')
            dkeparam_path = [pwd,'/'];
        else
            if strcmp(sparams.kinetics.dkeparam.path{ii}(end),'/')
                dkeparam_path = sparams.kinetics.dkeparam.path{ii};
            else
                dkeparam_path = [sparams.kinetics.dkeparam.path{ii},'/'];
            end
        end
        %
        data = load([dkeparam_path,dkeparam_file]);
        %
        if isfield(data,'post') % dkeparam from metis simulations
            %
            [dkeparam,~,~,~,~,~,~] = auto_extract_metisdata_for_luke(data.post,1,sparams.discharge.tmin{ii},1);
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.kinetics.dkeparam);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.kinetics.dkeparam.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            dkeparam.source = source;
            clear source
            %
            save(['SLUKE_KINETICS/DKEPARAM_',dkeparam_id,'.mat'],'dkeparam');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.kinetics.dkeparam.source{ii},'value')
        %
        %
    end
end
%
if isfield(sparams.kinetics.dkeparam,'nmhu_S')
    %
    dkeparam.nmhu_S = sparams.kinetics.dkeparam.nmhu_S{ii};%enforced value
    %
end
%
if isfield(sparams.kinetics.dkeparam,'np_S')
    %
    dkeparam.np_S = sparams.kinetics.dkeparam.np_S{ii};%enforced value
    %
end
%
if isfield(sparams.kinetics.dkeparam,'pnmax_S')
    %
    dkeparam.pnmax_S = sparams.kinetics.dkeparam.pnmax_S{ii};%enforced value
    %
end   
%
if isfield(sparams.kinetics.dkeparam,'rho_S')
    %
    dkeparam.rho_S = sparams.kinetics.dkeparam.rho_S{ii};%enforced value
    %
end   
    