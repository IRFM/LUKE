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
function done = sluke_all_sim_done(sparams)
% done = sluke_all_sim_done
%
% sluke_all_sim_done(sparams) returns true if in the current folder is
% present a folder named 'SLUKE_RESULTS' and it contains for each
% simulation either a file named 'PROC_LUKE_DATA(...).mat' or
% 'LUKE_DATA(...).mat' and contains the variable 'output' and false 
% otherwise.
 
% Riccardo Saura IRFM/CEA riccardo.saura@cea.fr 
% v.1 20.12.2023 

if any(cell2mat(sparams.discharge.nt) ~= 1)
    sparams = sluke_params_time(sparams);
end

nSim = length(sparams.machine);

if exist('SLUKE_RESULTS','dir')
    done = true;
else 
    done = false;
    %If there is not a folder called 'SLUKE_RESULTS' do not even bother to
    %start
end

ii = 1;
while ii <= nSim && done %% Exit if you do not find all done
    simul_id = sluke_id(sparams,ii);
    
    if ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA',simul_id,'.mat'],'file') 
        %If exist no need to check else. The ii-th simulation is done.
        if exist(['SLUKE_RESULTS/LUKE_DATA',simul_id,'.mat'],'file')
            %If exist LUKE_DATA could be both for saved data than job. Only
            %saved data contains the variable 'output'
            datas = who('-file',['SLUKE_RESULTS/LUKE_DATA',simul_id,'.mat']);
            done = any(strcmp(datas,'output'));
        else
            %If LUKE_DATA nor PROC_LUKE_DATA do not exist the simulation has not been done. 
            done = false;
        end
    end
    
    ii = ii + 1; %Index update
end

end