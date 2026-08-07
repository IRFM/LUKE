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
function external = load_externaldata_AUG(external_in,opt_gui)%(workdir,shotnum,shotime,t1,t2,opt_gui,dummy)
%
% This function loads data from AUG Torbeam output file
%
% INPUTS : 
%   - if nargin == 0, return default external_in to be modified interactively in iload_externaldata_jd

%   - external_in : input structure.
%   - opt_gui     : option for GUI within function (interactive mode only)
%       
%
if nargin == 0,
    %
    % default values
    %
    [pathname] = igetdir_jd(1,'Please select the directory containing torbeam data',pwd);
    %
	external.shotnum = 0;
	external.shotime = 0;
    %
    if pathname ~= 0,
        %
        external.workdir = pathname;
        %
        flag = 0;
        ifilesep = strfind(pathname,filesep);
        if length(ifilesep) <= 1 || ifilesep(end) ~= length(pathname),
            flag = 1;
        else
            pathname = pathname(ifilesep(end-1)+1:ifilesep(end)-1);
            idatasep = strfind(pathname,'_');
            if length(idatasep) <= 1 || idatasep(1) == 1 || idatasep(2) - idatasep(1) == 1,
                flag = 1;
            else
                external.shotnum = str2double(pathname(1:idatasep(1)-1));
                external.shotime = str2double(pathname(idatasep(1)+1:idatasep(2)-1));
            end
        end
        if flag == 1,
            %
            filename = [external.workdir,'topfile'];
            %
            if exist(filename,'file'),
                fid = fopen(filename);
                data = textscan(fid,'Number of radial and vertical grid points in AUGD:EQH:%d:%f:%f %f %f',1);
                if ~isempty(data{1}),
                    external.shotnum = data{1};
                end
                if ~isempty(data{5}),
                    external.shotime = data{5};
                end
            end
        end
        %
    else
        %
        external.workdir = pwd;
        %
    end  
    %
    %
    % description & user halp
    %
    external.info.workdir = 'directory for source files';
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    % 
    % expert mode
    %
    external.expert.workdir = 0;
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    %
    % range of values
    %
    external.values.workdir = '';
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    %
    return
    %
end
%
if nargin < 2,
    opt_gui = false;
end
%
workdir = external_in.workdir;
shotnum = external_in.shotnum;
shotime = external_in.shotime;
%
% ******************************************************************
%
external = '';
basestr = 'AUG';
%
external.basestr = basestr;
external.shotnum = num2str(shotnum);
external.shotime = shotime;
%
filename = [workdir,'ne.dat'];
%
if exist(filename,'file'),
    fid = fopen(filename);
    data = textscan(fid,'%d',1);
    nr = data{1};
    data = textscan(fid,'%f %f',nr);
    external.equil.prof.ne.rho = data{1};
    external.equil.prof.ne.data = data{2}*1e19;
    disp('ne data loaded from file')
else
    disp('warning : no ne data')
end
%
filename = [workdir,'Te.dat'];
%
if exist(filename,'file'),
    fid = fopen(filename);
    data = textscan(fid,'%d',1);
    nr = data{1};
    data = textscan(fid,'%f %f',nr);
    external.equil.prof.te.rho = data{1};
    external.equil.prof.te.data = data{2}*1e3;
    disp('te data loaded from file')
else
    disp('warning : no te data')
end
%
external.equil.prof.ti = 1;%Ti/Te
external.equil.prof.zeff = 1.5;%default value
%
filename = [workdir,'topfile'];
%
if exist(filename,'file'),
    fid = fopen(filename);
    fgetl(fid);
    data = textscan(fid,'%d %d',1);
    nR = data{1};
    nZ = data{2}; 
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    fgetl(fid);
    fgetl(fid);
    data = textscan(fid,'%f',nR);
    R = data{1};
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    data = textscan(fid,'%f',nZ);
    Z = data{1};
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    data = textscan(fid,'%f',nR*nZ);
    BR = reshape(data{1},nR,nZ);
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    data = textscan(fid,'%f',nR*nZ);
    Bphi = reshape(data{1},nR,nZ);
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    data = textscan(fid,'%f',nR*nZ);
    BZ = reshape(data{1},nR,nZ);
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    data = textscan(fid,'%f',nR*nZ);
    psi = reshape(data{1},nR,nZ)/2/pi;
    %
    external.equil.shotnum = external.shotnum;
    external.equil.shotime = external.shotime;
    %
    external.equil.magnetic.R = R;
    external.equil.magnetic.Z = Z;
    external.equil.magnetic.BR = BR;
    external.equil.magnetic.BZ = BZ;
    external.equil.magnetic.Bphi = Bphi;
    external.equil.magnetic.psi = psi;
    disp('magnetic equil data loaded from file')
else
    disp('warning : no magnetic equil data')
end
%
% waves
% 
filenames = dir([workdir,'inbeam*.dat']);
%
for ifile = 1:length(filenames),
    fid = fopen([workdir,filenames(ifile).name]);
    searchstr = 'Beam';
    a = '';
    while ~any(strfind(a,searchstr)),
        a = fgetl(fid);
    end
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).mmode = - data{2};
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).f_GHz = data{2}/1e9;
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).alpha_L = pi + data{2}*pi/180;
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).beta_L = pi/2 + data{2}*pi/180;
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).R_L = data{2}/1e2;
    %
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).Z_L = data{2}/1e2;
    %
    a = fgetl(fid);
    if isempty(a),
        fgetl(fid);
    end    
    a = fgetl(fid);
    a = fgetl(fid);
    a = fgetl(fid);
    %
    data = textscan(fid,'%s = %f,',1);
    external.wave.(['EC_',num2str(ifile)]).P_MW = data{2};
    %
    disp('ECRH data loaded from file')
end
if isempty(filenames),
    disp('warning : no ECRH data')
end
%
external.id = [basestr,'_',shotnum,'_',shotime]; 
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end
%
