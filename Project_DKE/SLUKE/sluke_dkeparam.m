function dkeparam = sluke_dkeparam(sparams,ii)
%



%
dkeparam_id = sluke_id(sparams,ii,'dkeparam');
%
if exist(['SLUKE_DKEPARAMS/DKEPARAM_',dkeparam_id,'.mat'])
    %
    load(['SLUKE_DKEPARAMS/DKEPARAM_',dkeparam_id,'.mat']);
    %
else
    %
    if strcmp(sparams.dkeparam.source{ii},'preset')
        %
        load(which(['DKEPARAM_',sparams.dkeparam.preset{ii},'.mat']));
        %
    elseif strcmp(sparams.dkeparam.source{ii},'file')
        %
        dkeparam_file = sparams.dkeparam.file{ii};
        dkeparam_path = sparams.dkeparam.path{ii};
        %
        if strcmp(sparams.dkeparam.path{ii},'.')
            dkeparam_path = [pwd,'/'];
        else
            if strcmp(sparams.dkeparam.path{ii}(end),'/')
                dkeparam_path = sparams.dkeparam.path{ii};
            else
                dkeparam_path = [sparams.dkeparam.path{ii},'/'];
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
            fns = fieldnames(sparams.dkeparam);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.dkeparam.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            dkeparam.source = source;
            clear source
            %
            save(['SLUKE_DKEPARAMS/DKEPARAM_',dkeparam_id,'.mat'],'dkeparam');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.dkeparam.source{ii},'value')
        %
        %
    end
end

    
    
    