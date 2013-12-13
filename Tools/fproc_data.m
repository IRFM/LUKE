function data_proc = fproc_data(datapath,load_id,opt)
%
if nargin < 3,
    opt.save = 0;
    opt.nr_dep = 0;
    opt.peak = 'n';
    opt.wave = 'y';
    opt.rho = 'p';
end
%
% This function processes LUKE data
%
if length(load_id) > 5 && strcmp(load_id(1:5),'PROC_'),
    load_id = load_id(6:end);
end
if length(load_id) > 13 && strcmp(load_id(1:13),'LUKE_RESULTS_'),
    load_id = load_id(14:end);
end
if length(load_id) > 10 && strcmp(load_id(1:10),'LUKE_DATA_'),
    load_id = load_id(11:end);
end
%
datafile1 = ['LUKE_RESULTS_',load_id,'.mat'];
datafile2 = ['LUKE_DATA_',load_id,'.mat'];
proc_datafile1 = ['PROC_',datafile1];
proc_datafile2 = ['PROC_',datafile2];
%
procdata = 0;
%
data_proc = '';
%
if exist([datapath,proc_datafile1],'file') && (gettime_jd(proc_datafile1,datapath) > gettime_jd(datafile1,datapath)),
    %
    load([datapath,proc_datafile1],'data_proc');
    %
    procdata = 1;
    opt.save = 0;
    %
    datafile = datafile1;
    %
end
%
if procdata == 0 && exist([datapath,proc_datafile2],'file') && (gettime_jd(proc_datafile2,datapath) > gettime_jd(datafile2,datapath)),
    %
    load([datapath,proc_datafile2],'data_proc');
    %
    procdata = 1;
    opt.save = 0;
    %
    datafile = datafile2;
    %
end
%
if procdata == 0 && exist([datapath,datafile1],'file'),
    %
    data = load([datapath,datafile1]);
    %
    data_proc = proc_luke_jd(data,-1,-1,0.1,NaN,'',opt);
    %
    procdata = 1;
    %
    datafile = datafile1;
    %
end
%
if procdata == 0 && exist([datapath,datafile2],'file'),
    %
    data = load([datapath,datafile2]);
    %
    data_proc = proc_luke_jd(data.output,-1,-1,0.1,NaN,'',opt);
    %
    procdata = 1;
    %
    datafile = datafile2;
    %
end
%
if procdata == 0,
    disp('Warning : No data found, aborted')
    return
end
%  
if opt.save,
    %
    save([datapath,'PROC_',datafile],'data_proc');
    %
end
%
