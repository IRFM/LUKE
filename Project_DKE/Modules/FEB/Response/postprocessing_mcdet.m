%
clc
close all
clear all
%
det = {'YAP:Ce','LYSO','BGO','NaI','CsI','CdTe'};%for display
det = {'YAP:Ce','CdTe'};%for display
det = {'YAP:Ce','LYSO'};%for display
det = {'YAP:Ce','LYSO','BGO'};%for display
%
% YAP:Ce
%
fid = fopen('rmcdet.data.yap');
tline = fgetl(fid);
%
i = 1;
j = 1;
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_yap(j) = str2num(c{2});
            n_yap(j) = str2num(c{3});
        else
            e_yap(j) = str2num(c{1});
            n_yap(j) = str2num(c{2});
        end
        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
% LYSO
%
fid = fopen('rmcdet.data.lyso');
tline = fgetl(fid);
%
i = 1;
j = 1;
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_lyso(j) = str2num(c{2});
            n_lyso(j) = str2num(c{3});
        else
            e_lyso(j) = str2num(c{1});
            n_lyso(j) = str2num(c{2});
        end
        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
% BGO
%
fid = fopen('rmcdet.data.bgo');
tline = fgetl(fid);
%
i = 1;
j = 1;
%
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_bgo(j) = str2num(c{2});
            n_bgo(j) = str2num(c{3});
        else
            e_bgo(j) = str2num(c{1});
            n_bgo(j) = str2num(c{2});
        end

        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
% CdTe
%
fid = fopen('rmcdet.data.cdte');
tline = fgetl(fid);
%
i = 1;
j = 1;
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_cdte(j) = str2num(c{2});
            n_cdte(j) = str2num(c{3});
        else
            e_cdte(j) = str2num(c{1});
            n_cdte(j) = str2num(c{2});
        end
        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
% nai
%
fid = fopen('rmcdet.data.nai');
tline = fgetl(fid);
%
i = 1;
j = 1;
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_nai(j) = str2num(c{2});
            n_nai(j) = str2num(c{3});
        else
            e_nai(j) = str2num(c{1});
            n_nai(j) = str2num(c{2});
        end
        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
% csi
%
fid = fopen('rmcdet.data.csi');
tline = fgetl(fid);
%
i = 1;
j = 1;
while ischar(tline)
    %
    if i >= 33 && i <=132
        %disp([int2str(i),'--> ',tline])
        c = strsplit(tline);
        if length(c) == 3
            e_csi(j) = str2num(c{2});
            n_csi(j) = str2num(c{3});
        else
            e_csi(j) = str2num(c{1});
            n_csi(j) = str2num(c{2});
        end
        j = j+1;
    end
    %
    tline = fgetl(fid);
    i = i + 1;
    %
end
%
fclose(fid);
%
mn_yap = max(n_yap);
mn_lyso = max(n_lyso);
mn_bgo = max(n_bgo);
mn_nai = max(n_nai);
mn_csi = max(n_csi);
mn_cdte = max(n_cdte);
%
mm = max([mn_yap,mn_lyso,mn_bgo,mn_nai,mn_csi,mn_cdte]);
%
leg = '';
%
j = 1;
for ii = 1:length(det)
    if strcmp(det{ii},'YAP:Ce')
        dE = diff(e_yap);
        plot(e_yap,n_yap/dE(1),'r-','LineWidth',3),hold on;leg =   [leg;'YAP:Ce'];
        mn(j) = max(n_yap/dE(1));j = j+1;
    end
    %
    if strcmp(det{ii},'LYSO')
        dE = diff(e_lyso);
        plot(e_lyso,n_lyso/dE(1),'b-','LineWidth',1),hold on;leg = [leg;'LYSO  '];
        mn(j) = max(n_lyso/dE(1));j = j+1;
    end
    %
    if strcmp(det{ii},'BGO')
        dE = diff(e_bgo);
        plot(e_bgo,n_bgo/dE(1),'g-','LineWidth',1),hold on;leg =   [leg;'BGO   '];
        mn(j) = max(n_bgo/dE(1));j = j+1;
    end
    if strcmp(det{ii},'NaI')
        dE = diff(e_nai);
        plot(e_nai,n_nai/dE(1),'r--','LineWidth',1),hold on;leg =  [leg;'NaI   '];
        mn(j) = max(n_nai/dE(1));j = j+1;
    end
    if strcmp(det{ii},'CsI')
        dE = diff(e_csi);
        plot(e_csi,n_csi/dE(1),'b--','LineWidth',1),hold on;leg =  [leg;'CsI   '];
        mn(j) = max(n_csi/dE(1));j = j+1;
    end
    if strcmp(det{ii},'CdTe')
        dE = diff(e_cdte);
        plot(e_cdte,n_cdte/dE(1),'g--','LineWidth',1),hold on;leg = [leg;'CdTe  '];
        mn(j) = max(n_cdte/dE(1));j = j+1;
    end
end
%
axis([0 2500, 0, max(mn)])
xlabel('Pulse energy (keV)')
ylabel('dn/dE (keV^{-1})')
title('Incoming photon energy 2 MeV')
%
%legend('YAP:Ce','LYSO','BGO','NaI','CsI','CdTe','Location','NorthWest')
legend(leg,'Location','NorthWest')
%
grid minor
