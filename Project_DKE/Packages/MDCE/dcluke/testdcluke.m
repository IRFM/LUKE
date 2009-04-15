%LUKE - Test function for LUKE distributed computing environment
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
clear all
%
dkepath = load_structures_yp('dkepath','','');
[cluster] = clustermode_luke(2,'',1);%Cluster parameters, paths and warnings. Must be called once before distributed computing
%
if cluster.mode == 2,
	dcluke(cluster,0,'RESET');
    id = dcluke(cluster,'fundcluke',pi/3); 
    dcluke(cluster);
    tic,[e1_d,e2_d,e3_d] = dcluke(cluster,id);toc
    rmdir(cluster.temppath,'s');%Must always be done after distributed computing call
    disp('Calculations in the distributed computing mode done.');
else
	disp(cluster.info);
end
%
tic,[e1,e2,e3] = fundcluke(pi/3);toc
disp('Calculations in the sequential computing mode done.');
%
disp('---------------------------------');
disp('Results: (sequential,distributed)');
disp('---------------------------------');
if cluster.mode == 2,
    [[e1,e1_d];[e2,e2_d];[e3,e3_d]]
else
    [[e1,NaN];[e2,NaN];[e3,NaN]]
end

