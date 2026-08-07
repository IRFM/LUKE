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


