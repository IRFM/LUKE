%LUKE - Test function for LUKE distributed computing environment
%
clear functions
clear mex
%
[dkepath] = load_structures_yp('dkepath','','');
[cluster] = clustermode_luke(0,0,dkepath,'');%All cluster paramters and paths
%
if exist(fullfile(getenv('HOME'),'.dcluke.mat'),'file')
	delete(fullfile(getenv('HOME'),'.dcluke.mat'));
end
dirini = pwd;
cd(cluster.temppath);
filelist = ls;
if isempty(filelist),
    delete('*');
end
cd(dirini);
%
flag = dcluke(0,'RESET');
%
if flag,
    disp('Please, check first if LUKE distributed computing environnement is set-up for this machine !');
    disp('LUKE distributed computing not done.');
else
    id = dcluke('fundcluke',pi/3); 
    dcluke;
    tic,[e1_d,e2_d,e3_d] = dcluke(id);toc 
    disp('LUKE distributed computing done.');
end
%
tic,[e1,e2,e3] = fundcluke(pi/3);toc
disp('LUKE sequential computing done.');
%
disp('results: (sequential,distributed)');
if ~flag,
    [[e1,e1_d];[e2,e2_d];[e3,e3_d]]
else
    [[e1,NaN];[e2,NaN];[e3,NaN]]
end

