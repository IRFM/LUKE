function [energy,hxr,t,beta,filter_thickness,filter_material,all_hxr_data] = collect_hxr_forLUKE_jd(basestr,shot,opt,data_path)
%
% This function collects HXR experimental data from database
%
all_hxr_data = '';
%
if nargin < 2,
    error('Not enough arguments');
end
%
if nargin < 3,
    opt.R = 1;
    opt.V = 1;
end
%
if strcmp(basestr,'TCV'),
    %
    hxrs_collect_hxr_luke;
    %
    t = t{1};
    energy = energy{1};
    hxr = hxr{1};
    filter_thickness = filter_thickness{1};
    filter_material = filter_material{1};
    %
elseif strcmp(basestr,'TS')
    %
    nk = 8;%number of energy chanels in TS
    energy = (20:20:160).';%energy channels in TS
    nc = 59;%number of chords in TS
    %
    if opt.R == 1,
        pilerej = 'R';
    else
        pilerej = '';
    end
    %
    if opt.V == 1,
        treel = 'V';
    else
        treel = '';
    end
    %
    icstr = cell(1,nc);
    for ic = 1:min([nc,9]),
        icstr{ic} = ['0',num2str(ic)];
    end
    for ic = 10:nc,
        icstr{ic} = num2str(ic);
    end
    %
    for ic = 1:nc
        %
        if ~isempty(icstr{ic})
            %
            hxr_signals(ic) = {['G',treel,pilerej,'X',icstr{ic}]};
            %
        end
        %
    end
    %
    if ischar(shot)
        shot1 = str2num(shot);
    else
        shot1 = shot;
    end
    %
    all_hxr_data = remote_mtsbase(shot1,hxr_signals);
    %
    if isfield(all_hxr_data,'err')
        %
        disp(['WARNING : data not found for shot :',num2str(shot1),', error : ',all_hxr_data.err{3}]);
        %
        energy = [];
        hxr = [];
        t = [];
        beta = [];
        filter_thickness = [];
        filter_material = [];
        %
        return            
    end                
    %
    t = all_hxr_data(1).yout2(:,1);
    %
    nt = size(t,1);
    %
    hxr = zeros(nt,nk,nc);            
    %
    for ic = 1:nc,
        try 
            %
            hxrloc = all_hxr_data(ic).yout1;
            tloc = all_hxr_data(ic).yout2;
            %
            nkloc = size(tloc,2);
            %
            if nkloc < nk,
                disp('WARNING : number of channels read from TS database is less than 8');
            elseif nkloc > nk,
                error('Number of channels read from TS database is more than 8');
            end
            %
            if size(tloc,1) ~= nt || any(tloc(:,1) ~= t),
                for ik = 1:nkloc,
                    hxr(:,ik,ic) = interp1(tloc(:,1),hxrloc(:,ik),t);
                end
            else
                hxr(:,1:nkloc,ic) = hxrloc;
            end                     
        catch
            continue
        end
    end
    %
    if opt.V == 1,
        hxr = flipdim(cumsum(flipdim(hxr,2),2),2);%TS data is per channel (it is not monotonically decreasing)
    end
    %
    filter_thickness = NaN;
    filter_material = NaN;
    beta = NaN;
    %
elseif strcmp(basestr,'WEST')
    %
    nk = 8;%number of energy chanels in WEST
    energy = (20:20:160).';%energy channels in WEST
    nc = 38;%number of chords in WEST (22-> 59)
    %
    for ic = 1:nc
       %
       hxr_signals(ic) = {['GVX',int2str(ic+21)]};%22->59
       %    
    end
    %
    if ischar(shot)
        shot1 = str2num(shot);
    else
        shot1 = shot;
    end
    %
    all_hxr_data = remote_mtsbase(shot1,hxr_signals);
    %
    if isfield(all_hxr_data,'err')
        %
        disp(['WARNING : data not found for shot : ',num2str(shot1),', error : ',all_hxr_data.err{3}]);
        %
        energy = [];
        hxr = [];
        t = [];
        beta = [];
        filter_thickness = [];
        filter_material = [];
        %
        return            
    end                
    %
    flag_empty_signal = 0;
    %
    for iii = 1:length(all_hxr_data)
        %
        if isempty(all_hxr_data(iii).yout1) && isempty(all_hxr_data(iii).yout2) && isempty(all_hxr_data(iii).yout3) && isempty(all_hxr_data(iii).yout4) && isempty(all_hxr_data(iii).yout5)
            %
            flag_empty_signal = flag_empty_signal + 1;
            %
        end
        %
    end
    %
    if flag_empty_signal == length(all_hxr_data)
        %
        disp(['WARNING : data structure is empty for shot : ',num2str(shot1)]);
        %
        energy = [];
        hxr = [];
        t = [];
        beta = [];
        filter_thickness = [];
        filter_material = [];
        %
        return
        %
    end
    %
    t = all_hxr_data(1).yout2(:,1);
    %
    nt = size(t,1);
    %
    hxr = zeros(nt,nk,nc);            
    %
    for ic = 1:nc
        try 
            %
            hxrloc = all_hxr_data(ic).yout1;
            tloc = all_hxr_data(ic).yout2;
            %
            nkloc = size(tloc,2);
            %
            if nkloc < nk,
                disp('WARNING : number of channels read from TS database is less than 8');
            elseif nkloc > nk,
                error('Number of channels read from TS database is more than 8');
            end
            %
            if size(tloc,1) ~= nt || any(tloc(:,1) ~= t),
                for ik = 1:nkloc,
                    hxr(:,ik,ic) = interp1(tloc(:,1),hxrloc(:,ik),t);
                end
            else
                hxr(:,1:nkloc,ic) = hxrloc;
            end                     
        catch
            continue
        end
    end
    %
    hxr = flipdim(cumsum(flipdim(hxr,2),2),2);%TS data is per channel (it is not monotonically decreasing)
    %
    filter_thickness = [];
    filter_material = [];
    beta = [];
    %
else
    %
    t = [];
    energy = [];
    hxr = [];
    filter_thickness = [];
    filter_material = [];
    beta = [];
    %
    disp(['-----> no access to the ',basestr,' database found. Check remote connexion if any.']);
    %
end
%
if nargout == 0,
    %
    if nargin < 4,
        data_path = './';
    end  
    %
    data_file = ['DSPX_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'shot','energy','hxr','t','beta','filter_thickness','filter_material');
    %
end
