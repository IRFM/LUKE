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
function [] = sluke_display_wave(equil,output,waves)



%
nw = length(waves);
%
if ~isempty(strfind(equil.id,'TCV'))
    g_opt.vessel_opt = input_dke_yp('Do you want to display TCV vessel and tiles','y',{'y','n'});
else
    g_opt.vessel_opt = 'n';
end
%
w_list = input_dke_yp('List of waves to display',1:nw,[1;nw],'');
%
g_opt.luke = input_dke_yp('Do you want to show waves using LUKE absorption (n/y)','y',{'n','y'}) == 'y';
%
if g_opt.luke
    %
    for iw = w_list
        %
        if ~isfield(waves{iw},'simul') || ~comp_struct_jd(waves{iw}.simul,output.dke_out.simul,0)
            %
            if isfield(waves{iw},'simul')
                %
                disp(['WARNING : LUKE data in wave # ',num2str(iw),' outdated, recalculating...'])
                %
            else
                %
                disp(['WARNING : LUKE data in wave # ',num2str(iw),' missing, calculating now...'])
                %
            end                         
            %
        end
        %
    end
    %
    waves = proc_wave_alphaphi_luke_jd(output,waves,1);
    %                       
else
    %
    g_opt.luke = false;
    %
end          
%
waves(w_list) = proc_wave_alphaphi_luke_jd('',waves(w_list),0);%tmp command to correct old waves
%
nr_dep = 40;
rho_disp = 0:0.1:1;
%
if length(w_list) == 1 && input_dke_yp('Do you want to split the wave into subwaves (n/y)','n',{'n','y'}) == 'n'
    %
    wave = waves{w_list};
    nrays = length(wave.rays);
    %
    if strcmp(wave.rayinit.launch.type,'LH') && input_dke_yp('Do you want to define the subwaves by initial lobe?','y',{'n','y'}) == 'y'
        %
        raygroups = repmat({[]},[1,length(wave.rayinit.launch.bNpar0)]);
        %
        for iray = 1:nrays
            %
            raygroups{find(wave.rays{iray}.rayinits{1}.yNpar0 == wave.rayinit.launch.bNpar0,1,'first')}(end+1) = iray;
            %
        end
        %
    elseif strcmp(wave.rayinit.launch.type,'LH') && input_dke_yp('Do you want to define the subwaves by initial vertical position?','y',{'n','y'}) == 'y',
        %
        % TODO
        %
    elseif strcmp(wave.rayinit.launch.type,'EC')
        %
        raygroups = {1};
        %
    else
        %
        keyboard;%raygroups = {1:24,25:48,49:72,73:96};%input_dke_yp(['Please regroup the ',num2str(nrays),' rays in cells of arrays'],{1:nrays});
        %
    end      
    %
    dispwaves = {};
    %
    for iw = 1:length(raygroups)
        %
        if ~isempty(raygroups{iw})
            %
            dispwaves{end+1} = wave;
            dispwaves{end}.id = [dispwaves{end}.id,'_',num2str(iw)];
            dispwaves{end}.rays = dispwaves{end}.rays(raygroups{iw});
            %
        end
        %
    end
    %
    w_list = input_dke_yp('List of subwaves to display',1:length(dispwaves),[1;length(dispwaves)],'');
    %
    dispwaves = dispwaves(w_list);
    %
else
    dispwaves = waves(w_list);
end
%
ymask = NaN;
%
graph_wave_jd(equil,dispwaves,nr_dep,g_opt,rho_disp,ymask);











for iw = w_list
    %
    if ~isfield(waves{iw},'simul') || ~comp_struct_jd(waves{iw}.simul,output.dke_out.simul,0)
        %
        if isfield(waves{iw},'simul')
            %
            disp(['WARNING : LUKE data in wave # ',num2str(iw),' outdated, recalculating...'])
            %
        else
            %
            disp(['WARNING : LUKE data in wave # ',num2str(iw),' missing, calculating now...'])
            %
        end        
        %
    end
end
%
waves = proc_wave_alphaphi_luke_jd(output,waves,1);%Calculate  LUKE absorption
% 
waves(w_list) = proc_wave_alphaphi_luke_jd('',waves(w_list),0);%tmp command to correct old waves
%
nr_dep = 40;%for display
rho_disp = 0:0.1:1;%for display
%
if length(w_list) == 1 && input_dke_yp('Do you want to split the wave into subwaves (n/y)','n',{'n','y'}) == 'n',
    %
    wave = waves{w_list};
    nrays = length(wave.rays);
    %{
    if strcmp(wave.rayinit.launch.type,'LH') && input_dke_yp('Do you want to define the subwaves by initial lobe?','y',{'n','y'}) == 'y',
        raygroups = repmat({[]},[1,length(wave.rayinit.launch.bNpar0)]);
        for iray = 1:nrays,
            raygroups{find(wave.rays{iray}.rayinits{1}.yNpar0 == wave.rayinit.launch.bNpar0,1,'first')}(end+1) = iray;
        end
    else%if strcmp(wave.rayinit.launch.type,'LH') && input_dke_yp('Do you want to define the subwaves by initial vertical position?','y',{'n','y'}) == 'y',
        % TODO
    %else
        keyboard;%raygroups = {1:24,25:48,49:72,73:96};%input_dke_yp(['Please regroup the ',num2str(nrays),' rays in cells of arrays'],{1:nrays});
    end      
    %
                        dispwaves = {};
                        for iw = 1:length(raygroups),
                            if ~isempty(raygroups{iw}),
                                dispwaves{end+1} = wave;
                                dispwaves{end}.id = [dispwaves{end}.id,'_',num2str(iw)];
                                dispwaves{end}.rays = dispwaves{end}.rays(raygroups{iw});
                            end
                        end
    %}
   % w_list = input_dke_yp('List of subwaves to display',1:length(dispwaves),[1;length(dispwaves)],'');
   % dispwaves = dispwaves(w_list);
   dispwaves = waves(w_list);
    %
else
    %
    dispwaves = waves(w_list);
    %
end
%
ymask = NaN;
%
graph_wave_jd(equil,dispwaves,nr_dep,g_opt,rho_disp,ymask);
                   