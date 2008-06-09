%LUKE - Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
load('initdata.mat','dkeparam_out','display','equilDKE','gridDKE');%Load data for the MDCE example
%
dkepath = path_LUKE_LOCAL;
%
display.display_mode = 0;%no display
%
N = 10;%number of jobs
nprocmax1 = 1;%maximum number of processors involved
nprocmax4 = 4;%maximum number of processors involved
nprocmax8 = 8;%maximum number of processors involved
%
time_seq = NaN*ones(1,N);flag_seq = NaN*ones(1,N);
time_dist1 = NaN*ones(1,N);flag_dist1 = NaN*ones(1,N);
time_dist4 = NaN*ones(1,N);flag_dist4 = NaN*ones(1,N);
time_dist8 = NaN*ones(1,N);flag_dist8 = NaN*ones(1,N);
%
timeout = 70;%Jump into sequential processing if distributed processing is blocked (s)
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
    tic;[flag_seq(n),Zbouncecoef_seq] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,nprocmax1,dkepath,display.display_mode,0);time_seq(n) = toc;
    %
    disp(['   --> time for single calculation : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Distributed job case (1 processor)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    tic;[flag_dist1(n),Zbouncecoef_dist] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,nprocmax1,dkepath,display.display_mode,1,timeout);time_dist1(n) = toc;
    %
    if flag_dist1(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation (1 processor) : ',num2str(time_dist1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_dist1(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_dist1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (4 processors)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    tic;[flag_dist4(n),Zbouncecoef_dist] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,nprocmax4,dkepath,display.display_mode,1,timeout);time_dist4(n) = toc;
    %
    if flag_dist4(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation (4 processors) : ',num2str(time_dist4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_dist4(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_dist4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (8 processors)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    tic;[flag_dist8(n),Zbouncecoef_dist] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,nprocmax8,dkepath,display.display_mode,1,timeout);time_dist8(n) = toc;
    %
    if flag_dist8(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation (8 processors) : ',num2str(time_dist8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_dist8(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_dist8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
end
%
leg = ['Single                        '];
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed (1 proc.)         '];
graph1D_jd(1:N,time_dist1',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed (4 proc.)         '];
graph1D_jd(1:N,time_dist4',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed (8 proc.)         '];
graph1D_jd(1:N,time_dist8',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','g',2,20,gca,0.9,0.7,0.7);
%
time_dist1_timeout = time_dist1.*flag_dist1;
time_dist1_timeout(find(time_dist1_timeout>0)) = NaN;
time_dist1_timeout = abs(time_dist1_timeout);
%
time_dist4_timeout = time_dist4.*flag_dist4;
time_dist4_timeout(find(time_dist4_timeout>0)) = NaN;
time_dist4_timeout = abs(time_dist4_timeout);
%
time_dist8_timeout = time_dist8.*flag_dist8;
time_dist8_timeout(find(time_dist8_timeout>0)) = NaN;
time_dist8_timeout = abs(time_dist8_timeout);
%
leg = [leg;'Distributed time out (1 proc.)'];
graph1D_jd(1:N,time_dist1_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out (4 proc.)'];
graph1D_jd(1:N,time_dist4_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out (8 proc.)'];
graph1D_jd(1:N,time_dist8_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Time out level                '];
graph1D_jd(0:N,timeout*ones(N+1,1),0,0,'N','time (s)','',leg,[0,N],NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
%
print_jd(2,'fig_mcde','.');

