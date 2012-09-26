function runluke(timeid,debugmode)
%
try
    %
    if nargin == 0,
        timeid = getenv('jobtimeid');
    else
        stimeid = whos('timeid');
        if ~strcmp(stimeid.class,'char'),
            timeid = int2str(timeid);% in case timeid is integer
        end
    end
    %
    if nargin < 2,
        debugmode = 0;
    end
    %
    if debugmode,
        filediary = ['matlab_diary.',timeid];
        diary(filediary);
    end
    %
    datapath = getenv('remotedatapath');
    xgridmode = getenv('LUKE_xgrid');
    logname = getenv('USER');
    %
    filein = [datapath,'LUKE_RUN_',logname,'_',timeid,'.mat'];
    %
    if xgridmode,
        fileout = ['LUKE_OUT_',logname,'_',timeid,'.mat'];
    else
        fileout = [datapath,'LUKE_OUT_',logname,'_',timeid,'.mat'];
    end
    %
    if debugmode,
        disp('-------- in runluke.m --------');
        disp(['datapath = ',datapath]);
        disp(['xgridmode = ',xgridmode]);
        disp(['logname = ',logname]);
        disp(['timeid = ',timeid]);
        disp(['filein = ',filein]);
        disp(['fileout = ',fileout]);
        disp('------------------------------');
    end
    %
    load(filein,'simul_in','wavestructs','waves','dkeparam','dkepath','equil','dkedisplay','ohm','transpfaste','ripple','Zf0_interp','XXsinksource','opt_save');
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
        run_lukert(simul_in,wavestructs,waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,Zf0_interp,XXsinksource,opt_save);   
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
if debugmode,
    diary off
end
%
