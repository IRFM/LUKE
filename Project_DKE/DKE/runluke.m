function runluke(timeid)

% delete mlog.txt
% diary mlog.txt
% disp('============================')
% disp('')

try
%     runlist = [];
%     filelist = what(pwd);
%     matlist = filelist.mat;
%     for ifile = 1:length(matlist),
%         if strfind(matlist{ifile},'LUKE_RUN');
%             runlist = [runlist;matlist{ifile}(10:21)];
%         end
%     end
%     if isempty(runlist),
%         error('No run input file')
%     end
%     runlist = str2num(runlist);
%     %ifile = num2str(max(runlist));
%     ifile = num2str(min(runlist));
%     if length(ifile) == 11,
%         ifile=['0',ifile];
%     end
%     filein = ['LUKE_RUN_',ifile,'.mat'];
%     fileout = ['LUKE_OUT_',ifile,'.mat'];
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
%     [dummy,logname] = unix('whoami');
%     dkepath.temppathroot = ['/home/',logname(1:end-1),'/tmp/'];
    %
    warning off
    %
    path
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = ...
        run_lukert(id_simul,[],waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
    %
    save(fileout,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource')
    %
%     [dummy,logname] = unix('whoami');
%     %
%     if strfind(logname,'jdecker'),
%             logname = 'decker';
%     end
%     %
%     unix(['scp ',fileout,' ',logname,'@crpppc70.epfl.ch:./'])
%     
%     delete(fileout);
    %
catch
    %
    err = lasterr;
    save(fileout,'err')
    %
end
%
% diary off
% exit
%
