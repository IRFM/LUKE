function equil = fmake_equil_KSTAR_jd(eqdsk_path,eqdsk_file,ece_path,ece_file,equil_prof_data,shotdata)
%
if nargin < 6,
    [shotinfo] = sscanf(eqdsk_file,'g%d.%d');
    shotnum = int2str(shotinfo(1));
    nshotime = shotinfo(2)/1000;
else
    shotnum = shotdata.shotnum;
    nshotime = shotdata.shotime;
end
%
shotime = num2str(nshotime,'%6.4f');
%
display_mode = 0;
p_opt = -1;
basestr = 'KSTAR';
%
equil_id =  [basestr,'_',shotnum,'_',shotime];
dispname = [basestr,' #',shotnum,'; t = ',shotime,' s'];
savename = equil_id;
%
% magnetic equil
%
[equil,prho,pspsin,pspsinT] = equil_magnetic_EFIT_jd([eqdsk_path,eqdsk_file],display_mode,p_opt,dispname,savename);
%
% profiles
%
if isfield(equil_prof_data,'ne0'),% ece_path and ece_file provide ECE data
    fid = fopen([ece_path,ece_file]);
    str = fgetl(fid);
    %
    istr = find(str == 't');
    istr = [istr,length(str) + 1];
    nt = length(istr) - 1;
    %
    t = NaN(1,nt);
    for it = 1:nt,
        t(it) = sscanf(str(istr(it):istr(it+1)-1),'t = %f s');
    end
    %
    fgetl(fid);
    %
    [data] = fscanf(fid,[' ECE%d %f',repmat(' %f',[1,nt])]);
    %
    nc = length(data)/(2+nt);
    %
    data = reshape(data,[2+nt,nc]);
    %
    %cnum = data(1,:).';
    cR = data(2,:).';
    cece = data(3:end,:).'/1e3;% keV
    %
    [tTe0,tTea,teTe1,teTe2] = Te_ece_jd(equil,cR,cece);
    %
    np = length(prho);
    %
    tpTe0 = repmat(tTe0.',[1,np]);
    tpTea = repmat(tTea.',[1,np]);
    tpeTe1 = repmat(teTe1.',[1,np]);
    tpeTe2 = repmat(teTe2.',[1,np]);
    %
    tprho = repmat(prho,[nt,1]);
    %
    tpTe = (tpTe0 - tpTea).*(1 - tprho.^tpeTe1).^tpeTe2 + tpTea;
    %
    pTe = interp1(t,tpTe,nshotime,'linear');
    %
    nz = length(equil_prof_data.Zi);
    pzTi = repmat(pTe/equil_prof_data.Tfac,[nz,1]);
    %
    ne0 = equil_prof_data.ne0;
    nea = equil_prof_data.nea;
    nei = equil_prof_data.nei;
    ene1 = equil_prof_data.ene1;
    ene2 = equil_prof_data.ene2;
    %
    if isnan(ne0) && ~isnan(nei),%ne0 obtained from line-averaged density
        %
        ne0 = nea + (nei - nea)*ene1/beta(1/ene1,1+ene2);
        %
    end
    %
    [dummy,dummy,pne,dummy,pzni,zZi,zmi,fi] = idealprof_yp(equil_prof_data.Zi,equil_prof_data.mi,equil_prof_data.fi,NaN,NaN,NaN,NaN,...
        ne0,nea,ene1,ene2,NaN,NaN,NaN,NaN,...
        equil_prof_data.Zeff0,equil_prof_data.Zeffa,equil_prof_data.eZeff,NaN,prho);
    %
else
    %
    % From Y-S Bae's file,
    % - remote first line
    % - save as cvs with spaces
    % - edit in matlab
    % - , -> .
    % - spaces -> ,
    %
    method = 'spline';
    %
    data = dlmread([ece_path,ece_file]);
    %
    prho_prof = data(:,2).';
    pTe_prof = data(:,3).';
    pTi_prof = data(:,4).';
    pne_prof = 1e19*data(:,5).';
    %
    pTe = interp1(prho_prof,pTe_prof,pspsinT,method);
    pTi = interp1(prho_prof,pTi_prof,pspsinT,method);
    pne = interp1(prho_prof,pne_prof,pspsinT,method);
    %
    zZi = equil_prof_data.Zi;
    zmi = equil_prof_data.mi;
    fi = equil_prof_data.fi;
    %
    pzTi = repmat(pTi,[length(zZi),1]);
    pzni = species_dke_yp(pne,equil_prof_data.Zeff,zZi,fi);
    %
end
%
equil.pTe = pTe;
equil.pne = pne;
equil.pzTi = pzTi;
equil.pzni = pzni;
equil.zZi = zZi;
equil.zmi = zmi;
equil.fi = fi;
%
equil.id = equil_id;
%
equil.basestr = basestr;
equil.shotnum = shotnum;
equil.shotime = shotime;




