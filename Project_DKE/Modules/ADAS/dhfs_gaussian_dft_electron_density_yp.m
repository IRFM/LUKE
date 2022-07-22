function dft = dhfs_gausian_dft_electron_density_yp(Z_in,Z0_in,code,remote,cancel)
%
%   Calculation script of the atomic electron density for all ionization states of an
%   atom with atomic number Z. To be used with DFT programs to calculate the
%   atomic electron density like GAUSSIAN, GRASP, EXCITING or GAMESS. Matlab is
%   supposed to be installed on the computer on which the DFT codes are done. 
%
%   INPUTS:
%
%       - Z_in : atomic number vector [1,1]
%       - Z0_in : ionization states (Z0 < Z) [1,p]
%       - code : code structure [1,1]
%       - remote : remote structure [1,1]
%
% An example for Gaussian DFT code
%
%   code.rootpath = '/home/u01/GAUSSIAN/';%absolute path
%   code.codepath = 'g09';%relative path
%   code.codetype = 'gaussian';
%   code.functional = 'PBE1PBE';%?hybrid-exchange correlation functional
%   code.basis = '6-311G';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
%   code.basis = AUG-cc-pVDZ';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
%   code.basis = cc-pVDZ';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
%   code.basis = 'gen/Auto';%Relativistic case calculations. To be used with ANO-RCC basis set exchange basis (download from www.basissetexchange.org)
%   code.equation = 'Integral=DKH2';%Relativistic case calculations. Douglas-Kroll-Hess second order scalar relativistic Hamiltonian.
%   code.mem = '5GB';%allocated memory (use 64bits Gaussian, 2GB max for 32bits Gaussian code only)
%   code.procs = '4';%number of shared cores (use 64bits Gaussian, A proc max for 32bits Gaussian code only)
%   code.postprocpath = 'Multiwfn';%Post-processing path, absolute or relative path to rootpath
%   code.postproccode = 'Multiwfn';%Post-processing tool
%
%   OUTPUTS:
%
%       - dft : dft structure with solid angle averaged atomic electron density for all ionisation states [n,p+2]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, K. Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin < 3
    %
    if ~exist(['dft_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
        %
        error('Error: not enough input arguments in dft_electron_density_yp.m.');
        %
    end
    %
end
%
if nargin == 3
    %
    if ~exist(['dft_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
        %
        remote = [];% local calculation. DFT code is supposed to be on the same computer on which this Matlab script is launched
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
    localdir = [pwd,'/dft_shell_scripts_',code.codetype,'_',int2str(Z_in)];
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
    delete(['dft_run_Zi_',int2str(Z_in),'.mat']); %close simulation
    %
    dft = [];
    %
    return;
    %
end
%
if exist(['dft_run_Zi_',int2str(Z_in),'.mat'],'file') %jobs are running
    %
    load(['dft_run_Zi_',int2str(Z_in),'.mat'])
    %
    symbol = dft.symbol;
    Z_in = dft.Z;
    ZZ0 = dft.Z0;
    MM = dft.M;
    code = dft.code; 
    %
    if ~isempty(remote) %remote calculations
        %
        disp('-------------------')
        disp(['GAUSSIAN simulations status for Z = ',int2str(Z_in),'.']);
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
            if iZ0 == 1
            	dft.ne(:,1:3) = importdata([symbol,'_',int2str(ZZ0(iZ0)),'.output']);
            else
                ne_tmp = importdata([symbol,'_',int2str(ZZ0(iZ0)),'.output']);
                dft.ne(:,iZ0+2) = ne_tmp(:,3);
            end
            %
        end
    end
    %
    cd('..');
    %
    if ss == length(ZZ0) %all results have been transfered. Clean up folders
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
        delete(['dft_run_Zi_',int2str(Z_in),'.mat']); %close simulation
        %
        datesave = datestr(now,'dd-mm-yyyy_HH:MM:SS');
        dft.datesave = datesave;
        %
        save(['dft_',int2str(Z_in),'_',elements('atomic_number', Z_in, 'symbol'),'_',elements('atomic_number', Z_in, 'name'),'_',code.codetype,'_',datesave,'.mat'],'dft');
        disp(['DFT calculations with ',code.codetype,' code successfully saved in dft_',int2str(Z_in),'_',elements('atomic_number', Z_in, 'name'),'_',code.codetype,'_',datesave,'.mat']);
        %
        disp('-------------------')
        disp('-------------------')
        %
    else
        %
        save(['dft_run_Zi_',int2str(Z_in),'.mat'],'dft','remote','localdir')
        %
    end
    %    
else
    %
    if ~exist([pwd,'/dft_shell_scripts_',code.codetype,'_',int2str(Z_in)],'dir')
        mkdir([pwd,'/dft_shell_scripts_',code.codetype,'_',int2str(Z_in)]);
    end
    %
    localdir = [pwd,'/dft_shell_scripts_',code.codetype,'_',int2str(Z_in)];
    %
    [MM_in,ZZ0_in,symbol] = spinmultiplicity_yp(Z_in);%all ionization states
    %
    if ~isempty(Z0_in)
        %
        MM = MM_in(Z0_in+1);
        ZZ0 = ZZ0_in(Z0_in+1);
        %
    else
        MM = MM_in;
        ZZ0 = ZZ0_in;
    end
    %
    dft.symbol = symbol;
    dft.Z = Z_in;
    dft.Z0 = ZZ0;
    dft.M = MM;
    dft.code = code;
    %
    if isfield(code,'postprocgrid') && ~isempty(code.postprocgrid)
        dft.ne = zeros(code.postprocgrid,length(ZZ0)+2);
    else
        dft.ne = zeros(500,length(ZZ0)+2);
    end
    %
    build_write_shell_script(MM,ZZ0,symbol,code,localdir,remote.remotedir);% shell script name <<symbol>>_<<Z0>>.sh
    %
    if ~isempty(remote) %remote calculations
        %
        [s_condor,m_condor] = unix(['ssh ',remote.id,'@',remote.ip,' ''condor_version''']); %Check if htcondor scheduler exists on remote machine
        %
        if s_condor == 0 && strfind(m_condor,'CondorVersion')
            build_write_condorshell_script(ZZ0,symbol,localdir);% shell script name <<symbol>>_<<Z0>>.sh
        end
        %
        [s,m] = unix(['scp -r -p ',localdir,' ',remote.id,'@',remote.ip,':',remote.remotedir]); %copy script on remote computer
        %
        if s ~= 0
            disp(['WARNING for copying files on the remote computer : ',m]);
        else
            disp(['Copying files on the remote computer done.']);
        end
        %
        [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' '' chmod -R 700 ',remote.remotedir,'''']); %change rights, for owner only (mandatory for Gaussian DFT program)
        %
        if s ~= 0
                disp(['WARNING for changing rights of the files on the remote computer : ',m]);
        else
            disp(['Changing rights of the files on the remote computer done.']);
        end
        %
        disp('Starting calculations. May take some time ... ');
        %
        ss = 0;
        %
        for iZ0 = 1:length(ZZ0)
            %
            if s_condor == 0 && strfind(m_condor,'CondorVersion')
                [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''cd ',remote.remotedir,'; condor_submit ',symbol,'_',int2str(ZZ0(iZ0)),'_condor.submit''']); %run each script and give hand back
            else
                [s,m] = unix(['ssh ',remote.id,'@',remote.ip,' ''cd ',remote.remotedir,'; nohup ./',symbol,'_',int2str(ZZ0(iZ0)),'.sh > /dev/null 2>&1 &''']); %run each script and give hand back
            end
            %
            if s ~= 0
                disp(['WARNING for launching script ',symbol,'_',int2str(ZZ0(iZ0)),'.sh : ',m]);
                ss = ss + s;
            end      
            %
        end
        %
        if ss == 0
            disp(['Scripts have been well launched on the remote computer.']);
            disp('-------------------')
        end   
        %
    else local calculations
        %
        cd(localdir);
        %
        for iZ0 = 1:length(ZZ0)
            %
            [s,m] = unix(['chmod 700 ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.sh']); %change rights, for owner only (mandatory for Gaussian DFT program)
            %
            if s ~= 0
                disp(['WARNING for changing rights of files on the local computer : ',m]);
            end
            %
            [s,m] = unix(['nohup ',localdir,'/',symbol,'_',int2str(ZZ0(iZ0)),'.sh > /dev/null 2>&1 &']); %run script
            %
            if s ~= 0
                disp(['WARNING for launching local script ',symbol,'_',int2str(ZZ0(iZ0)),'.sh : ',m]);
            end        
            %
        end
        %
        cd('..');
        %
    end
    %
    save(['dft_run_Zi_',int2str(Z_in),'.mat'],'dft','remote','localdir')
    %
    return;
    %
end   
%
end
%
function [] = build_write_shell_script(MM,ZZ0,symbol,code,localdir,remotedir)
    %
    for iZ0 = 1:length(ZZ0)
        %
        Z0 = ZZ0(iZ0);
        M = MM(iZ0);
        %
        if strcmp(code.codetype,'gaussian')
            %
            fileID = fopen([localdir,'/',symbol,'_',int2str(Z0),'.sh'],'w');
            %
            if fileID < 0
                error(['Error : file ',symbol,'_',int2str(Z0),'.sh cannot be created in ',localdir,' folder']);       
            else
                %
                fprintf(fileID,'#!/bin/csh\n\n');
                fprintf(fileID,['setenv GAUSS_EXEDIR ',code.rootpath,code.codepath,'\n']);
                fprintf(fileID,['setenv GAUSS_ARCHDIR ',code.rootpath,code.codepath,'\n']);
                fprintf(fileID,['setenv GAUSS_SCRDIR /tmp\n']);
                fprintf(fileID,'setenv LD_LIBRARY_PATH "${GAUSS_EXEDIR}:/usr/lib"\n\n');
                %
                if ~isempty(remotedir)
                    fprintf(fileID,[code.rootpath,code.codepath,'/',code.codepath(1:3),' <<END >',remotedir,'/',symbol,'_',int2str(Z0),'.log\n']);
                    fprintf(fileID,['%%Chk=',remotedir,'/',symbol,'_',int2str(Z0),'\n\n']);
                else
                    fprintf(fileID,[code.rootpath,code.codepath,'/',code.codepath,' <<END >',localdir,'/',symbol,'_',int2str(Z0),'.log\n']);
                    fprintf(fileID,['%%Chk=',localdir,'/',symbol,'_',int2str(Z0),'\n\n']);
                end
                %
                if isfield(code,'equation') && ~isempty(code.equation)
                    fprintf(fileID,['#P ',code.functional,'/',code.basis.mode,' ',code.equation,'\n\n']);
                else
                    fprintf(fileID,['#P ',code.functional,'/',code.basis.mode,'\n\n']);
                end
                %
                if isfield(code,'grid') && ~isempty(code.grid)
                    fprintf(fileID,['%%Grid=',code.grid,'\n']);
                end
                fprintf(fileID,['%%mem=',code.mem,'\n']);
                fprintf(fileID,['%%NProcShared=',code.procs,'\n']);
                %
                if strcmp(code.basis.mode,'gen/Auto')
                    if exist(['DFT/',code.basis.external,'.gbs'],'file') %exchange basis set file
                        fprintf(fileID,['Gaussian Job for ',symbol,'_',int2str(Z0),' with ',code.basis.external,' external basis set.\n\n']);
                    end
                else
                    fprintf(fileID,['Gaussian Job for ',symbol,'_',int2str(Z0),'\n\n']);
                end
                %   
                fprintf(fileID,[int2str(Z0),',',int2str(M),'\n']);
                fprintf(fileID,[symbol,'\n\n']);
                %
                if strcmp(code.basis.mode,'gen/Auto')
                    %
                    if exist(['DFT/',code.basis.external,'.gbs'],'file') %exchange basis set file for DFT
                        %
                        ebs = fileread(['DFT/',code.basis.external,'.gbs']);
                        ebs = ebs(12:end);%remove header
                        ii = strfind(ebs,symbol);
                        ebs = ebs(ii:end);
                        jj = strfind(ebs,'****');
                        ebs = ebs(1:jj+3);
                        %
                        fprintf(fileID,[ebs,'\n\n']);
                        %
                    else
                        error(['Error : exchange basis set file ',code.basis.name,'.gbs not found.']);
                    end
                    %
                end
                %   
                fprintf(fileID,'END\n\n');
                %
                if ~isempty(remotedir)
                    fprintf(fileID,[code.rootpath,code.codepath,'/formchk ',remotedir,'/',symbol,'_',int2str(Z0),'.chk\n\n']);
                    fprintf(fileID,[code.rootpath,code.postprocpath,'/',code.postproccode,' ',remotedir,'/',symbol,'_',int2str(Z0),'.fchk > ',remotedir,'/',symbol,'_',int2str(Z0),'.txt << EOF\n']);
                else
                    fprintf(fileID,[code.rootpath,code.codepath,'/formchk ',localdir,'/',symbol,'_',int2str(Z0),'.chk\n\n']);
                    fprintf(fileID,[code.rootpath,code.postprocpath,'/',code.postproccode,' ',localdir,'/',symbol,'_',int2str(Z0),'.fchk > ',localdir,'/',symbol,'_',int2str(Z0),'.txt << EOF\n']);    
                end
                %
                fprintf(fileID,'200\n');
                fprintf(fileID,'5\n');
                %
                if isfield(code,'postprocgrid') && ~isempty(code.postprocgrid)
                    fprintf(fileID,'5\n');
                    fprintf(fileID,[int2str(code.postprocgrid),'\n']); 
                end
                %
                fprintf(fileID,'0\n');
                fprintf(fileID,'7\n');
                fprintf(fileID,'-1\n');
                fprintf(fileID,'EOF\n\n');
                %
                if ~isempty(remotedir)
                    fprintf(fileID,['mv ',remotedir,'/sphavgval.txt ',remotedir,'/',symbol,'_',int2str(Z0),'.output\n']);    
                else
                	fprintf(fileID,['mv ',localdir,'/sphavgval.txt ',localdir,'/',symbol,'_',int2str(Z0),'.output\n']);
                end
                %
                %fprintf(fileID,['mv sphavgval.txt ',symbol,'_',int2str(Z0),'.output\n']);
                fprintf(fileID,['echo "Job done for ',symbol,'_',int2str(Z0),'.sh"']);
                fclose(fileID);
                %
            end
        else
            error('Error: DFT code type not yet recognized.');
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
            fprintf(fileID,['Arguments = \n']);
            fprintf(fileID,['Log = ',symbol,'_',int2str(Z0),'_condor.log\n']);
            fprintf(fileID,['Output = ',symbol,'_',int2str(Z0),'_condor.out\n']);
            fprintf(fileID,['Error = ',symbol,'_',int2str(Z0),'_condor.error\n']);
            fprintf(fileID,['Queue\n']);
            %
            fclose(fileID);
            %
        end
    end
end