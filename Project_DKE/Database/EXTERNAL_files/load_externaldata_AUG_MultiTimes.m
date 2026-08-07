% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function external = load_externaldata_AUG_MultiTimes(workdir,opt_gui,style,~)
    %
    % This function loads AUG data for multiple times from S. Denk
    % LUKE_data_shot_<shotnum>.mat files
    %
    external = struct;
    %
    [filename,pathname] = igetfile_jd(isobject(opt_gui) || opt_gui,{'LUKE_data_shot_*.mat'},'Please select AUG data file',workdir);
    %
    if ~ischar(filename)
        return
    end
    %
    external.basestr = 'AUG';
    %
    if length(filename) > 19 && strcmp(filename(1:15),'LUKE_data_shot_') && strcmp(filename(end-3:end),'.mat')
        shotnum = filename(16:end-4);
    else
        shotnum = '0';
    end
    %
    external.shotnum = iselect_jd({},'Enter shot number : ',opt_gui,style.editselectstyle,shotnum,'edit');
    %
    shotdata = make_double(load([pathname,filesep,filename]));
    %
    tshot = shotdata.t;
    ntshot = length(tshot);
    %
    timestr = ['tmin = ',sprintf('%3.3f',min(tshot)),'s ; tmax = ',sprintf('%3.3f',max(tshot)),'s ; dt = ',sprintf('%3.3f',mean(diff(tshot))),'s ; nt = ',num2str(ntshot)];
    %
    itshot = iselect_jd({},[timestr,' :\n -> select time indices (enter 0 to select all times)'],opt_gui,style.editselectstyle,0,'edit');
    %
    if isempty(itshot)
        itshot = 1:ntshot;
    end
    %
    external.shotime = tshot(itshot);
    %
    for it = 1:length(itshot)
        %
        external.equil(it).shotnum = external.shotnum;
        external.equil(it).shotime = external.shotime(it);
        %
        external.equil(it).prof.ne.rho = shotdata.rhop_prof(itshot(it),:).';
        external.equil(it).prof.ne.data = shotdata.ne_prof(itshot(it),:).';
        %
        external.equil(it).prof.te.rho = shotdata.rhop_prof(itshot(it),:).';
        external.equil(it).prof.te.data = shotdata.Te_prof(itshot(it),:).';
        %
        external.equil(it).prof.ti = 1;%Ti/Te
        external.equil(it).prof.zeff = 1.5;%default value
        %
        external.equil(it).prof.Ip = -shotdata.I_p(itshot(it));
        %
        external.equil(it).magnetic.R = shotdata.R(itshot(it),:);
        external.equil(it).magnetic.Z = shotdata.z(itshot(it),:);
        %
        nR = size(shotdata.R,2);
        nZ = size(shotdata.z,2);
        %
        external.equil(it).magnetic.BR = reshape(shotdata.Br(itshot(it),:,:),[nR,nZ]);
        external.equil(it).magnetic.BZ = reshape(shotdata.Bz(itshot(it),:,:),[nR,nZ]);
        external.equil(it).magnetic.Bphi = -reshape(shotdata.Bt(itshot(it),:,:),[nR,nZ]);% different sign convention
        external.equil(it).magnetic.psi = reshape(shotdata.Psi(itshot(it),:,:),[nR,nZ])/(2*pi);
        external.equil(it).magnetic.rhop = reshape(shotdata.rhop(itshot(it),:,:),[nR,nZ]);
        %
        external.equil(it).magnetic.Rp = shotdata.R_ax(itshot(it));
        external.equil(it).magnetic.Zp = shotdata.z_ax(itshot(it));
        external.equil(it).magnetic.psi0 = shotdata.Psi_ax(itshot(it))/(2*pi);
        external.equil(it).magnetic.psia = shotdata.Psi_sep(itshot(it))/(2*pi);
        %
        external.ohm(it).vloop = shotdata.Vloop(itshot(it));
        %
        external.wave(1,it).mmode = - shotdata.mode_gy1(itshot(it));
        external.wave(2,it).mmode = - shotdata.mode_gy2(itshot(it));
        %
        external.wave(1,it).f_GHz = shotdata.freq_gy1(itshot(it))/1e9;
        external.wave(2,it).f_GHz = shotdata.freq_gy2(itshot(it))/1e9;
        %
        external.wave(1,it).P_MW = shotdata.PW_gy1(itshot(it))/1e6;
        external.wave(2,it).P_MW = shotdata.PW_gy2(itshot(it))/1e6;
        %
        external.wave(1,it).alpha_L = pi + pi/180*shotdata.tor_angle_gy1(itshot(it));
        external.wave(2,it).alpha_L = pi + pi/180*shotdata.tor_angle_gy2(itshot(it));
        %
        external.wave(1,it).beta_L = pi/2 + pi/180*shotdata.pol_angle_gy1(itshot(it));
        external.wave(2,it).beta_L = pi/2 + pi/180*shotdata.pol_angle_gy2(itshot(it));
        %
        x1_L = shotdata.x_gy1(itshot(it));
        x2_L = shotdata.x_gy2(itshot(it));
        y1_L = shotdata.y_gy1(itshot(it));
        y2_L = shotdata.y_gy2(itshot(it));
        %
        external.wave(1,it).R_L = sqrt(x1_L^2 + y1_L^2);
        external.wave(2,it).R_L = sqrt(x2_L^2 + y2_L^2);
        %
        external.wave(1,it).Z_L = shotdata.z_gy1(itshot(it));
        external.wave(2,it).Z_L = shotdata.z_gy2(itshot(it));
        %
        if shotdata.curv_y_gy1(itshot(it)) ~= shotdata.curv_z_gy1(itshot(it))
            disp('Warning : EC beam 1 is astygmatic. Average curvature radius selected.')
        end
        %
        if shotdata.curv_y_gy2(itshot(it)) ~= shotdata.curv_z_gy2(itshot(it))
            disp('Warning : EC beam 2 is astygmatic. Average curvature radius selected.')
        end
        %
        external.wave(1,it).z0 = (shotdata.curv_y_gy1(itshot(it)) + shotdata.curv_z_gy1(itshot(it)))/2;
        external.wave(2,it).z0 = (shotdata.curv_y_gy2(itshot(it)) + shotdata.curv_z_gy2(itshot(it)))/2;
        %
        if shotdata.width_y_gy1(itshot(it)) ~= shotdata.width_z_gy1(itshot(it))
            disp('Warning : EC beam 1 is elliptical. Average beam radius selected.')
        end
        %
        if shotdata.width_y_gy2(itshot(it)) ~= shotdata.width_z_gy2(itshot(it))
            disp('Warning : EC beam 2 is elliptical. Average beam radius selected.')
        end
        %
        external.wave(1,it).w0 = (shotdata.width_y_gy1(itshot(it)) + shotdata.width_z_gy1(itshot(it)))/2;
        external.wave(2,it).w0 = (shotdata.width_y_gy2(itshot(it)) + shotdata.width_z_gy2(itshot(it)))/2;
    end    

    %
    external.id = [external.basestr,'_',external.shotnum]; 
    %
    if isnan_jd(external,0)
        disp('Warning : NaNs were found in the structure ''external'' : ')
        isnan_jd(external,1),
    end
    %
end
%
function s = make_double(s)
    %
    fnames = fieldnames(s);
    for ifield = 1:length(fnames)
        if isnumeric(s.(fnames{ifield}))
            s.(fnames{ifield}) = double(s.(fnames{ifield}));
        end
    end
end
