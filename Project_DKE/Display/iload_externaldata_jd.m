function external = iload_externaldata_jd(dkepath,basestr,workdir,opt_gui)
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
%
t1 = input_dke_yp('Averaging of shot data, initial time',[],'','',[1,1]);
t2 = input_dke_yp('Averaging of shot data, final time',[],'','',[1,1]);
shotime = input_dke_yp('Shot time',(t1 + t2)/2,'','',[1,1]);
%
shotime = num2str(shotime,'%6.4f');
%
external = feval(fname,workdir,shotnum,shotime,t1,t2,opt_gui);

