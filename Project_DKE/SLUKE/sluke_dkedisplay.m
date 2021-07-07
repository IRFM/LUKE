function dkedisplay = sluke_dkedisplay(sparams,ii)
%



%
dkedisplay_id = sluke_id(sparams,ii,'dkedisplay');
%
if exist(['SLUKE_DKEDISPLAYS/DKEDISPLAY_',dkedisplay_id,'.mat'])
    %
    load(['SLUKE_DKEDISPLAYS/DKEDISPLAY_',dkedisplay_id,'.mat']);
    %
else
    %
    if strcmp(sparams.dkedisplay.source{ii},'code')
        %
        %
    elseif strcmp(sparams.dkedisplay.source{ii},'file')
        %
        dkedisplay_file = sparams.dkedisplay.file{ii};
        dkedisplay_path = sparams.dkedisplay.path{ii};
        %
        if strcmp(sparams.dkedisplay.path{ii},'.')
            dkedisplay_path = [pwd,'/'];
        else
            if strcmp(sparams.dkedisplay.path{ii}(end),'/')
                dkedisplay_path = sparams.dkedisplay.path{ii};
            else
                dkedisplay_path = [sparams.dkedisplay.path{ii},'/'];
            end
        end
        %
        data = load([dkedisplay_path,dkedisplay_file]);
        %
        if isfield(data,'post') % dkedisplay from metis simulations
            %
            [~,dkedisplay,~,~,~,~,~] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii},1);
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.dkedisplay);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.dkedisplay.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            dkedisplay.source = source;
            clear source
            %
            save(['SLUKE_DKEDISPLAYS/DKEDISPLAY_',dkedisplay_id,'.mat'],'dkedisplay');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.dkedisplay.source{ii},'value')
        %
        %
    end
end

    
    
    