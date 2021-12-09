close all
clear all
clc
%
remote_enforce = 0;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
shotnumber = 45525;%45525*1i;%shot number (real number for waiting results or imaginary number for giving hand after launching function and getting back data later) or data structure (with or without job for remote calculations)
%
if isreal(shotnumber)
    disp('Mode : waiting for results.')
    data = remote_mtsbase(shotnumber,{'gphyb','sipmes','svsur'},remote_enforce);%
else
    disp('Mode : give hand back.')
    data = remote_mtsbase(shotnumber,{'gphyb','sipmes','svsur'},remote_enforce);%
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
    disp(['ERROR -> ',data.err])
else
    %
    if isfield(data(1),{'yout1','yout2'})
        phyb = data(1).yout1;
        thyb = data(1).yout2;
        subplot(3,1,1),plot(thyb,phyb);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
    end
    %
    if isfield(data(2),{'yout1','yout2'})
        sipmes = data(2).yout1;
        tsipmes = data(2).yout2;
        subplot(3,1,2),plot(tsipmes,sipmes);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Plasma current (MA)');
    end
    %
    if isfield(data(3),{'yout1','yout2'})
        svsur = data(3).yout1;
        tsvsur = data(3).yout2;
        subplot(3,1,3),plot(tsvsur,svsur);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Surface voltage (V)');axis([min(tsvsur),max(tsvsur),-1,1])
    end
end
