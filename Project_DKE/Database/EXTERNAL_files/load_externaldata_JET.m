function external = load_externaldata_JET(workdir,shotnum,shotime,t1,t2,opt_gui)
%
% This function loads data from JET database using zjet
%
external = '';
% basestr = 'JET';
%
% -------------------------------------------------------------------------
%
% addpath('/luke/Projet_Cronos/acces/jet/interface')
% addpath('/luke/Projet_Cronos/')
% zineb_path
% %
% % script de demarrage de l'interface de preparation des donnees JET
% %
% setappdata(0,'langue_cronos','anglais');
% %
% if ~exist('zuijetdata','file'),
%     disp('-----> Access to the JET database is not granted.')
%     disp('-----> You need the zuijetdata.m file in the matlab path.');
%     return;
% end
% %
% zuijetdata(shotnum);
%
% -------------------------------------------------------------------------
%
% filestr = [shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2)];
% datafile = ['data_for_LUKE_',filestr,'.mat'];
% %
% [datafile,datapath] = igetfile_jd(opt_gui,datafile,'Please select the JET data file',workdir);
% %
% if datafile == 0,
%     return
% end
% %
% load([datapath,datafile],'x','y','Rp','Zp','xypsin','psia','xBt',...
%     'xne','xTe','Zeff');
%
% -------------------------------------------------------------------------
%
addpath('/luke/Projet_Cronos/acces/jet/bilan')
addpath('/luke/Projet_Cronos/acces/jet/bilan/zwingmann')
%
shotimenum = str2num(shotime);
%
datadir = igetdir_jd(opt_gui,'Please select the JET data directory',workdir);
%
efitstr = [datadir,'/efit',shotnum,'.mat'];
tempstr = [datadir,'/temp',shotnum,'.mat'];
profstr = [datadir,'/prof',shotnum,'.mat'];
nexstr = [datadir,'/nex',shotnum,'.mat'];
texstr = [datadir,'/tex',shotnum,'.mat'];
%
if exist(efitstr,'file') && exist(tempstr,'file') && exist(profstr,'file'),
    %
    load(tempstr,'emap','fbnd','faxs','tzeff','zefv','zefh');
    load(efitstr,'tefit','psix','qx');
    load(profstr,'rbnd','zbnd','rth','tth','neth','teth');
    %
    if exist(nexstr,'file')
        load(nexstr,'nex');
    else
        nex = [];
    end
    %
    if exist(texstr,'file')
        load(texstr,'tex');
    else
        tex = [];
    end
    %
else
    error(['equilibrium data not found for shot ',shotnum]);
end
%
% Magnetic Equilibrium
%
timediff = tefit - shotimenum;
kf = find(abs(timediff) == min(abs(timediff)),1,'first');
psia = fbnd(kf);
psip_old = faxs(kf);
psix = psix(kf,:);
pq = qx(kf,:);
%
np = 100;
nz = 100;
%
R2 = linspace(min(rbnd(kf,:))*0.9,max(rbnd(kf,:))*1.1,np);
Z2 = linspace(min(zbnd(kf,:))*1.1,max(zbnd(kf,:))*1.1,nz);
[R,Z] = meshgrid(R2,Z2);
%
[psi,Br,Bz,Bt,err] = jetequi3(R,Z,emap,tefit(kf));%+40
%
xypsi = psi.';
%xyBr = Br.';
%xyBz = Bz.';
xBt = -Bt;% negative sign for phi orientation
%
R = R(1,:);
Z = Z(:,1).';
%
mask = find(all(xypsi.' == repmat(xypsi(:,1).',[nz,1])));
%
R(mask) = [];
xypsi(mask,:)=  [];
%xyBr(mask,:)=  [];
%xyBz(mask,:)=  [];
xBt(mask)=  [];
%
sigma = sign(psia);
Ns = 101;
%
psip = min(min(sigma*xypsi));
[iR,iZ] = find(sigma*xypsi == psip);
%
if length(iR) ~= 1,
    error('unable to locate minimum in xypsi data');
end
%
ss = linspace(0,1,Ns);
sR = R(iR-1) + (R(iR+1)-R(iR-1))*ss;
sZ = Z(iZ-1) + (Z(iZ+1)-Z(iZ-1))*ss;
%
sspsi = interp2(R,Z,xypsi.',sR.',sZ,'spline').';
psip = sigma*min(min(sigma*sspsi));
[isR,isZ] = find(sspsi == psip);
%
if length(isR) ~= 1,
    error('unable to locate minimum in xypsi data');
end
%
Rp = sR(isR);
Zp = sZ(isZ);
%
disp(['Old value of psip: ',num2str(psip_old),', new value: ',num2str(psip)])
disp(['Rp: ',num2str(Rp)])
disp(['Zp: ',num2str(Zp)])
%
x = R - Rp;
y = Z - Zp;
xypsi = xypsi - psip;
psia = psia - psip;
psix = psix - psip;
%
xypsin = xypsi/psia;
psin = psix/psia;
psin(1) = 0;
%
% Profiles
%
xth = rth - Rp;
method = 'linear';
%
nt = length(tth);
%
tth = tth.';
%
tth_S = [tth(1),(tth(1:end-1) + tth(2:end))/2,tth(end)];
dtth = min([tth_S(2:end);t2*ones(1,nt)]) - max([tth_S(1:end-1);t1*ones(1,nt)]);
dtth(dtth < 0) = 0;
rdtth = repmat(dtth.',[1,length(rth)]);
pdtth = repmat(dtth.',[1,length(psin)]);
%
neth = sum(neth.*rdtth)/(t2-t1);
teth = sum(teth.*rdtth)/(t2-t1);
if ~isempty(nex),
    pne = sum(nex.*pdtth)/(t2-t1);
else
    pne = [];
end
if ~isempty(tex),
    pTe = sum(tex.*pdtth)/(t2-t1);
else
    pTe = [];
end
%
xne = interp1(xth,neth,x,method);
xTe = interp1(xth,teth,x,method);
Zeff = interp1(tzeff,(zefh + zefv)/2,shotimenum);
%
filestr = [shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2),'.mat'];
%
% Data saved for irunluke
%
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
%
external.equil.magnetic.x = x;
external.equil.magnetic.y = y;
external.equil.magnetic.Rp = Rp;
external.equil.magnetic.Zp = Zp;
external.equil.magnetic.xypsin = xypsin;
external.equil.magnetic.psia = psia;
external.equil.magnetic.xBt = xBt;
external.equil.magnetic.psin = psin;
external.equil.magnetic.pq = pq;
%
external.equil.prof.xne = xne;
external.equil.prof.xTe = xTe;
external.equil.prof.Zeff = Zeff;
external.equil.prof.psin = psin;
external.equil.prof.pne = pne;
external.equil.prof.pTe = pTe;
%
% external.ohm. = ;
% external.wave. = ;
%
external.id = ['JET_',filestr];

