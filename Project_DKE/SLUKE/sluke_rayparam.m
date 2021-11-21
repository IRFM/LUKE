function dkeparam = sluke_rayparam(sparams,ii)
%



%
rayparam_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_RAYPARAMS/RAYPARAM_',rayparam_id,'.mat'])
    %
    load(['SLUKE_RAYPARAMS/RAYPARAM_',rayparam_id,'.mat']);
    %
else
    %
    if strcmp(sparams.rayparam.source{ii},'file')
        %
        rayparam_file = sparams.rayparam.file{ii};
        rayparam_path = sparams.rayparam.path{ii};
        %
        if strcmp(sparams.rayparam.path{ii},'.')
            rayparam_path = [pwd,'/'];
        else
            if strcmp(sparams.rayparam.path{ii}(end),'/')
                rayparam_path = sparams.rayparam.path{ii};
            else
                rayparam_path = [sparams.rayparam.path{ii},'/'];
            end
        end
        %
        data = load([rayparam_path,rayparam_file]);
        %
        if isfield(data,'post') % rayparam from metis simulations
            %
            [~,~,~,~,~,~,wavestructs] = auto_extract_metisdata_for_luke(data.post,1,sparams.discharge.tmin{ii},1);
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.rayparam);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.rayparam.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            rayparam.source = source;
            clear source
            %
            save(['SLUKE_RAYPARAMS/RAYPARAM_',rayparam_id,'.mat'],'rayparam');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.rayparam.source{ii},'value')
        %
        
        
        
        
        %
    end
end

    
    
    