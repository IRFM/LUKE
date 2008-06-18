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
%
time_mdce1 = NaN*ones(1,N);flag_mdce1 = NaN*ones(1,N);
time_mdce4 = NaN*ones(1,N);flag_mdce4 = NaN*ones(1,N);
time_mdce8 = NaN*ones(1,N);flag_mdce8 = NaN*ones(1,N);
%
time_ldce1 = NaN*ones(1,N);flag_ldce1 = NaN*ones(1,N);
time_ldce4 = NaN*ones(1,N);flag_ldce4 = NaN*ones(1,N);
time_ldce8 = NaN*ones(1,N);flag_ldce8 = NaN*ones(1,N);
%
%
[cluster] = clustermode_luke;
cluster.timeout = 70;%Jump into sequential processing if distributed processing is blocked (s)


n = 3
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    cluster.mode = 2;
    cluster.size = nprocmax1;
    tic;[flag_ldce1(n),Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_ldce1(n) = toc;
    return

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
    cluster.mode = 0;
    cluster.size = nprocmax1;
    tic;[flag_seq(n),Zbouncecoef_seq] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_seq(n) = toc;
    %
    disp(['   --> time for single calculation : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Distributed job case (1 processor)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    cluster.mode = 1;
    cluster.size = nprocmax1;
    tic;[flag_mdce1(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_mdce1(n) = toc;
    cluster.mode = 2;
    cluster.size = nprocmax1;
    tic;[flag_ldce1(n),Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_ldce1(n) = toc;
    %
    if flag_mdce1(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (1 processor) : ',num2str(time_mdce1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_mdce1(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_mdce1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
 %
    if flag_ldce1(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the LUKE distributed computing toolbox (1 processor) : ',num2str(time_ldce1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_ldce1(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the LUKE toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_ldce1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (4 processors)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    cluster.mode = 1;
    cluster.size = nprocmax4;
    tic;[flag_mdce4(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_mdce4(n) = toc;
    cluster.mode = 2;
    cluster.size = nprocmax4;
    tic;[flag_ldce4(n),Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_ldce4(n) = toc;
    %
    if flag_mdce4(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (4 processors) : ',num2str(time_mdce4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_mdce4(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_mdce4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
	%
    if flag_ldce4(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the LUKE distributed computing toolbox (4 processors) : ',num2str(time_ldce4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_ldce4(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the LUKE toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_ldce4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (8 processors)
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    cluster.mode = 1;
    cluster.size = nprocmax8;
    tic;[flag_mdce8(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_mdce8(n) = toc;
    cluster.mode = 2;
    cluster.size = nprocmax8;
    tic;[flag_ldce8(n),Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkepath,dkeparam_out,display,equilDKE,gridDKE},4,arg_range,cluster);time_ldce8(n) = toc;
    %
    if flag_mdce8(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (8 processors) : ',num2str(time_mdce8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_mdce8(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_mdce8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
	%
    if flag_ldce8(n) == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the LUKE distributed computing toolbox (8 processors) : ',num2str(time_ldce8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    elseif flag_ldce8(n) == -1,
        disp(['- n = ',num2str(n),' distributed calculations with the LUKE toolbox is called but time out is reached. Sequential processing performed.'])
        disp(['--> time for sequential calculation : ',num2str(time_ldce8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
end
%
leg = ['Single                        '];
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, MatLab toolbox (1 proc.)         '];
graph1D_jd(1:N,time_mdce1',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, MatLab toolbox (4 proc.)         '];
graph1D_jd(1:N,time_mdce4',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, MatLab toolbox (8 proc.)         '];
graph1D_jd(1:N,time_mdce8',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','g',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, LUKE toolbox (1 proc.)         '];
graph1D_jd(1:N,time_ldce1',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','m',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, LUKE toolbox (4 proc.)         '];
graph1D_jd(1:N,time_ldce4',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','m',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed, LUKE toolbox (8 proc.)         '];
graph1D_jd(1:N,time_ldce8',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','m',2,20,gca,0.9,0.7,0.7);
%
time_mdce1_timeout = time_mdce1.*flag_mdce1;
time_mdce1_timeout(find(time_mdce1_timeout>0)) = NaN;
time_mdce1_timeout = abs(time_mdce1_timeout);
%
time_mdce4_timeout = time_mdce4.*flag_mdce4;
time_mdce4_timeout(find(time_mdce4_timeout>0)) = NaN;
time_mdce4_timeout = abs(time_mdce4_timeout);
%
time_mdce8_timeout = time_mdce8.*flag_mdce8;
time_mdce8_timeout(find(time_mdce8_timeout>0)) = NaN;
time_mdce8_timeout = abs(time_mdce8_timeout);
%
time_ldce1_timeout = time_ldce1.*flag_ldce1;
time_ldce1_timeout(find(time_ldce1_timeout>0)) = NaN;
time_ldce1_timeout = abs(time_ldce1_timeout);
%
time_ldce4_timeout = time_ldce4.*flag_ldce4;
time_ldce4_timeout(find(time_ldce4_timeout>0)) = NaN;
time_ldce4_timeout = abs(time_ldce4_timeout);
%
time_ldce8_timeout = time_ldce8.*flag_ldce8;
time_ldce8_timeout(find(time_ldce8_timeout>0)) = NaN;
time_ldce8_timeout = abs(time_ldce8_timeout);
%
leg = [leg;'Distributed time out, MatLab toolbox (1 proc.)'];
graph1D_jd(1:N,time_mdce1_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out, MatLab toolbox (4 proc.)'];
graph1D_jd(1:N,time_mdce4_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out, MatLab toolbox (8 proc.)'];
graph1D_jd(1:N,time_mdce8_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','r',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out, LUKE toolbox (1 proc.)'];
graph1D_jd(1:N,time_ldce1_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','k',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out, LUKE toolbox (4 proc.)'];
graph1D_jd(1:N,time_ldce4_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','k',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Distributed time out, LUKE toolbox (8 proc.)'];
graph1D_jd(1:N,time_ldce8_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','k',2,20,gca,0.9,0.7,0.7);
%
leg = [leg;'Time out level                '];
graph1D_jd(0:N,timeout*ones(N+1,1),0,0,'N','time (s)','',leg,[0,N],NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
%
print_jd(2,'fig_mcde','.');

