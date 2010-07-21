function runluke(timeid)
%
try
    %
    timeid = getenv('LUKE_timeid');
    datapath = getenv('LUKE_datapath');
    %
    [res,logname] = unix('whoami');
    %
    if res ~= 0,
        error('Local login name could not be obtained')
    end
    %
    logname(double(logname) == 10) = [];
    %
    filein = [datapath,'LUKE_RUN_',logname,'_',timeid,'.mat'];
    fileout = [datapath,'LUKE_OUT_',logname,'_',timeid,'.mat'];
    %
    load(filein,'id_simul','wavestructs','waves','dkeparam','equil','dkedisplay','ohm','transpfaste','ripple')
    %
    delete(filein);
    %
    dkepath = load_structures_yp('dkepath','','');
    %
    warning off
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = ...
        run_lukert(id_simul,wavestructs,waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
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
