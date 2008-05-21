clear all
close all
%
load initdata.mat
display.display_mode = 0;
%
opt = 2;
N = 10;
%
if opt == 1,
    %
    % Single job case
    %
    tic;
    [Zbouncecoef_old] = bouncecoefbuilder_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE);%bounce averaging coefficients
    time1 = toc;tic;
    [ZXXD_c_old,ZXXF_c_old,ZXXD_c_tp_old,ZXXF_c_tp_old,XXfM_old,XXILor_old] = coll_dke_jd(dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);%Collisions flux coefficients 
    time2 = toc;
    %
    disp(['--> time for bounce calculation : ',num2str(time1),' s'])
    disp(['--> time for collisions calculation : ',num2str(time2),' s'])
    %
    disp(['--> total time for single calculation : ',num2str(time2 + time1),' s'])
    %
    % Distributed job case
    %
    dkeparam = dkeparam_out;
    Zbouncecoef = Zbouncecoef_old;
    %
    delete('lukedata_in.mat');
    delete('lukedata_out.mat');
    %
    tic;
    save('lukedata_in.mat','dkepath','dkeparam','display','equilDKE','gridDKE','mksa','Zmomcoef','Zbouncecoef');
    %
    jm = findResource('scheduler','type','jobmanager','name', 'drfc');
    job = createJob(jm);
    %
    set(job,'PathDependencies',{pwd})
    set(job,'FileDependencies',{'jobStartup.m'})%,'lukedata.mat'    
    %
    createTask(job, @bouncecoefbuilder_dke_yp, 0);
    createTask(job, @coll_dke_jd, 0);
    %
    save('lukedata_out.mat','job');
    %
    submit(job);
    %
    while ~strcmp(get(job,'State'),'finished'),
    end
    %
    load('lukedata_out.mat','Zbouncecoef','ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor');
    %
    time = toc;
    %
    disp(['--> time for distributed calculation : ',num2str(time),' s'])
    %
    destroy(job)
    %
elseif opt == 2,
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
        dkeparam = dkeparam_out;
        %
        delete('lukedata_in.mat');
        delete('lukedata_out.mat');
        %
        tic;
        save('lukedata_in.mat','dkepath','dkeparam','display','equilDKE','gridDKE');
        %
        jm = findResource('scheduler','type','jobmanager','name', 'drfc');
        job = createJob(jm);
        %
        set(job,'PathDependencies',{pwd})
        set(job,'FileDependencies',{'jobStartup.m'})%,'lukedata.mat'    
        %
        for j=1:n,
            createTask(job, @bouncecoefbuilder_dke_yp, 0);
        end
        %
        save('lukedata_out.mat','job');
        %
        submit(job);
        %
        while ~strcmp(get(job,'State'),'finished'),
        end
        %
        load('lukedata_out.mat','Zbouncecoef');
        %
        destroy(job)
        %
        time_dist(n) = toc;
        %
        disp(['--> time for distributed calculation : ',num2str(time_dist(n)),' s'])
        %
    end
end
%
leg = ['Single     ';...
       'Distributed'];
%
graph1D_jd(1:N,time_sing,0,0,'','','',NaN,[0,N+1],NaN,'none','+','b',2,20);
graph1D_jd(1:N,time_dist,0,0,'N','time (s)','',leg,[0,N+1],NaN,'none','o','r',2,20,gca,0.9,0.7,0.7);
%

