%
% test script for building LAUNCHS structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
close all
clear all
clc
%
disp('-------------------------------')
disp('Test ALOHA calculation remotely')
disp('-------------------------------')
%
sparams = sluke_params_preset('TEST_ALOHA');%simulation parameters
%
[err,status] = sluke_params_consistency(sparams);
%
if ~err
    %
    if strcmp(input_dke_yp('Change remote profile of the computer on which ALOHA calculations will be perfomed (y/n)','n',{'y','n'}),'y')
        %
        dispremoteprofiles('','scheduler');
        %
        disp('---------------------------------------------')
        disp(' ')
        %
        sparams = sluke_params_modify(sparams);
        %
    end
    %
    for ii = 1:length(sparams.machine)
        %
        for kk = 1:length(sparams.rfwaves.antenna.type{ii})
            %
            launchs{ii}{kk} = sluke_build_launchs(sparams,ii,kk);
            %
        end
        %
    end
    %
end
%


