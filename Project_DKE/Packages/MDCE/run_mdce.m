%LUKE - Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
load('initdata.mat','dkepath','dkeparam_out','display','equilDKE','gridDKE');%Load data for the MDCE example
%
dkepath = path_LUKE_LOCAL;
%
display.display_mode = 0;%no display
%
N = 10;
%
time_sing = NaN*ones(1,N);
time_dist = NaN*ones(1,N);
%
for n=1:N,
    %
    disp(['- n = ',num2str(n),' consecutive calculations'])
    %
    % Sequential job case
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    tic;[Zbouncecoef_seq] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,N,dkepath,display,0);time_seq(n) = toc;
    %
    disp(['   --> time for single calculation : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Distributed job case
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    tic;[Zbouncecoef_dist,flag] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,N,dkepath,display,1);time_dist(n) = toc;
    %
    if flag,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for single calculation : ',num2str(time_sing(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
end
%
leg = ['Single'];
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','+','b',2,20,gca,0.9,0.7,0.7);
%
if flag,
    leg = [leg;'Distributed'];
    graph1D_jd(1:N,time_dist,0,0,'N','time (s)','',leg,[0,N+1],NaN,'none','o','r',2,20,gca,0.9,0.7,0.7);
end
%
print_jd(2,'fig_mcde','.');

