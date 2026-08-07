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
close all
clear all
clc
%
shotnumber = 32299;%45525*1i;%shot number (real number for waiting results or imaginary number for giving hand after launching function and getting back data later) or data structure (with or without job for remote calculations)
%
tsclean(shotnumber);
%
data_list = {'GHXR3',      'GPROFCHKVSPX%1', 'GPROFILEVSPX', 'GPROFNEFIT', ...
            'GPROFTEFIT', 'SCIONBRAG',      'SDEPLW',       'SHAUTTOR',   ...
            'SPROFIP',    'gbilan%11',      'gbilan',       'gfluxnoy%4', ...
            'gnl',        'gphyb'           'gplasma',      'gptore',     ...
            'gpuifci',    'gqbeli',         'grho',         'gshr',       ...
            'gshtenv',    'sdeb',           'sika1',        'sipmes',     ...
            'sitor',      'snli',           'snmoy',        'spiq',       ...
            'sprad',      'stebrag',        'stibrag',      'szfbrm',     ...
            'svsur'};
%
if isreal(shotnumber) 
    %
    disp('Mode : waiting for results.')
    data = remote_mtsbase(shotnumber,data_list);
    %
else
    %
    disp('Mode : give hand back.')
    data = remote_mtsbase(shotnumber,data_list);%
    %
    while 1
        %
        data = remote_mtsbase(data);%
        %
        if ~isfield(data,'job')
            break
        end
    end
    %
end
%
if isfield(data,'err')
    %
    disp(['ERROR -> ',data.err])
    %
else
    %
    if isfield(data(1),{'yout1','yout2'})
        %
        phyb = data(14).yout1;
        thyb = data(14).yout2;
        subplot(3,1,1),plot(thyb,phyb);title(['Tore Supra, shot #',int2str(shotnumber)]),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
        %
    end
    %
    if isfield(data(2),{'yout1','yout2'})
        %
        sipmes = data(24).yout1;
        tsipmes = data(24).yout2;
        subplot(3,1,2),plot(tsipmes,sipmes);title(['Tore Supra, shot #',int2str(shotnumber)]),xlabel('Time (s)');ylabel('Plasma current (MA)');
        %
    end
    %
    if isfield(data(3),{'yout1','yout2'})
        %
        svsur = data(33).yout1;
        tsvsur = data(33).yout2;
        subplot(3,1,3),plot(tsvsur,svsur);title(['Tore Supra, shot #',int2str(shotnumber)]),xlabel('Time (s)');ylabel('Surface voltage (V)');axis([min(tsvsur),max(tsvsur),-1,1])
        %
    end
end
