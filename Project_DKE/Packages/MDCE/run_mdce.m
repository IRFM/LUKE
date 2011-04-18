%LUKE - Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
dkepath = load_structures_yp('dkepath','','');
%
load('initdata.mat','dkeparam_out','display','equilDKE','gridDKE');%Load data for the MDCE example
%
display.display_mode = 0;%no display
%
N = 10;%number of jobs
nprocmax1 = 1;%maximum number of processors involved
nprocmax4 = 4;%maximum number of processors involved
nprocmax8 = 8;%maximum number of processors involved
%
time_seq = NaN*ones(1,N);flag_seq = cell(1,N);
%
time_mdce1 = NaN*ones(1,N);flag_mdce1 = NaN*ones(1,N);
time_mdce4 = NaN*ones(1,N);flag_mdce4 = NaN*ones(1,N);
time_mdce8 = NaN*ones(1,N);flag_mdce8 = NaN*ones(1,N);
%
time_ldce = NaN*ones(1,N);flag_ldce = cell(1,N);
%
flag_mode1 = 0;
flag_mode2 = 0;
%
for n=1:N,
    %
    disp(['- n = ',num2str(n),' calculations'])
    %
    % Sequential job case
    %
    arg_range = '';
    for j = 1:n,arg_range{j} = equilDKE;end
    %
    [dkecluster] = clustermode_luke(0,'',0,dkepath.remote);%All cluster paramters and paths
    dkecluster.size = n;
    
    tic;[flag_seq{n},Zbouncecoef_seq] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_seq(n) = toc;
    %
    disp(['   --> time for consecutive calculations (1 proc.) : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Distributed job case (1 processor)
    %
%    [dkecluster] = clustermode_luke(1,'',0,dkepath.remote);%All cluster paramters and paths
%    dkecluster.size = nprocmax1;
%    if dkecluster.mode == 1,%(MDCE only with 1 processor called)
%    	tic;[flag_mdce1(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_mdce1(n) = toc;
%		flag_mode1 = 1;
%    end
    [dkecluster] = clustermode_luke(2,'',0,dkepath.remote);%All cluster paramters and paths
    dkecluster.enforce = 0;
    dkecluster.size = n;
    if dkecluster.mode == 2,%All matlab may be used with this technique based on an external batch-queuing
    	tic;[flag_ldce{n},Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_ldce(n) = toc;
        flag_mode2 = 1;
    end
    %
%    if flag_mdce1(n) == 1 & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations'])
%        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (1 processor) : ',num2str(time_mdce1(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    elseif flag_mdce1(n) <= -1 & & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
%        disp(['--> time for sequential calculation : ',num2str(time_mdce1(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    end
    %
    if all(flag_ldce{n} == 2) && dkecluster.mode == 2,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the LUKE distributed computing toolbox using ',num2str(n),' jobs in batch queing mode: ',num2str(time_ldce(n)),' s'])
        disp('-------------------------------------------------------------------------')
    else
        disp('One or more calculations with distributed computing did not complete. Please check.')
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (MDCE only with 4 processors called)
    %
%    [dkecluster] = clustermode_luke(1,'',0,dkepath.remote);%All cluster paramters and paths
%    dkecluster.size = nprocmax4;
%    if dkecluster.mode == 1,
%    	tic;[flag_mdce4(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_mdce4(n) = toc;
%    end
    %
%    if flag_mdce4(n) == 1 & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations'])
%        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (4 processors) : ',num2str(time_mdce4(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    elseif flag_mdce4(n) <= -1 & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
%        disp(['--> time for sequential calculation : ',num2str(time_mdce4(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    end
    %
    % Distributed job case (MDCE only with 8 processors called)
    %
%    [dkecluster] = clustermode_luke(1,'',0,dkepath.remote);%All cluster paramters and paths
%    dkecluster.size = nprocmax8;
%    if dkecluster.mode == 1,
%        tic;[flag_mdce8(n),Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_mdce8(n) = toc;
%    end
    %
%    if flag_mdce8(n) == 1 & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations'])
%        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (8 processors) : ',num2str(time_mdce8(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    elseif flag_mdce8(n) <= -1 & dkecluster.mode == 1,
%        disp(['- n = ',num2str(n),' distributed calculations with the MatLab toolbox is called but time out is reached. Sequential processing performed.'])
%        disp(['--> time for sequential calculation : ',num2str(time_mdce8(n)),' s'])
%        disp('-------------------------------------------------------------------------')
%    end
end
%
leg = {'Single'};
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
if flag_mode1,
	leg = [leg;'Distributed, MatLab toolbox (1 proc.)'];
	graph1D_jd(1:N,time_mdce1',0,0,'N','time (s)','',leg,[0,N],NaN,'none','s','g',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed, MatLab toolbox (4 proc.)'];
	graph1D_jd(1:N,time_mdce4',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed, MatLab toolbox (8 proc.)'];
	graph1D_jd(1:N,time_mdce8',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','g',2,20,gca,0.9,0.7,0.7);
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
	leg = [leg;'Distributed time out, MatLab toolbox (1 proc.)'];
	graph1D_jd(1:N,time_mdce1_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','s','r',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed time out, MatLab toolbox (4 proc.)'];
	graph1D_jd(1:N,time_mdce4_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','r',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed time out, MatLab toolbox (8 proc.)'];
	graph1D_jd(1:N,time_mdce8_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','r',2,20,gca,0.9,0.7,0.7);
	%
end
%
if flag_mode2,
	leg = [leg;'Distributed, LUKE toolbox'];
	graph1D_jd(1:N,time_ldce',0,0,'N','time (s)','',leg,[0,N],NaN,'none','d','g',2,20,gca,0.9,0.7,0.7);
	%
	time_ldce_timeout = time_ldce;%.*flag_ldce;
	time_ldce_timeout(find(time_ldce_timeout>0)) = NaN;
	time_ldce_timeout = abs(time_ldce_timeout);
	%
	leg = [leg;'Distributed time out, LUKE toolbox'];
	graph1D_jd(1:N,time_ldce_timeout',0,0,'N','time (s)','',leg,[0,N],NaN,'none','d','r',2,20,gca,0.9,0.7,0.7);
	%
end
%
leg = [leg;'Time out level'];
graph1D_jd(0:N,dkecluster.timeout*ones(N+1,1),0,0,'N','time (s)','',leg,[0,N],NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
%
if flag_mode1 & flag_mode2,
	print_jd(2,'fig_mcde_lcde','.');
elseif ~flag_mode1 & flag_mode2,
	print_jd(2,'fig_lcde','.');
elseif flag_mode1 & ~flag_mode2,
	print_jd(2,'fig_mcde','.');
elseif ~flag_mode1 & ~flag_mode2,
	print_jd(2,'fig_seq','.');
end
