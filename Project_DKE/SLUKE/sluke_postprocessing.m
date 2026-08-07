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
function sluke_postprocessing(sparams,ii,lukestructs)
%
simul_id = sluke_id(sparams,ii);
%
if ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
    %
    if ~isfield(sparams,'postprocessing')
        %
        if isfield(lukestructs,'output') && ~isempty(lukestructs.output)
            %
            data_proc = proc_luke_jd(lukestructs.output);%default value
            %
            cprintf([1,0.5,0],'---> Defaults options for LUKE postprocessing since they are not defined in sparams.' );disp(' ')    
            %
        else
            %
            cprintf('*red','---> error in local LUKE postprocessing.' );disp(' ')    
            %
        end
        %
    else
        %
        if isfield(lukestructs,'data_proc')
            %
            data_proc = lukestructs.data_proc;%Processed data calculated remotely
            %
        else
            %
            data_proc = proc_luke_jd(lukestructs.output,sluke_params_value(sparams.postprocessing,ii));
            %
        end
        %
    end
    %
    if ~isempty(data_proc)
        %
        save(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'],'data_proc');
        %
        cprintf('*green','---> has been completed : processed results of LUKE are saved.');disp(' ')
        %
    else
        %
        cprinf('*red','WARNING : Post-processing of LUKE results failed !');disp(' ')
        %
    end
    %
end
