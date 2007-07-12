function [nproc] = nproc_dke_yp(display_mode,param,dkepath);
%
% Calculate the optimal number of processor (machine dependent)
%
% INPUTS: None
%
%  - display_mode: display some results [1,1]
%  - param: Structure for controling program. 
%  - dkepath: Structure of the paths 

%
% OUTPUTS:
%
%   - nproc: number of processor [1,1]
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
[status,message_proc] = unix('uname -p');%Processor type
[status,message_net] = unix('uname -n');%Network name of the machine
%
if status == 0,
    if (strfind(message_proc,'powerpc')>0 & strfind(message_net,'peysson')>0) | strfind(message_proc,'unknown'),%Personal computer of Yves Peysson
        nproc = nproc_powerbook_YVES(display_mode,param,dkepath);
    elseif strfind(message_proc,'x86_64')>0 & strfind(message_net,'saturne')>0,%SATURNE cluster @ CEA-DRFC     
        nproc = nproc_saturne_CEA_DRFC(display_mode,param,dkepath);
    elseif strfind(message_proc,'Intel')>0,
        nproc = 1;
    elseif strfind(message_proc,'YOUR_PROCESSOR_NAME')>0 & strfind(message_net,'YOUR_COMPUTER')>0,%YOUR computer. Replace here the name of your machine
        error('Your computer is not recognized by PETSc_Cloop_dke_ft.m. Please open the file and add the parameters of your environment !') 
% PUT HERE A FUNCTION SPECIFIC TO YOUR MACHINE THAT CALCULATES THE ADEQUATE NUMBER OF PROCESSORS
    else
        error('Your computer is not recognized by PETSc_Cloop_dke_ft.m. Please open the file and add the parameters of your environment !')             
    end
else
    error('This matrix solver cannot run on your computer which is not a Unix system. Sorry !'); 
end



