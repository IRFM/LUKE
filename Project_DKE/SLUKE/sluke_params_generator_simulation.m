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
function sparams = sluke_params_generator_simulation(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (simulation). All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : none (interactive mode), string (preset parameters) or 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 0
    %
    error('Wrong number of input arguments in sluke_params_generator_simulation.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - General simulation parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    sparams.simul.id{ii} = input_dke_yp('   - simulation id',sparams.simul.id{ii-1});
                else
                    sparams.simul.id{ii} = input_dke_yp('   - simulation id','');
                end
                %
                if ii > 1
                    sparams.simul.comment{ii} = input_dke_yp('   - comment on simulation',sparams.simul.comment{ii-1});
                else
                    sparams.simul.comment{ii} = input_dke_yp('   - comment on simulation','');
                end
                %
                sparams.simul.enable{ii} = input_dke_yp('   - enable simulation [0,1]',1,[0,1]);
                %
                sparams.simul.enforce{ii} = input_dke_yp('   - enforce simulation if enabled [0,1,2]',1,[0,1,2]);
                %
                sparams.simul.max_simulations{ii} =  input_dke_yp('   - maximum number of distributed simulations [Inf]',Inf);
                %
                sparams.simul.log{ii} = input_dke_yp('   - generate log and diary files [0,1]',1,[0,1]);
                %
                sparams.simul.output{ii} = input_dke_yp('   - generate log and diary files [0,1,2,3]',1,[0,1,2,3]);
                %
                indexlist = dispremoteprofiles('','scheduler'); % list of available remote profile numbers
                %
                if ii > 1
                    sparams.simul.remote_profile{ii} = input_dke_yp('   - remote profile number where LUKE will run.',sparams.simul.remote_profile{ii-1},indexlist);%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
                else
                    sparams.simul.remote_profile{ii} = input_dke_yp(['   - remote profile number where LUKE will run [',strrep(strrep(int2str(indexlist),'   ',','),'  ',','),'].'],0,indexlist);%remote profile number (list available by typing 'dispremoteprofiles' in command window)                        
                end
                %
                if sparams.simul.remote_profile{ii} > 0
                    %
                    sparams.simul.remote.mode{ii} = input_dke_yp('   - calculation distribution mode [-2,-1,0,1,2,3]',0,[-2,-1,0,1,2,3]);
                    %
                    sparams.simul.remote.remtimout{ii} = input_dke_yp('   - wait for reults or return mode after starting calculations [0,1]',1,[0,1]);
                    %
                    sparams.simul.remote.debugmode{ii} = input_dke_yp('   - debug mode [0,1,2]',0,[0,1,2]);
                    %
                    sparams.simul.remote.cleanmode{ii} = input_dke_yp('   -  clean job files/folders once calculations done [0,1,2]',2,[0,1,2]);
                    %
                    sparams.simul.remote.matver{ii} = input_dke_yp('   -  matlab version on the remote machine ''matxxx''','mat907');
                    %
                    sparams.simul.remote.git.projects{ii} = {'MatRemote','MatHelp','MatTools','LUKE'};%by default all are considered
                    %
                    sparams.simul.remote.git.pull{ii} = input_dke_yp('   - git pull remote projects before calculations [0,1]',1,[0,1]);
                    %
                    sparams.simul.remote.git.display{ii} = input_dke_yp('   - display results of git pull remote projects before calculations [0,1]',1,[0,1]);
                    %
                    scheduler_type = input_dke_yp('   - type of scheduler on remote machine [pbs, torque, htcondor, slurm]','pbs',{'pbs', 'torque', 'htcondor', 'slurm'});
                    %
                    if strcmp(scheduler_type,'pbs') || strcmp(scheduler_type,'torque')
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).nodes{ii} = input_dke_yp('   - number of nodes requested or node names','');
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).ppn{ii} = input_dke_yp('   - number of processors requested on the same node','');
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).select{ii} = input_dke_yp('   - number of separate nodes','');
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).ncpus{ii} = input_dke_yp('   - number of cpus per node (must be even number) [2,4,...]',2);
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).memory{ii} = input_dke_yp('   - job memory in Mbytes (should be increased for large calculation grids) [7000,15000,25000]',7000);
                        %
                        sparams.simul.remote.scheduler.(scheduler_type).walltime{ii} = input_dke_yp('   - job walltime in hours',24); 
                        %
                    end
                    %
                end
                %
                sparams.simul.mute.load_structures_yp{ii} = input_dke_yp('   - mute function load_structures_yp.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.run_lukert{ii} = input_dke_yp('   - mute function run_lukert.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.clustermode_luke{ii} = input_dke_yp('   - mute function clustermode_luke.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.mdce_clustermode{ii} = input_dke_yp('   - mute function mdce_clustermode.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.displayrunningjob{ii} = input_dke_yp('   - mute function displayrunningjob.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.remote_tsdate{ii} = input_dke_yp('   - mute function remote_tsdate.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.bremsstrahlung_dke_yp{ii} = input_dke_yp('   - mute function bremsstrahlung_dke_yp.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.bremdiag_dke_yp{ii} = input_dke_yp('   - mute function bremdiag_dke_yp.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.metis2luke{ii} = input_dke_yp('   - mute function metis2luke.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.equilconsistency_yp{ii} = input_dke_yp('   - mute function equilconsistency_yp.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.make_equil_metis2luke{ii} = input_dke_yp('   - mute function make_equil_metis2luke.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.make_sluke_build_launchs{ii} = input_dke_yp('   - mute function make_sluke_build_launchs.m [0,1]',1,[0,1]);
                %
                sparams.simul.mute.lukeschedulerparam{ii} = input_dke_yp('   - mute function lukeschedulerparam.m [0,1]',1,[0,1]);
                %
                sparams.simul.jprofileconsistency.code{ii} = 'METIS';
                %
                sparams.simul.jprofileconsistency.nit{ii} = 0;
                %
                sparams.simul.initial_distribution{ii} = 0;
                %
                disp('------------------------------------------------------------------');
            end
             %
            disp('------------------------------------------------------------------');
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_simulation. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_simulation. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end