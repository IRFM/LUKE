%Script that runs all C3PO examples in one pass (only cases recognized by CVS)
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA-IRFM, joan.decker@cea.fr)
%
allforcerun = 1;%force run of all cases
%
init_dir = pwd;
%
dirlist = dir;
for id = 1:length(dirlist),
    %
    if ~strcmp(dirlist(id).name,'.') && ~strcmp(dirlist(id).name,'..') && ~strcmp(dirlist(id).name,'.DS_store') && ~strcmp(dirlist(id).name,'CVS') && dirlist(id).isdir && exist([dirlist(id).name,filesep,'EQUIL']),
        %
        dirlist_equil = dir([dirlist(id).name,filesep,'EQUIL']);
        %
        for id_equil = 1:length(dirlist_equil),
            if ~strcmp(dirlist_equil(id_equil).name,'.') && ~strcmp(dirlist_equil(id_equil).name,'..') && ~strcmp(dirlist_equil(id_equil).name,'.DS_store') && ~strcmp(dirlist_equil(id_equil).name,'CVS') && ~isempty(strfind(dirlist_equil(id_equil).name,'make_equil_')) && ~strcmp(dirlist_equil(id_equil).name(1),'.'),
                equilname = dirlist_equil(id_equil).name(12:end-2);
                if ~exist([dirlist(id).name,filesep,'EQUIL',filesep,'EQUIL_',equilname,'.mat'],'file') || allforcerun,
                    cd([dirlist(id).name,filesep,'EQUIL']),
                    eval(dirlist_equil(id_equil).name(1:end-2));
                    cd(init_dir)
                    if allforcerun
                        disp([' - ',dirlist(id).name,filesep,'EQUIL',filesep,'EQUIL_',equilname,'.mat is build (overwritten)']);
                    else
                        disp([' - ',dirlist(id).name,filesep,'EQUIL',filesep,'EQUIL_',equilname,'.mat is build']);
                    end
                else
                    disp([' - ',dirlist(id).name,filesep,'EQUIL',filesep,'EQUIL_',equilname,'.mat is already build']);
                end
            end
        end
        %
        dirlist_fluct = dir([dirlist(id).name,filesep,'FLUCT']);
        %
        for id_fluct = 1:length(dirlist_fluct),
            if ~strcmp(dirlist_fluct(id_fluct).name,'.') && ~strcmp(dirlist_fluct(id_fluct).name,'..') && ~strcmp(dirlist_fluct(id_fluct).name,'.DS_store') && ~strcmp(dirlist_fluct(id_fluct).name,'CVS') && ~isempty(strfind(dirlist_fluct(id_fluct).name,'make_fluct_')) && ~strcmp(dirlist_fluct(id_fluct).name(1),'.'),
                fluctname = dirlist_fluct(id_fluct).name(12:end-2);
                if ~exist([dirlist(id).name,filesep,'FLUCT',filesep,'FLUCT_',fluctname,'.mat'],'file') || allforcerun,
                    cd([dirlist(id).name,filesep,'FLUCT']),
                    eval(dirlist_fluct(id_fluct).name(1:end-2));
                    cd(init_dir)
                    if allforcerun
                        disp([' - ',dirlist(id).name,filesep,'FLUCT',filesep,'FLUCT_',fluctname,'.mat is build (overwritten)']);
                    else
                        disp([' - ',dirlist(id).name,filesep,'FLUCT',filesep,'FLUCT_',fluctname,'.mat is build']);
                    end
                else
                    disp([' - ',dirlist(id).name,filesep,'FLUCT',filesep,'FLUCT_',fluctname,'.mat is already build']);
                end
            end
        end
        %
        dirlist_wave = dir([dirlist(id).name,filesep,'WAVE']);
        %
        for id_wave = 1:length(dirlist_wave),
            if ~strcmp(dirlist_wave(id_wave).name,'.') && ~strcmp(dirlist_wave(id_wave).name,'..') && ~strcmp(dirlist_wave(id_wave).name,'.DS_store') && ~strcmp(dirlist_wave(id_wave).name,'CVS') && ~isempty(strfind(dirlist_wave(id_wave).name,'make_wave_')) && ~strcmp(dirlist_wave(id_wave).name(1),'.'),
                wavename = dirlist_wave(id_wave).name(11:end-2);
                if ~exist([dirlist(id).name,filesep,'WAVE',filesep,'WAVE_',wavename,'.mat'],'file') || allforcerun,
                    cd([dirlist(id).name,filesep,'WAVE']),
                    eval(dirlist_wave(id_wave).name(1:end-2));
                    cd(init_dir)
                    if allforcerun
                        disp([' - ',dirlist(id).name,filesep,'WAVE',filesep,'WAVE_',wavename,'.mat is build (overwritten)']);
                    else
                        disp([' - ',dirlist(id).name,filesep,'WAVE',filesep,'WAVE_',wavename,'.mat is build']);
                    end
                else
                    disp([' - ',dirlist(id).name,filesep,'WAVE',filesep,'WAVE_',wavename,'.mat is already build']);
                end
            end
        end
        %
    end
end
