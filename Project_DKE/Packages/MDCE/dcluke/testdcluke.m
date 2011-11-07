%LUKE - Test function for LUKE distributed computing environment
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
clear all
if isappdata(0,'BATCH_DISTRIBUE_LUKE'),rmappdata(0,'BATCH_DISTRIBUE_LUKE');end
%
dkepath = load_structures_yp('dkepath','','');
[dkecluster] = clustermode_luke(2,'',dkepath);%Cluster parameters, paths and warnings. Must be called once before distributed computing
%
if dkecluster.scheduler.mode == 2,
    mkdir(dkecluster.scheduler.temppath);
    fileattrib(dkecluster.scheduler.temppath,'+w');
    %
	dcluke(dkecluster.scheduler,0,'RESET');
    id = dcluke(dkecluster.scheduler,'fundcluke',pi/3); 
    dcluke(dkecluster.scheduler);
    tic,[e1_d,e2_d,e3_d] = dcluke(dkecluster.scheduler,id);toc
    rmdir(dkecluster.scheduler.temppath,'s');
    disp('Calculations in the distributed computing mode done.');
else
	disp(dkecluster.scheduler.info);
end
%
tic,[e1,e2,e3] = fundcluke(pi/3);toc
disp('Calculations in the sequential computing mode done.');
%
disp('---------------------------------');
disp('Results: (sequential,distributed)');
disp('---------------------------------');
if dkecluster.scheduler.mode == 2,
    [[e1,e1_d];[e2,e2_d];[e3,e3_d]]
else
    [[e1,NaN];[e2,NaN];[e3,NaN]]
end

