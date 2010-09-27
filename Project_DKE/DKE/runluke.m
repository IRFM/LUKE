function runluke(timeid)
%
try
    %
    if nargin == 0,
        timeid = getenv('LUKE_timeid');
    end        
    datapath = getenv('LUKE_datapath');
    %
    logname = getenv('USER');
    %
    filein = [datapath,'LUKE_RUN_',logname,'_',timeid,'.mat'];
    fileout = [datapath,'LUKE_OUT_',logname,'_',timeid,'.mat'];
    %
    load(filein,'id_simul','wavestructs','waves','dkeparam','dkepath','equil','dkedisplay','ohm','transpfaste','ripple','Zf0_interp')
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
        run_lukert(id_simul,wavestructs,waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,Zf0_interp,[],0);
    %
    save(fileout,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource')
    %
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
