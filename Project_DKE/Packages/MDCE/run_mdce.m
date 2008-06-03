clear all
close all
%
load('initdata.mat','dkepath','dkeparam_out','display','equilDKE','gridDKE');
display.display_mode = 0;
temppath = '/home/sccp/gsem/decker/tmp/';
%
N = 10;
%
time_sing = NaN*ones(1,N);
time_dist = NaN*ones(1,N);
%
for n=1:N,
    %
    disp(['====> ',num2str(n),' consecutive calculations'])
    %
    % Single job case
    %
    tic;
    for j=1:n,
        [Zbouncecoef_old] = bouncecoefbuilder_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE);%bounce averaging coefficients
    end
    time_sing(n) = toc;
    %
    disp(['--> time for single calculation : ',num2str(time_sing(n)),' s'])
    %
    % Distributed job case
    %
    tic;
    %
    jm = findResource('scheduler','type','generic');
    %
    set(jm,'DataLocation',temppath);
    % ajout HP
    set(jm,'HasSharedFileSystem',true);
    %
    set(jm,'ClusterMatlabRoot','/usr/local/R2007B/');
    set(jm,'SubmitFcn',@pbsSubmitFcn)
    set(jm,'ParallelSubmitFcn',@pbsParallelSubmitFcn)
    %        
    job = createJob(jm);
    %
    for j=1:n,
        createTask(job,@bouncecoefbuilder_dke_yp,5,{dkepath,dkeparam_out,display,equilDKE,gridDKE});
    end
    %
    submit(job);
    %
    waitForState(job);
    %
    Zbouncecoef = getAllOutputArguments(job);
    %
    destroy(job)
    %
    time_dist(n) = toc;
    %
    disp(['--> time for distributed calculation : ',num2str(time_dist(n)),' s'])
    %
end
%
leg = ['Single     ';...
       'Distributed'];
%
graph1D_jd(1:N,time_sing,0,0,'','','',NaN,[0,N+1],NaN,'none','+','b',2,20);
graph1D_jd(1:N,time_dist,0,0,'N','time (s)','',leg,[0,N+1],NaN,'none','o','r',2,20,gca,0.9,0.7,0.7);
%
print_jd(2,'fig_mcde','.');

