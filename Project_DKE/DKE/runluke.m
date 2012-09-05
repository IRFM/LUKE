function runluke(timeid,debugmode)
%
try
    %
    if nargin == 0,
        timeid = getenv('LUKE_timeid');
    else
        stimeid = whos('timeid');
        if ~strcmp(stimeid.class,'char'),
            timeid = int2str(timeid);
        end
    end
    %
    if nargin < 2,debugmode = 0;end
    %
    datapath = getenv('LUKE_datapath');
    xgridmode = getenv('LUKE_xgrid');
    logname = getenv('USER');
    %
    if debugmode,
        filediary = ['matlab_diary.',timeid];
        diary(filediary);
        %
        disp('-------- in runluke.m --------');
        disp(['datapath = ',datapath]);
        disp(['xgridmode = ',xgridmode]);
        disp(['logname = ',logname]);
        disp(['timeid = ',timeid]);
        disp('------------------------------');
    end
    %
    filein = [datapath,'LUKE_RUN_',logname,'_',timeid,'.mat'];
    %
    if xgridmode,
        fileout = ['LUKE_OUT_',logname,'_',timeid,'.mat'];
    else
        fileout = [datapath,'LUKE_OUT_',logname,'_',timeid,'.mat'];
    end
    %
    load(filein,'id_simul','wavestructs','waves','dkeparam','dkepath','equil','dkedisplay','ohm','transpfaste','ripple','Zf0_interp','XXsinksource','opt_save');
    %
    delete(filein);
    %
    if isempty(dkepath),
        dkepath = load_structures_yp('dkepath','','');
    else
        setpath_luke_jd(dkepath.luke_root,dkepath);
    end
    %
    warning off
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = ...
        run_lukert(id_simul,wavestructs,waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,Zf0_interp,XXsinksource,opt_save);   
    %
    save(fileout,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
    %
catch
    %
    lsterr = lasterror;
    %
    err = {'The action was cancelled due to the following error:','',lsterr.message};
    for il = 1:length(lsterr.stack),
        err = [err,['In ',lsterr.stack(il).file,' at line ',num2str(lsterr.stack(il).line)]];
    end
    %
    save(fileout,'err')
    %
end
%
