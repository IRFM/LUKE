% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [energy,hxr,time] = collect_mehxr_forLUKE_tb(basestr,shot,bin_rows,data_path)
%
% This function collects HXR experimental data from MEHXR database
% 
% author: T. Barbui tbarbui@pppl.gov 2024
%

if nargin < 2,
    error('Not enough arguments');
end

occ = 1; %0 for MESXR, 1 for MEHXR
run = 0; %last data base entry

Nx = 195; %number of pixels in horizontal direction
Ny = 487; %number of pixels in vertical direction

try
    % Open IMAS file: function imas_west_get(shot, ids_name, run, occ, user, machine)
    mesxr_ids = imas_west_get(str2num(shot), 'camera_x_rays',run,occ);
    
    if isempty(mesxr_ids.time)
        %
        disp(['WARNING : MEHXR data not found for shot : ',num2str(shot)]);
        %
        time=[];
        energy=[];
        hxr=[];
        return
    end

    time = mesxr_ids.time;
    nt = numel(time);
    data = zeros(Ny, Nx, nt);
    for t=1:nt
        data(:, :, t) = mesxr_ids.frame{t}.counts_n;
    end
    % Masking edge pixels
    mask = ones(Ny, Nx, nt);
    for idx = [60	61	62	121	122	123	182	183	184	243	244	245	304	305	306	365	366	367	426	427	428 487]
        mask(idx,:,:) = NaN;
    end
    data=data.*mask;

    % Masking bad and miscalibrated pixels
    bad_pxl_mask = ones(Ny, Nx, nt);
    for i=1:nt
        bad_pxl_mask(:,:,i) = mesxr_ids.pixel_status;
    end
    bad_pxl_mask(bad_pxl_mask~=1) = NaN;
    data = data.*bad_pxl_mask;

    % Finds the thresholds and their indeces
    thresholds = unique(mesxr_ids.energy_threshold_lower);
    if numel(thresholds) > 1
        thresholds=thresholds(2:end); %delete threshold = 0keV in multi energy mode
    end
    for index=1:numel(thresholds)
        indexes_threshold{index} = find(mesxr_ids.energy_threshold_lower(:,1)==thresholds(index));
    end

    neth = length(thresholds);

    hxr = cell(nt,neth);
    for t=1:nt
        P = get_profiles(data, t, thresholds, indexes_threshold, bin_rows);
        for i=1:neth
            hxr{t,i}=P{1,i};
        end
    end

    energy=thresholds;
    
catch
    disp(['-----> no access to the ',basestr,' database found. Check remote connexion if any.']);

    time=[];
    energy=[];
    hxr=[];
    return
end

%
if nargout == 0,
    %
    if nargin < 4,
        data_path = './';
    end  
    %
    data_file = ['MEHXR_',basestr,'_',num2str(shot),'.mat'];
    %
    save([data_path,data_file],'shot','energy','hxr','time');
    %
end


function profile = get_profiles(data, ind_t, thresholds, indexes_threshold, bin_rows)
    for en=1:numel(thresholds)
        for j=1:numel(indexes_threshold{en})  
            if bin_rows
                s = sum(~isnan(data(indexes_threshold{en}(j), :, ind_t)));
                if s > 0
                    profile{en}(j)=sum(data(indexes_threshold{en}(j), :, ind_t),2,'omitnan')*195/s;
                else
                    profile{en}(j) = NaN;
                end
            else
                profile{en}(j,:) = data(indexes_threshold{en}(j), :, ind_t);
            end
        end    
    end
end

end
