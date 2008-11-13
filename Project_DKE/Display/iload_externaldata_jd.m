function external = iload_externaldata_jd(basestr,workdir)
%
% This function loads data from external database
%
external = '';
%
fname = ['load_externaldata_',basestr];
%
if ~exist(fname,'file'),
    %
    disp(['-----> Database access is not implemented for ',basestr]);
    return;    
    %
end    
%    
shotnum = input_dke_yp('Shot number','');
shotime = input_dke_yp('Shot time',[],'','',[1,1]);
%
shotime = num2str(shotime,'%6.4f');
%
t1 = input_dke_yp('Averaging of shot data, initial time',[],'','',[1,1]);
t2 = input_dke_yp('Averaging of shot data, final time',[],'','',[1,1]);
%
external = feval(fname,workdir,shotnum,shotime,t1,t2);

