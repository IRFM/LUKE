function [sparams_new] = sluke_sparams_stamp(sparams_new,ii,display_mode) 
%
if nargin == 2
    %
    display_mode = 1;
    %
end
%
simul_id = sluke_id(sparams_new,ii);
%
if exist(['SLUKE_STAMPS/STAMPS_',simul_id,'.mat']) && exist(['SLUKE_STAMPS/PROC_LUKE_DATA_',simul_id,'.mat'])
    %
    load(['SLUKE_STAMPS/STAMPS_',simul_id,'.mat']);
    sparams_old = sparams;
    clear sparams;
    %
    if ~comp_struct_jd(sparams_new.equil,sparams_old.equil,display_mode)
        %
        cprintf('*red',['---> The ''equil'' structure has been changed in sparams. Simulation is launched with sparams.simul.enforce{',intstr(ii),'} = 1. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
        sparams_new.simul.enforce{ii} = 1;
        %
    end
    %
    if ~comp_struct_jd(sparams_new.kinetics,sparams_old.kinetics,0)
        %
        cprintf('*red',['---> The ''kinetics'' structure has been changed in sparams. Simulation is launched with sparams.simul.enforce{',intstr(ii),'} = 1. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
        sparams_new.simul.enforce{ii} = 1;
        %
    end
    %
    if ~comp_struct_jd(sparams_new.ohm,sparams_old.ohm,display_mode)
        %
        cprintf('*red',['---> The ''ohm'' structure has been changed in sparams. Simulation is launched with sparams.simul.enforce{',intstr(ii),'} = 1. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
        sparams_new.simul.enforce{ii} = 1;
        %
    end
    %        
    if ~comp_struct_jd(sparams_new.rfwaves,sparams_old.rfwaves,0)
        %
        cprintf('*red',['---> The ''rfwaves'' structure has been changed in sparams. Simulation is launched with sparams.simul.enforce{',intstr(ii),'} = 1. Type sluke_sparams_stamp(sparams,ii) to get details.']);disp(' ')
        sparams_new.simul.enforce{ii} = 1;
        %
    end
    %
    if ~comp_struct_jd(sparams_new.postprocessing,sparams_old.postprocessing,0)
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
    end
    %        
    if ~comp_struct_jd(sparams_new.diags,sparams_old.diags,0)
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
else
    %
    if ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
        %
        flag_stamp = 1; %simulation can be done. No sparams conflict
        %
        
    %

    end
%
end