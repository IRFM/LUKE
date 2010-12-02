function [energy,hxr,t,beta,filter_thickness,filter_material] = collect_hxr_forLUKE_jd(basestr,shot,opt,data_path)
%
% This function collects HXR experimental data from database
%
if nargin < 2,
    error('Not enough arguments');
end
%
if nargin < 3,
    opt = 1;
end
%
t = NaN;
energy = NaN;
hxr = NaN;
filter_thickness = NaN;
filter_material = NaN;
beta = NaN;
%
if strcmp(basestr,'TCV'),
    %
    collect_hxr;
    %
    t = t{1};
    energy = energy{1};
    hxr = hxr{1};
    filter_thickness = filter_thickness{1};
    filter_material = filter_material{1};
    %
elseif strcmp(basestr,'TS') && exist('tsbase','file'),
    %
    nk = 8;%number of energy chanels in TS
    energy = (20:20:160).';%energy channels in TS
    nc = 59;%numver of chords in TS
    %
    if opt == 1,
        pilerej = 'R';
    else
        pilerej = '';
    end
    %
    [hxr01,t] = tsbase(shot,['GV',pilerej,'X01']);
    %
    if isempty(hxr01),
        disp(['-----> hxr data not found for shot :',num2str(shot)]);
        return            
    end                
    %
    nt = size(t,1);
    %
    t = t(:,1);
    %
    hxr = zeros(nt,nk,nc);            
    %
    icstr = cell(1,nc);
    for ic = 1:min([nc,9]),
        icstr{ic} = ['0',num2str(ic)];
    end
    for ic = 10:nc,
        icstr{ic} = num2str(ic);
    end
    %
    for ic = 1:nc,
        try 
            [hxrloc,tloc] = tsbase(shot,['GV',pilerej,'X',icstr{ic}]);
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
else
    %
    disp(['-----> no access to the ',basestr,' database found.']);
    %
end
%
if nargout == 0,
    %
    if nargin < 4,
        data_path = './';
    end  
    %
    data_file = ['HXREXP_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'shot','energy','hxr','t','beta','filter_thickness','filter_material');
    %
end
