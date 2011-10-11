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
[vmatlab,testtoolbox] = matlabstatus_yp('Parallel Computing Toolbox');
%
Nmax = 4;
Configname = 'local';%'PBSPro';%
%
if vmatlab >= 77 && testtoolbox,
    set(findResource('scheduler','type',Configname),'ClusterSize',Nmax);%maximum local workers (max : number of physical cores recommanded) 
end
%
MDCE = 0;%Set to 1 if matlab MDCE is tested
LUKEDC = 0;%Set to 1 if batch DCLUKE is tested
PARLOOP = 1;%Set to 1 if parfor is tested
%
N = 2*Nmax;%number of jobs
%
time_seq = NaN*ones(1,N);flag_seq = cell(1,N);
time_par = NaN*ones(1,N);flag_par = cell(1,N);
time_mdce = NaN*ones(1,N);flag_mdce = cell(1,N);
time_ldce = NaN*ones(1,N);flag_ldce = cell(1,N);
%
Rp = equilDKE.Rp;
%
for n=1:N,
    %
    arg_range = '';%Set the number of input data
    for j = 1:n,
        equilDKE.Rp = Rp*(1 + 0.1*rand(1));%For changing the equilibrium
        arg_range{j} = equilDKE;
    end
    %
    % Sequential job (for loop)
    %
    [dkecluster] = clustermode_luke(0,'',dkepath,Configname);%All cluster paramters and paths
    %
    tic;[flag_seq{n},Zbouncecoef_seq] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_seq(n) = toc;
    %
    disp(['   --> time for n = ',int2str(n),' serial (for loop) calculations on (',int2str(1),' proc.) : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Matlab Distributed Computing Environment (MDCE)
    %
    if MDCE == 1,
        [dkecluster] = clustermode_luke(1,'',dkepath,Configname);%All cluster parameters and paths
        dkecluster.scheduler.size = min(n,dkecluster.scheduler.size);
        %
        tic;[flag_mdce{n},Zbouncecoef_mdce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_mdce(n) = toc;
        test_mdce(n) = comp_struct_jd(Zbouncecoef_seq,Zbouncecoef_mdce,0);
        %
        disp(['   --> time for n = ',int2str(n),' MDCE calculations on (',int2str(dkecluster.scheduler.size),' proc.) : ',num2str(time_mdce(n)),' s'])
        if test_mdce(n) == 1,
            disp('   --> sequential and MDCE calculations give same outputs');
        else
            disp('   --> WARNING: sequential and MDCE calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
    %
    % LUKE Distributed Computing Environment (LDCE)
    %
    if LUKEDC == 1,%All matlab may be used with this technique based on an external batch-queuing
        [dkecluster] = clustermode_luke(2,'',dkepath,Configname);%All cluster parameters and paths
        dkecluster.scheduler.size = min(n,dkecluster.scheduler.size);
        dkecluster.scheduler.enforce = 0;
        %
    	tic;[flag_ldce{n},Zbouncecoef_ldce] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_ldce(n) = toc;
        test_ldce(n) = comp_struct_jd(Zbouncecoef_seq,Zbouncecoef_ldce,0);
        %
        disp(['   --> time for n = ',int2str(n),' LDCE calculations on (',int2str(dkecluster.scheduler.size),' proc.) : ',num2str(time_ldce(n)),' s'])
        if test_ldce(n) == 1,
            disp('   --> sequential and LDCE calculations give same outputs');
        else
            disp('   --> WARNING: sequential and LDCE calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
    %
    % Parallel job (parfor loop)
    %
    if PARLOOP == 1,
        [dkecluster] = clustermode_luke(3,'',dkepath,Configname);%All cluster paramters and paths
        dkecluster.scheduler.size = min(n,dkecluster.scheduler.size);
        %
        tic;[flag_par{n},Zbouncecoef_par] = mdce_luke(@bouncecoefbuilder_dke_yp,{dkeparam_out,display,equilDKE,gridDKE},3,arg_range,dkecluster);time_par(n) = toc;
        matlabpool close force
        test_par(n) = comp_struct_jd(Zbouncecoef_seq,Zbouncecoef_par,0);
        %    
        disp(['   --> time for n = ',int2str(n),' parallel (parfor loop) calculations on (',int2str(dkecluster.scheduler.size),' proc.) : ',num2str(time_par(n)),' s'])
        if test_par(n) == 1,
            disp('   --> sequential and parallel (parfor loop) calculations give same outputs');
        else
            disp('   --> WARNING: sequential and parallel (parfor loop) calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
end
%
leg = 'Serial                                    ';
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
if PARLOOP == 1,
    leg = [leg;'Parallel                                  '];
    graph1D_jd(1:N,time_par,0,0,'','','',leg,[0,N+1],NaN,'none','x','r',2,20,gca,0.9,0.7,0.7);
end
%
if MDCE == 1,
    leg = [leg;'MDCE                                      '];
    graph1D_jd(1:N,time_mdce',0,0,'N processors','time (s)','',leg,[0,N],NaN,'none','s','g',2,20,gca,0.9,0.7,0.7);
end
%
if LUKEDC == 1,
    leg = [leg;'LDCE                                      '];
    graph1D_jd(1:N,time_ldce',0,0,'N processors','time (s)','',leg,[0,N],NaN,'none','d','g',2,20,gca,0.9,0.7,0.7);
end
%

	
