function flag = sluke_sparams_stamp(sparams,ii,display_mode) 
%
flag = 0;
%
if nargin < 3
    %
    display_mode = 0;
    %
end
%
simul_id = sluke_id(sparams,ii);
%
if isfield(sparams.simul,'enforce') && sparams.simul.enforce{ii} == 2
    %
    sluke_clear_folders(sparams,ii);% clear all previous simulation files
    %
    sparams_stamp = sluke_params_extract(sparams,ii);
    %
    save(['SLUKE_STAMPS/STAMP_',simul_id,'.mat'],'sparams_stamp');
    %
    cprintf('*green',['---> The stamp for the simulation ID : ',simul_id,' has been updated.']);disp(' ')
    %
elseif isfield(sparams.simul,'enforce') && sparams.simul.enforce{ii} <= 1
    %
    if exist(['SLUKE_STAMPS/STAMP_',simul_id,'.mat'])
        %
        load(['SLUKE_STAMPS/STAMP_',simul_id,'.mat']);
        %
        sparams_e = sluke_params_extract(sparams,ii);
        %
        flag = 0;
        %
        if sparams.simul.enforce{ii} == 1 && isfield(sparams_stamp,'equil') && isfield(sparams,'equil') && ~comp_struct_jd(sparams_stamp.equil,sparams_e.equil,display_mode)
            %
            cprintf('*red',['---> The ''equil'' structure has been changed in sparams while keeping the same simulation ID.']);disp(' ')
            cprintf('*red',['EQUIL_',simul_id,'.mat']);disp(' ')
            cprintf('*red',['EQUILCONSISTENCY_',simul_id,'.mat']);disp(' ')
            cprintf('*red',['FITEQUIL_',simul_id,'.mat']);disp(' ')
            cprintf('*red',['Above files are inconsistent with input parameters in sparams structure.']);disp(' ')            
            %
            sluke_clear_folders(sparams,ii,'EQUIL');
            sluke_clear_folders(sparams,ii,'OHM');
            sluke_clear_folders(sparams,ii,'LUKE_RESULTS');
            sluke_clear_folders(sparams,ii,'LUKE_DATA');
            sluke_clear_folders(sparams,ii,'PROC_LUKE_DATA');
            sluke_clear_folders(sparams,ii,'WAVESTRUCTS');
            sluke_clear_folders(sparams,ii,'DIAG_RESULTS');
            %
            flag = flag + 1;
            %
        end
        %
        if sparams.simul.enforce{ii} == 1 && isfield(sparams_stamp,'ohm') && isfield(sparams,'ohm') && ~comp_struct_jd(sparams_stamp.ohm,sparams_e.ohm,display_mode)
            %
            cprintf('*red',['---> The ''ohm'' structure has been changed in sparams while keeping the same simulation ID.']);disp(' ')
            cprintf('*red',['OHM_',simul_id,'.mat']);disp(' ')
            cprintf('*red',['Above files are inconsistent with input parameters in sparams structure.']);disp(' ')            
            %
            sluke_clear_folders(sparams,ii,'OHM');
            sluke_clear_folders(sparams,ii,'LUKE_RESULTS');
            sluke_clear_folders(sparams,ii,'LUKE_DATA');
            sluke_clear_folders(sparams,ii,'PROC_LUKE_DATA');
            sluke_clear_folders(sparams,ii,'DIAG_RESULTS');
            %
            flag = flag + 1;
            %
        end
        %      
        if sparams.simul.enforce{ii} == 1 && isfield(sparams_stamp,'rfwaves') && isfield(sparams,'rfwaves') && ~comp_struct_jd(sparams_stamp.rfwaves,sparams_e.rfwaves,display_mode)
            %
            cprintf('*red',['---> The ''rfwaves'' structure has been changed in sparams while keeping the same simulation ID. ']);disp(' ')
            cprintf('*red',['WAVESTRUCTS_',simul_id,'.mat']);disp(' ')
            cprintf('*red',['Above files are inconsistent with input parameters in sparams structure.']);disp(' ')            
            %
            sluke_clear_folders(sparams,ii,'WAVESTRUCTS');
            sluke_clear_folders(sparams,ii,'LUKE_RESULTS');
            sluke_clear_folders(sparams,ii,'LUKE_DATA');
            sluke_clear_folders(sparams,ii,'PROC_LUKE_DATA');
            sluke_clear_folders(sparams,ii,'DIAG_RESULTS');
            %
            flag = flag + 1;
            %
        end 
        %
        if isfield(sparams_stamp,'rfwaves') && isfield(sparams,'rfwaves') && isfield(sparams_stamp.rfwaves,'antenna') && isfield(sparams.rfwaves,'antenna')  && isfield(sparams_stamp.rfwaves.antenna,'LH') && isfield(sparams.rfwaves.antenna,'LH') && isfield(sparams_stamp.rfwaves.antenna.LH,'ALOHA') && isfield(sparams.rfwaves.antenna.LH,'ALOHA') && ~comp_struct_jd(sparams_stamp.rfwaves.antenna.LH.ALOHA,sparams_e.rfwaves.antenna.LH.ALOHA,display_mode)
            %
            cprintf('*red',['---> The ''rfwaves'' structure has been changed in sparams while keeping the same simulation ID.']);disp(' ')
            %
            if sparams.simul.enforce{ii} == 1
                %
                sluke_clear_folders(sparams,ii,'WAVESTRUCTS');
                sluke_clear_folders(sparams,ii,'LUKE_RESULTS');
                sluke_clear_folders(sparams,ii,'LUKE_DATA');
                sluke_clear_folders(sparams,ii,'PROC_LUKE_DATA');
                sluke_clear_folders(sparams,ii,'DIAG_RESULTS');
                %
            end
            %
            flag = flag + 1;
            %
        end   
        %
        if isfield(sparams_stamp,'kinetics') && isfield(sparams,'kinetics') && ~comp_struct_jd(sparams_stamp.kinetics,sparams_e.kinetics,display_mode)
            %
            cprintf('*red',['---> The ''kinetics'' structure has been changed in sparams while keeping the same simulation ID.']);disp(' ')
            %
            if sparams.simul.enforce{ii} == 1
                %
                sluke_clear_folders(sparams,ii,'LUKE_RESULTS');
                sluke_clear_folders(sparams,ii,'LUKE_DATA');
                sluke_clear_folders(sparams,ii,'PROC_LUKE_DATA');
                sluke_clear_folders(sparams,ii,'DIAG_RESULTS');
                %
            end
            %
            flag = flag + 1;
            %
        end
        %
        if isfield(sparams_stamp,'postprocessing') && isfield(sparams,'postprocessing') && ~comp_struct_jd(sparams_stamp.postprocessing,sparams_e.postprocessing,display_mode)
            %
            flag = flag + 1;
            %
            cprintf([1,0.5,0],['---> The ''postprocessing'' structure has been changed in sparams. Postprocessing is performed locally with new sparams values. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
            %
            if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
                %
                load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
                %
                if exist('lukestructs','var') && isfield(lukestructs,'output')
                    %
                    try
                        %
                        sluke_diagnostics(sparams,ii,lukestructs);% Synthetic diagnostic calculations
                        %
                    catch
                        %
                        cprintf('*red',['---> error in synthetic diagnostics calculations.' ]);disp(' ')
                        %  
                    end
                    %
                else
                    %
                    cprintf('*red',['---> Postprocessing cannot be performed with new sparams values, since output structure does not exist in LUKE_DATA_',simul_id,'.mat has not been saved. Full simulations must be enforced with sparams.simul.output{',int2str(ii),' = 2.']);disp(' ')
                    %
                end
                %
                cprintf('*red',['---> Postprocessing cannot be performed with new sparams values, since LUKE_DATA_',simul_id,'.mat has not been saved. Full simulations must be enforced with sparams.simul.output{',int2str(ii),' = 2.']);disp(' ')
                %
            end
            %
        end
        %        
        if isfield(sparams_stamp,'diags') && isfield(sparams,'diags') && ~comp_struct_jd(sparams_stamp.diags,sparams_e.diags,display_mode)
            %
            flag = flag + 1;
            %
            cprintf([1,0.5,0],['---> The ''diags'' structure has been changed in sparams. Synthetic diagnostic calculations are performed locally with new sparams values. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
            %
            if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
                %
                load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
                %
                if exist('lukestructs','var') && isfield(lukestructs,'output')
                    %
                    try
                        %
                        sluke_diagnostics(sparams,ii,lukestructs);% Synthetic diagnostic calculations
                        %
                    catch
                        %
                        cprintf('*red',['---> error in synthetic diagnostics calculations.' ]);disp(' ')
                        %  
                    end
                    %
                else
                    %
                    cprintf('*red',['---> Synthetic diagnostics calculations cannot be performed with new sparams values, since output structure does not exist in LUKE_DATA_',simul_id,'.mat has not been saved. Full simulations must be enforced with sparams.simul.output{',int2str(ii),' = 2.']);disp(' ')
                    %
                end
                %
                cprintf('*red',['---> Synthetic diagnostics calculations cannot be performed with new sparams values, since LUKE_DATA_',simul_id,'.mat has not been saved. Full simulations must be enforced with sparams.simul.output{',int2str(ii),' = 2.']);disp(' ')
                %
            end
            %
        end
        %  
        if sparams.simul.enforce{ii} == 1
            %
            if flag > 0
                %
                sparams_stamp = sparams_e;
                %
                save(['SLUKE_STAMPS/STAMP_',simul_id,'.mat'],'sparams_stamp');
                %
                cprintf('*green',['---> The stamp for the simulation : ',simul_id,' has been updated and the simulation is relaunched.']);disp(' ')
                %
                flag = 0;
                %
            end
            %     
        elseif sparams.simul.enforce{ii} == 0
            %
            if flag > 0
                %
                cprintf('*red',['---> The simulation has been done, but data of the actual sparams structure does not match the previous ones. ']);disp(' ')
                %
                flag = -1;
            end
            %
        end
        %
    else
        %
        if sparams.simul.enforce{ii} == 1
            %
            cprintf([1,0.5,0],['---> No stamp file of the simulation : ',simul_id,' exists. A new one is created from sparams and the simulation is relaunched.']);disp(' ')
            %
            sparams_stamp = sluke_params_extract(sparams,ii);
            %
            save(['SLUKE_STAMPS/STAMP_',simul_id,'.mat'],'sparams_stamp');
            %
        elseif sparams.simul.enforce{ii} == 0
            %
            if exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
                %
                cprintf([1,0.5,0],['---> No stamp file of the simulation : ',simul_id ,' exists, but the simulations has been done. Set sparams.simul.enforce{',int2str(ii),'} to 1 or 2 to be able to relaunch the simulation.']);disp(' ')
                %
                flag = -1;
            else
                %
                cprintf([1,0.5,0],['---> No stamp file of the simulation : ',simul_id ,' exists, but the simulations has not been done. The simulation is launched.']);disp(' ')
                %
            end
            %
        end

        %
    end
    %
end









