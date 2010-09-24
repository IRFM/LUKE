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
datafile1 = ['LUKE_RESULTS_',load_id,'.mat'];
datafile2 = ['LUKE_DATA_',load_id,'.mat'];
proc_datafile1 = ['PROC_',datafile1];
proc_datafile2 = ['PROC_',datafile2];
%
procdata = 0;
%
data_proc = '';
%
if exist([datapath,proc_datafile1],'file'),
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
if procdata == 0 && exist([datapath,proc_datafile2],'file'),
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
