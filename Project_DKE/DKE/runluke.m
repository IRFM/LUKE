function runluke(timeid)
%
try
    %
    timeid = getenv('timeid');
    %
    [res,logname] = unix('whoami');
    %
    if res ~= 0,
        error('Local login name could not be obtained')
    end
    %
    logname(double(logname) == 10) = [];
    %
    filein = ['LUKE_RUN_',logname,'_',timeid,'.mat'];
    fileout = ['LUKE_OUT_',logname,'_',timeid,'.mat'];
    %
    load(filein,'id_simul','waves','dkeparam','equil','dkedisplay','ohm','transpfaste','ripple')
    %
    delete(filein);
    %
    dkepath = load_structures_yp('dkepath','','');
    %
    warning off
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = ...
        run_lukert(id_simul,[],waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
    %
    save(fileout,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource')
    %
    %
catch
    %
    err = lasterr;
    save(fileout,'err')
    %
end
%
