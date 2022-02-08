function sluke_params_help
%
clc
%
disp('---------------------------------------------------------------------------------------------')
disp('--------------------------------------- HELP OF SLUKE ---------------------------------------')
disp('---------------------------------------------------------------------------------------------')
%
disp('SLUKE is a scriptable interface of the LUKE suite of codes designed to simulate the dynamics ')
disp('of a fast electron population pulled out from the thermal bulk either inductively by a       ')
disp('constant electric field, or by an oscillatory one produced by propagating radio-frequency RF ')
disp('waves. It allows multi-machine, multi-shot time-dependent simulations in a single script.')
disp(' ')
disp('In order to run SLUKE, the following toolboxes must be installed : LUKE_LHCD, MatRemote,     ')
disp('MatTools, MatHelp. For studying the Lower Hybrid wave, it is recommended to install ALOHA    ')
disp('coupling code. In addition, the MUMPS matrix solver must be compiled as a mex-file. It speeds')
disp('up considerably Fokker-Planck calculations.')
disp(' ')
disp('Installation procedure requires Linux or MacOS computers with Matlab installed. It takes     ')
disp('approximately an hour to be operational.')
disp(' ')
disp('For a technical support, please contact Y. Peysson (CEA-France) by mail : yves.peysson@cea.fr')
disp(' ')
disp('All the simulations parameters are contained in a single structure of cells or indexed data  ')
disp('containers which allow to consider heterogeneous types of data. Its name is ''sparams''.')
disp(' ')
disp('The structure ''sparams'' can be created manually from scratch or by modifying an existing   ')
disp('script, but also interactively using the function ''sluke_params_generator'' with the syntax ')
disp('''sparams = sluke_params_generator;''. A script file is generated automatically from ')
disp('the ''sparams'' structure, which can be easily customized or duplicated, and possibly send to')
disp('other users.')
disp(' ')
disp('Once the ''sparams'' structure is created, the simulations can be performed by a single      ')
disp('command : ''sluke(sparams,mfilename);''. According to the parameters in ''sparams'',         ')
disp('calculations can be done locally or remotely on a distant computer that is registered in the ')
disp('''Profiles'' folder of the ''MatRemote'' toolbox. In the latter, the command                 ')
disp('''sluke(sparams,mfilename);'' must be typed several times in the command window to get the   ')
disp('status of the simulations . All results are stored in specific SLUKE folders automatically   ')
disp('created named as ''SLUKE_*''. When all results are saved, a user-defined display script can  ')
disp('be used to visualize the data and possibly to compare them to the experimental observations. ')
%
disp('NOTE : ''mfilename'' is a MatLab defined function which returns the most recently invoked    ')
disp('code file.')
%
disp(' ')
%
disp('---------------------------------------------------------------------------------------------')
disp('----------------------------------- SLUKE SCRIPTS AND FUNCTIONS -----------------------------')
disp('---------------------------------------------------------------------------------------------')
%
path_sluke = which('sluke');
dir(path_sluke(1:end-8))
%
disp('---------------------------------------------------------------------------------------------')
disp('---------------------------------------------------------------------------------------------')
disp('---------------------------------------------------------------------------------------------')
%