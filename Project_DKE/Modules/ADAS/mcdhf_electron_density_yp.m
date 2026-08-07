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
function mcdhf = mcdhf_electron_density_yp(Z_in,Z0_in,code,remote,cancel)
%
%   Calculation script of the atomic electron density for all ionization states of an
%   atom with atomic number Z. To be used with MCDHF GRASP2018 code to calculate the
%   atomic electron density like GRASP2018, .... Matlab is
%   supposed to be installed on the computer on which the MCDHF calculations are done. 
%
%   For examples of GRASP2018 calculations wisit the webpages 
%
%       - https://www.diracprogram.org/doc/release-12/exercises/computer_grasp.html
%       - https://www.diracprogram.org/doc/release-17/exercises/computer_grasp.html
%
%   INPUTS:
%
%       - Z_in : atomic number vector [1,1]
%       - Z0_in : ionization states (Z0 < Z) [1,p]
%       - code : code structure [1,1]
%       - remote : remote structure [1,1]
%
% An example for GRASP2018 MCDHF code
%
%   OUTPUTS:
%
%       - mcdhf : mcdhf structure with solid angle averaged atomic electron density for all ionisation states [nr,p+2]
%
%   By Y. Savoye-Peysson CEA-IRFM <yves.savoye-peysson@cea.fr>
%
if nargin < 3
    %
    if ~exist(['mcdhf_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
        %
        error('Error: not enough input arguments in mcdhf_electron_density_yp.m.');
        %
    end
    %
end
%
if nargin == 3
    %
    if ~exist(['mcdhf_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
        %
        remote = [];% local distributed calculation. GRASP2018 code is supposed to be on the same computer on which this Matlab script is launched
        %
    end
    %
    cancel = 0;
end
%
if nargin == 4
    %
    cancel = 0;
    %
end
%
if cancel
    %
    localdir = [pwd,'/mcdhf_shell_scripts_',code.codetype,'_',int2str(Z_in)];
    %
    [s,m] = unix(['rm -rf ',localdir]);
    %
    if s ~= 0
        disp(['WARNING : ',m]);
    end
    %
    if ~isempty(remote)
       %
        [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''rm -rf ',remote.remotedir,'''']); 
        %
        if s ~= 0
            disp(['WARNING : ',m]);
        end
        %
    end
    %
    delete(['mcdhf_run_Zi_',int2str(Z_in),'.mat']); %close simulation
    %
    mcdhf = [];
    %
    return;
    %
end
%
if exist(['mcdhf_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
    %
    load(['mcdhf_run_Zi_',int2str(Z_in),'.mat'])
    %
    symbol = mcdhf.symbol;
    Z_in = mcdhf.Z;
    ZZ0 = mcdhf.Z0;
    code = mcdhf.code; 
    %
    if ~isempty(remote) %remote calculations
        %
        disp('-------------------')
        disp(['GRASP2018 simulations status for Z = ',int2str(Z_in),'.']);
        disp('-------------------')
        %
        ss = 0;
        for iZ0 = 1:length(ZZ0)
            %
            if exist([localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.output'],'file') && exist([localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.log'],'file')
                %
                disp([' - Calculations for ',symbol,'_',int2str(ZZ0(iZ0)),' are done and saved locally.']);
                %
            else
                %
                [s0,m0] = unix(['scp -r -p ',remote.id,'@',remote.ip,':',remote.remotedir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.output ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.output']); %get results on local computer
                [s1,m1] = unix(['scp -r -p ',remote.id,'@',remote.ip,':',remote.remotedir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.log ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.log']); %get logs on local computer
                %
                if s0 == 0 && s1 == 0
                    %
                    s = 0;
                    %
                else
                    %
                    s = 1;
                    %
                end
                %
                if s ~= 0
                    %
                    if s0 ~= 0 && s1 ~= 0
                        %
                        disp([' - WARNING file ',symbol,'_',int2str(ZZ0(iZ0)),'.output and ',symbol,'_',int2str(ZZ0(iZ0)),'.log are missing.']);
                        %
                    elseif s0 ~= 0 && s1 == 0
                        %
                        disp([' - WARNING file ',symbol,'_',int2str(ZZ0(iZ0)),'.output is missing. Check the ',symbol,'_',int2str(ZZ0(iZ0)),'.log file.']);
                        %
                    end
                    ss = ss + s;
                    %
                else
                    %
                    disp([' - Calculations for ',symbol,'_',int2str(ZZ0(iZ0)),' are done and transfered locally.']);
                    %
                end
                %
            end
            %
        end
    end
    %
    if ss == 0
        %
        disp('-------------------')
        disp(['All results have been well transfered back to the local computer for Z = ',int2str(Z_in),'.']);
        disp('-------------------')
        %
    else
        %
        disp('-------------------')
        disp([' ---> ',int2str(ss),' calculations remain to be done for Z = ',int2str(Z_in),'.']);
        disp('-------------------')
        %
    end
    %
    cd(localdir);
    %
    ss = 0;
    %
    for iZ0 = 1:length(ZZ0)
        %
        if exist([symbol,'_',int2str(ZZ0(iZ0)),'.output'])
            %
            ss = ss + 1;
            %
            res = table2array(readtable([symbol,'_',int2str(ZZ0(iZ0)),'.output'],'FileType','text'));
            res = res(2:end,:);%remove useless first line
            %
            if iZ0 == 1
                %
                nr = size(res,1);
                xnr = [1:size(res,1)]';
                %
            	mcdhf.ne(:,1:3) = [xnr,res(:,1),res(:,3)/4/pi];
                %
            else
                %
                ne_temp = interp1(res(:,1),res(:,3)/4/pi,mcdhf.ne(:,2));
                mcdhf.ne(:,iZ0+2) = ne_temp;
                %
            end
            %
            clear res ne_temp 
            %
        end
        %
    end
    %
    cd('..');
    %
    if ss == length(ZZ0) %all results have been transfered. Clean up folders
        %
        [s,m] = unix(['rm -rf ',localdir]);
        %
        if s ~= 0
            %
            disp(['WARNING : ',m]);
            %
        end
        %
        if ~isempty(remote)
            %
            [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''rm -rf ',remote.remotedir,'''']); 
            %
            if s ~= 0
                %
                disp(['WARNING : ',m]);
                %
            end
            %
        end
        %
        delete(['mcdhf_run_Zi_',int2str(Z_in),'.mat']); %close simulation
        %
        datesave = datestr(now,'dd-mm-yyyy_HH:MM:SS');
        mcdhf.datesave = datesave;
        %
        save(['mcdhf_',int2str(Z_in),'_',elements('atomic_number', Z_in, 'symbol'),'_',elements('atomic_number', Z_in, 'name'),'_',code.codetype,'_',datesave,'.mat'],'mcdhf');
        disp(['MCDHF calculations with ',code.codetype,' code successfully saved in mcdhf_',int2str(Z_in),'_',elements('atomic_number', Z_in, 'name'),'_',code.codetype,'_',datesave,'.mat']);
        %
        disp('-------------------')
        disp('-------------------')
        %
    else
        %
        save(['mcdhf_run_Zi_',int2str(Z_in),'.mat'],'mcdhf','remote','localdir')
        %
    end
    %    
else
    %
    if ~exist([pwd,'/mcdhf_shell_scripts_',code.codetype,'_',int2str(Z_in)],'dir')
        %
        mkdir([pwd,'/mcdhf_shell_scripts_',code.codetype,'_',int2str(Z_in)]);
        %
    end
    %
    localdir = [pwd,'/mcdhf_shell_scripts_',code.codetype,'_',int2str(Z_in)];
    %
    [MM_in,ZZ0_in,symbol] = spinmultiplicity_yp(Z_in);%all ionization states
    %
    if ~isempty(Z0_in)
        %
        ZZ0 = ZZ0_in(Z0_in+1);
        %
    else
        %
        ZZ0 = ZZ0_in;
        %
    end
    %
    mcdhf.symbol = symbol;
    mcdhf.Z = Z_in;
    mcdhf.Z0 = ZZ0;
    mcdhf.code = code;%transfer simulation parameters
    %
    build_write_shell_script(ZZ0,symbol,code,localdir,remote.remotedir);% shell script name <<symbol>>_<<Z0>>.sh
    %
    if ~isempty(remote) %remote distributed calculations
        %
        [s_condor,m_condor] = unix(['ssh ',remote.id,'@',remote.ip,' ''condor_version''']); %Check if htcondor scheduler exists on remote machine
        %
        if strcmp(remote.scheduler,'none')
            %
            s_condor = 1;%direct computing is performed
            %
        end
        %
        if s_condor == 0 && strfind(m_condor,'CondorVersion')
            %
            build_write_condorshell_script(ZZ0,symbol,localdir);% shell script name <<symbol>>_<<Z0>>.sh
            %
        end
        %
        [s,m] = unix(['scp -r -p ',localdir,' ',remote.id,'@',remote.ip,':',remote.remotedir]); %copy script on remote computer
        %
        if s ~= 0
            %
            disp(['WARNING for copying files on the remote computer : ',m]);
            %
        else
            %
            disp(['Copying files on the remote computer done.']);
            %
        end
        %
        [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' '' chmod -R 777 ',remote.remotedir,'''']); %change rights, for owner only
        %
        if s ~= 0
            %
            disp(['WARNING for changing rights of the files on the remote computer : ',m]);
            %
        else
            %
            disp(['Changing rights of the files on the remote computer done.']);
            %
        end
        %
        disp('Starting calculations. May take some time ... ');
        %
        ss = 0;
        %
        for iZ0 = 1:length(ZZ0)
            %
            if s_condor == 0 && strfind(m_condor,'CondorVersion')
                %
                [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''cd ',remote.remotedir,'; condor_submit ',symbol,'_',int2str(ZZ0(iZ0)),'_condor.submit''']); %run each script and give hand back
                %
            else
                %
               % [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''cd ',remote.remotedir,'; nohup ./',symbol,'_',int2str(ZZ0(iZ0)),'.sh > /dev/null 2>&1 &''']); %run each script and give hand back
                [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''cd ',remote.remotedir,'; ./',symbol,'_',int2str(ZZ0(iZ0)),'.sh''']); %run each script and give hand back
               %
            end
            %
            if s ~= 0
                %
                disp(['WARNING for launching script ',symbol,'_',int2str(ZZ0(iZ0)),'.sh : ',m]);
                %
                ss = ss + s;
                %
            end      
            %
            iZ0
            %pause(10)
        end
        %
        if ss == 0
            %
            disp(['All scripts have been well launched on the remote computer.']);
            disp('-------------------')
            %
        end   
        %
    else % local distributed calculations
        %
        cd(localdir);
        %
        for iZ0 = 1:length(ZZ0)
            %
            [s,m] = unix(['chmod 700 ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.sh']); %change rights, for owner only 
            %
            if s ~= 0
                %
                disp(['WARNING for changing rights of files on the local computer : ',m]);
                %
            end
            %
          %  [s,m] = unix(['nohup ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.sh > /dev/null 2>&1 &']); %run script
            [s,m] = unix([localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.sh']); %run script

            %
            if s ~= 0
                %
                disp(['WARNING for launching local script ',symbol,'_',int2str(ZZ0(iZ0)),'.sh : ',m]);
                %
            end        
            %
        end
        %
        cd('..');
        %
    end
    %
    save(['mcdhf_run_Zi_',int2str(Z_in),'.mat'],'mcdhf','remote','localdir')
    %
    return;
    %
end   
%
end
%
function [] = build_write_shell_script(ZZ0,symbol,code,localdir,remotedir)
    %
    Z = elements('symbol',symbol, 'atomic_number');
    name = elements('symbol',symbol, 'name');
    weight = elements('atomic_number',Z, 'atomic_mass');
    mass = 184;
    %
    for iZ0 = 1:length(ZZ0)
        %
        Z0 = ZZ0(iZ0);
        %
        rcsfgenerate = grasp_rcsfgenerate_yp(Z,Z0,code);%core and configurations
        %
        if strcmp(lower(code.codetype),'grasp2018')
            %
            fileID = fopen([localdir,'/',symbol,'_',int2str(Z0),'.sh'],'w');
            %
            if fileID < 0
                error(['Error : file ',symbol,'_',int2str(Z0),'.sh cannot be created in ',localdir,' folder']);       
            else
                %
                fprintf(fileID,'#!/bin/bash\n\n');
                %
                fprintf(fileID,['export PATH=$PATH:',code.rootpath,'bin\n']);
                fprintf(fileID,[code.fortran,' \n\n']);
                %
                % rnucleus, output file : isodata
                %
                fprintf(fileID,'rnucleus << eof\n');
                fprintf(fileID,[int2str(Z),'\n']);
                fprintf(fileID,[int2str(mass),'\n']);
                fprintf(fileID,'n\n');%default answer no (n) concerning root mean squared radius and nuclear skin thickness (see interactive rnucleus)
                fprintf(fileID,[num2str(weight),'\n']);
                fprintf(fileID,[int2str(code.rnucleus.nuclear.spin),'\n']);
                fprintf(fileID,[int2str(code.rnucleus.nuclear.dipole),'\n']);
                fprintf(fileID,[int2str(code.rnucleus.nuclear.quadrupole),'\n']);
                fprintf(fileID,'eof\n\n');
                %
                % rcsfgenerate, output files : rcsf.out, rcsfgenerate.log
                %
                fprintf(fileID,'rcsfgenerate << eof\n');
                fprintf(fileID,[rcsfgenerate.order,'\n']);
                fprintf(fileID,[int2str(rcsfgenerate.core),'\n']);
                %
                for kk = 1:length(rcsfgenerate.config)
                    fprintf(fileID,[rcsfgenerate.config{kk},'\n']);
                end
                %
                fprintf(fileID,[int2str(rcsfgenerate.Jmin),'  ',int2str(rcsfgenerate.Jmax),'\n']);
                fprintf(fileID,[int2str(rcsfgenerate.excitation),'\n']);
                fprintf(fileID,'n\n');%no other list
                fprintf(fileID,'eof\n\n');
                %
                fprintf(fileID,'mv rcsf.out rcsf.inp\n\n');%file rename for rangular
                %
                % rangular, input file : rcsf.inp, output files : mcp.30, mcp.31, ... , rangular.log                     
                %
                fprintf(fileID,'rangular << eof\n');
                fprintf(fileID,[num2str(code.rangular.fullinteraction),'\n']);
                fprintf(fileID,'eof\n\n');
                %
                % rwfnestimate, input files : isodata, rcsf.inp, rwfn (optional), output file : rwfn.inp                
                %
                fprintf(fileID,'rwfnestimate << eof\n');
                fprintf(fileID,[code.rwfnestimate.default_settings,' \n']);
                fprintf(fileID,[int2str(code.rwfnestimate.subshell_radial_wavefunctions),'\n']);
                fprintf(fileID,[code.rwfnestimate.list_of_relativistic_subshells,'\n']);
                fprintf(fileID,'eof\n\n');
                %
                % rmcdhf input files : ,output file :              
                %
                fprintf(fileID,'rmcdhf << eof\n');
                fprintf(fileID,[code.rmcdhf.default_settings,'\n']);
                fprintf(fileID,[int2str(code.rmcdhf.ASF_serial_numbers_for_each_block),'\n']);
                fprintf(fileID,[code.rmcdhf.orbitals_to_be_varied,'\n']);
                fprintf(fileID,[code.rmcdhf.spectroscopic_orbitals,'\n']);
                %fprintf(fileID,[code.rmcdhf.orbitals_to_be_varied,'\n']);
                fprintf(fileID,[int2str(code.rmcdhf.maximum_number_of_SCF_cycles),'\n']);
                fprintf(fileID,'eof\n\n');
                %
                fprintf(fileID,['rsave DHF_',symbol,int2str(Z0),' \n\n']);
                %
                % rci input files : isodata, name_of_state.c, name_of_state.w ,output file : name_of_state.cm, name_of_state.csum, name_of_state.clog, rci.res (can be used for restart)        
                %
                fprintf(fileID,'rci << eof\n');
                fprintf(fileID,[code.rci.default_settings,'\n']);
                fprintf(fileID,['DHF_',symbol,int2str(Z0),'\n']);
                fprintf(fileID,[code.rci.contribution_of_H,'\n']);
                fprintf(fileID,[code.rci.modify_all_transverse_photon_frequencies,'\n']);
                fprintf(fileID,[num2str(code.rci.scale_factor),'\n']);
                fprintf(fileID,[code.rci.include_H_vacuum_polarisation,'\n']);
                fprintf(fileID,[code.rci.include_H_normal_mass_shift,'\n']);
                fprintf(fileID,[code.rci.include_H_specific_mass_shift,'\n']);
                fprintf(fileID,[code.rci.estimate_self_energy,'\n']);
                fprintf(fileID,[int2str(code.rci.largest_n_quantum_number_for_including_self_energy),'\n']);
                fprintf(fileID,[int2str(code.rmcdhf.ASF_serial_numbers_for_each_block),'\n']);
                fprintf(fileID,'eof\n\n');
                %
                % rdensity input files : isodata, name_of_state.c, name_of_state.w, name_of_state.(c)m ,output file : name_of_state.nw, name_of_state.(c)d             
                %
                fprintf(fileID,'rdensity << eof\n');
                fprintf(fileID,[code.rdensity.default_settings,' \n']);
                fprintf(fileID,['DHF_',symbol,int2str(Z0),' \n']);
                fprintf(fileID,[code.rdensity.mixing_coefficients_from_CI_calc,' \n']);
                fprintf(fileID,[int2str(code.rdensity.egvc_order),' \n']);
                fprintf(fileID,'eof\n\n');
                %
                fprintf(fileID,'rm mcp* \n');
                fprintf(fileID,'rm rci.res \n');
                fprintf(fileID,'rm rcsf* \n');
                fprintf(fileID,'rm clist.new \n');
                %/home/u01/mcdhf_shell_scripts_grasp2018_18/Ar_0_condor.out
                fprintf(fileID,['mv DHF_',symbol,int2str(Z0),'.cd ',symbol,'_',int2str(Z0),'.output \n']);%to be read by matlab
                fprintf(fileID,['cp ',symbol,'_',int2str(Z0),'_condor.out ',symbol,'_',int2str(Z0),'.log \n']);%to be read by matlab
                fprintf(fileID,['rm DHF_',symbol,int2str(Z0),'* \n']);
                fprintf(fileID,'rm isodata \n');
                fprintf(fileID,'rm rwfn.inp \n');
                fprintf(fileID,'rm rwfn.out \n');
                %
                fclose(fileID);
                %
            end
        else
            error('Error: MCDHF GRASP2018 code not recognized.');
        end
        %
    end
end
%
%
function [] = build_write_condorshell_script(ZZ0,symbol,localdir)
    %
    for iZ0 = 1:length(ZZ0)
        %
        Z0 = ZZ0(iZ0);
        %
        fileID = fopen([localdir,'/',symbol,'_',int2str(Z0),'_condor.submit'],'w');
        %
        if fileID < 0
            error(['Error : file ',symbol,'_',int2str(Z0),'_condor.submit cannot be created in ',localdir,' folder']);       
        else
            %
            fprintf(fileID,'Universe = vanilla\n');
            fprintf(fileID,['Executable = ./',symbol,'_',int2str(Z0),'.sh\n']);
            fprintf(fileID,'Arguments = \n');
            fprintf(fileID,['Log = ',symbol,'_',int2str(Z0),'_condor.log\n']);
            fprintf(fileID,['Output = ',symbol,'_',int2str(Z0),'_condor.out\n']);
            fprintf(fileID,['Error = ',symbol,'_',int2str(Z0),'_condor.error\n']);
            fprintf(fileID,'Queue\n');
            %
            fclose(fileID);
            %
        end
    end
end