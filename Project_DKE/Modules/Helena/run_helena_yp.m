function [equil,separatrix,profile] = run_helena_yp(sepparam,profparam,helparam,dkepath)
%
% Create input file and run HELENA magnetic equilibrium solver C3PO/LUKE
%
% INPUT:
%   
%   - sepparam: separatrix input structure
%   - profparam: profiles input structure
%
% OUTPUT:
%
%   - flag: execution flag (0: OK, not zeo: convergence problem) [1,1]
%
% by Y. PEYSSON, CEA-DRFC (yves.peysson@cea.fr) and J. DECKER (joan.decke@cea.fr) 
%
% HELENA control parameters that are fixed for LUKE magnetic equilibrium
% calculations. 
%
helparam.shape.ias = 1;%up-down asymmetric shape 
helparam.shape.ishape = 2;%shape given by fourier series
%helparam.shape.iarc = 0;%equidistant poloidal grid
helparam.output.npr1  = 0;%switch some of the printing off
helparam.output.npr2  = 0;%switch off 'real world' data output
helparam.plot.npl1 = 0;%switch plotting off
helparam.ballooning.nqb = 0;%switch ballooning calculation off
%
[separatrix] = make_helsep_yp(sepparam,helparam);%Calculate the geometrical shape of the separatrix and its Fourier transform for HELENA
[profile] = make_helprof_yp(profparam);%Calculate the pressure and current profiles for HELENA
%
initial_dir = pwd;
temppath = [dkepath.temppathroot,timeid_jd(clock),filesep,'HELENA/'];
mkdir(temppath);%Create calculation directory
cd(temppath);%Move to calculation directory	
%
%Create input file (fixed name fort.10)
%
fm = zeros(2,length(separatrix.fm));
gradxp = zeros(2,length(profile.gradxp));
current = zeros(2,length(profile.current));
if isfield(separatrix,'fm'),
    for ifm = 1:length(separatrix.fm),
        fm(:,ifm) = [ifm;separatrix.fm(ifm)];
    end
end
%
if isfield(profile,'gradxp'),
    for ipr = 1:length(profile.gradxp),
        gradxp(:,ipr) = [ipr;profile.gradxp(ipr)];
    end
end
%
if isfield(profile,'current'),
    for ijr = 1:length(profile.current),
        current(:,ijr) = [ijr;profile.current(ijr)];
    end
end
%
fid = fopen('fort.10','w');
fprintf(fid,'%s\n\n','Magnetic equilibrium for LUKE/C3PO');
%
fprintf(fid,'%s\n','&shape');
if isfield(helparam.shape,'ias');fprintf(fid,'ias = %d\n',helparam.shape.ias);end
if isfield(helparam.shape,'ishape');fprintf(fid,'ishape = %d\n',helparam.shape.ishape);end
if isfield(helparam.shape,'iarc');fprintf(fid,'iarc = %d\n',helparam.shape.iarc);end
if isfield(helparam.shape,'mfm');fprintf(fid,'mfm = %d\n',helparam.shape.mfm);end
if isfield(helparam.shape,'mharm');fprintf(fid,'mharm = %d\n',helparam.shape.mharm);end
if isfield(helparam.shape,'xr1');fprintf(fid,'xr1 = %f\n',helparam.shape.xr1);end
if isfield(helparam.shape,'sig1');fprintf(fid,'sig1 = %d\n',helparam.shape.sig1);end
if isfield(separatrix,'fm'),
    fprintf(fid,'fm(%i) = %11.5e\n',fm);
end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&profile');
if isfield(profile,'igam');fprintf(fid,'igam = %d\n',profile.igam);end
if isfield(profile,'ipai');fprintf(fid,'ipai = %d\n',profile.ipai);end
if isfield(profile,'icur');fprintf(fid,'icur = %d\n',profile.icur);end
if isfield(profile,'npts');fprintf(fid,'npts = %d\n',profile.npts);end
if isfield(profile,'gradxp'),
    fprintf(fid,'dpr(%i) = %11.5e\n',gradxp);
end
if isfield(profile,'current'),
    fprintf(fid,'zjz(%i) = %11.5e\n',current);
end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&phys');
if isfield(helparam.phys,'eps');fprintf(fid,'eps = %d\n',helparam.phys.eps);end
if isfield(helparam.phys,'B');fprintf(fid,'B = %d\n',helparam.phys.B);end
if isfield(helparam.phys,'betap');fprintf(fid,'betap = %d\n',helparam.phys.betap);end
if isfield(helparam.phys,'alfa');fprintf(fid,'alfa = %d\n',helparam.phys.alfa);end
if isfield(helparam.phys,'xiab');fprintf(fid,'xiab = %d\n',helparam.phys.xiab);end
if isfield(helparam.phys,'q95');fprintf(fid,'q95 = %d\n',helparam.phys.q95);end
if isfield(separatrix,'Rvac');fprintf(fid,'Rvac = %d\n',separatrix.Rvac);end
if isfield(helparam.phys,'Bvac');fprintf(fid,'Bvac = %d\n',helparam.phys.Bvac);end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&num');
if isfield(helparam.num,'nr');fprintf(fid,'nr = %d\n',helparam.num.nr);end
if isfield(helparam.num,'np');fprintf(fid,'np = %d\n',helparam.num.np);end
if isfield(helparam.num,'nrmap');fprintf(fid,'nrmap = %d\n',helparam.num.nrmap);end
if isfield(helparam.num,'npmap');fprintf(fid,'npmap = %d\n',helparam.num.npmap);end
if isfield(helparam.num,'nchi');fprintf(fid,'nchi = %d\n',helparam.num.nchi);end
if isfield(helparam.num,'nrcur');fprintf(fid,'nrcur = %d\n',helparam.num.nrcur);end
if isfield(helparam.num,'npcur');fprintf(fid,'npcur = %d\n',helparam.num.npcur);end
if isfield(helparam.num,'errcur');fprintf(fid,'errcur = %d\n',helparam.num.errcur);end
if isfield(helparam.num,'nmesh');fprintf(fid,'nmesh = %d\n',helparam.num.nmesh);end
if isfield(helparam.num,'niter');fprintf(fid,'niter = %d\n',helparam.num.niter);end
if isfield(helparam.num,'amix');fprintf(fid,'amix = %d\n',helparam.num.amix);end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&pri');
if isfield(helparam.output,'npr1');fprintf(fid,'npr1 = %d\n',helparam.output.npr1);end
if isfield(helparam.output,'npr2');fprintf(fid,'npr2 = %d\n',helparam.output.npr2);end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&plot');
if isfield(helparam.plot,'npl1');fprintf(fid,'npl1 = %d\n',helparam.plot.npl1);end
fprintf(fid,'%s\n\n','&end');
%
fprintf(fid,'%s\n','&ball');
if isfield(helparam.ballooning,'nqb');fprintf(fid,'nqb = %d\n',helparam.ballooning.nqb);end
fprintf(fid,'%s\n\n','&end');
%
fclose(fid);
%
%Run HELENA
%
eval(['!',dkepath.luke_root,'Project_DKE/Modules/Helena/Application/helena_luke.app'])
%
equil = '';
if exist('luke'),
    [equil_mag] = equil_helmag_yp('luke');
    [equil_prof] = equil_helprof_yp(profparam,equil_mag);
    equil = conc_struct_jd(equil_mag,equil_prof);
end
%
cd(initial_dir);



