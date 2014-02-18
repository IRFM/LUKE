%LUKE - Test function for LUKE distributed computing environment
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
clear all
if isappdata(0,'BATCH_DISTRIBUE_LUKE'),rmappdata(0,'BATCH_DISTRIBUE_LUKE');end
%
nrun = 7;%number of jobs
%
dkepath = load_structures_yp('dkepath','','');
[dkecluster] = clustermode_luke(2,'',dkepath);%Cluster parameters, paths and warnings. Must be called once before distributed computing
%
if dkecluster.scheduler.mode == 2,
    mkdir(dkecluster.scheduler.temppath);
    fileattrib(dkecluster.scheduler.temppath,'+w');
    %
	dcluke(dkecluster.scheduler,0,'RESET');
    %
    for irun = 1:nrun,
        id(irun) = dcluke(dkecluster.scheduler,'fundcluke',pi/3);
    end
    dcluke(dkecluster.scheduler);
    for irun = 1:nrun,
        tic,[e1_d(irun),e2_d(irun),e3_d(irun)] = dcluke(dkecluster.scheduler,id(irun));toc
    end
    try
        rmdir(dkecluster.scheduler.temppath,'s');
    catch
        disp(['WARNING : tmp directory ',dkecluster.scheduler.temppath,' could not be removed.'])
    end
    disp('Calculations in the distributed computing mode done.');
else
	disp(dkecluster.scheduler.info);
end
%
tic,[e1,e2,e3] = fundcluke(pi/3);toc
disp('Calculations in the sequential computing mode done.');
%
disp('---------------------------------');
disp('Results: (sequential : distributed)');
disp('---------------------------------');
%
e1_out = e1;
e2_out = e2;
e3_out = e3;
%
e1_out = [num2str(e1_out),' :'];
e2_out = [num2str(e2_out),' :'];
e3_out = [num2str(e3_out),' :'];
%
for irun = 1:nrun,
    if dkecluster.scheduler.mode == 2,
        e1_out = [e1_out,' ',num2str(e1_d(irun))];
        e2_out = [e2_out,' ',num2str(e2_d(irun))];
        e3_out = [e3_out,' ',num2str(e3_d(irun))];
       
    else
        e1_out = [e1_out,' NaN'];
        e2_out = [e2_out,' NaN'];
        e3_out = [e3_out,' NaN'];
    end
end
%
[e1_out;e2_out;e3_out]
