function [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = sluke_autoTSmetis(sparams,ii)
%
% LUKE - Automatic calculations of the toroidal MHD equilibrium for sluke by autoTSmetis (for Tore Supra tokamak only). All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin{1} : initial 'sparams' structure
%   - varargin{2} : simulation index in the sparams structure
%
% OUTPUT :
%
%   - dkeparam : structure of the parameters for kinetic calculations
%   - dkedisplay : structure of the display options for kinetic calculations
%   - equil : toroidal MHD equilibrium structure for sluke
%   - ohm : ohnmic field structure for sluke
%   - transpfaste : anomalous fast electron transport structure for sluke
%   - ripple : toroidal magnetic ripple calculations structure for sluke
%   - wavestructs : rf waves structure for sluke
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
dkeparam = '';
dkedisplay = '';
equil = '';
ohm = '';
transpfaste = '';
ripple = '';
wavestructs = '';
%
if strcmp(sparams.machine{ii},'TS')
    %
    equil_id = sluke_id(sparams,ii);
    %
    if isfield(sparams.discharge,'gas')
        %
        if sparams.discharge.gas{ii} == 'D'
            %
            gas = 1;
            %
        elseif sparams.discharge.gas{ii} == 'He'
            %
            gas = 2;
            %
        else
            %
            error('Main gas discharge unrecognized. It should be D (Deuterium) or He (Helium).');
            %
        end
    else
        cprintf([1,0.5,0],['WARNING : Main gas discharge is not defined in structure sparams.discharge. It is enforced to D (Deuterium).']);disp(' ')
        gas = 1;
    end
    %
    if isfield(sparams,'equil') && isfield(sparams.equil,'autoTSmetis') && isfield(sparams.equil.autoTSmetis,'tprofonoff') 
        %
        tprofonoff = sparams.equil.autoTSmetis.tprofonoff{ii};
        %
    else
        %
        cprintf([1,0.5,0],['WARNING : TPROF option is not defined in structure sparams.equil.code.autoTSmetis. It is enforced to TPROF profiles.']);disp(' ')
        tprofonoff = 1;
        %
    end
    %
    if isfield(sparams,'equil') && isfield(sparams.equil,'autoTSmetis') && isfield(sparams.equil.autoTSmetis,'slice_times') 
        %
        slice_times = sparams.equil.autoTSmetis.slice_times{ii};
        %
    else
        %
        cprintf([1,0.5,0],['WARNING : slice_times option is not defined in structure sparams.equil.code.autoTSmetis. Default METIS number of time slices is enforced.']);disp(' ')
        slice_times = [];
        %
    end
    %
    data = remote_autoTSmetis(str2num(sparams.discharge.shot{ii}),gas,slice_times,'',tprofonoff);
    %
    if ~isempty(data) 
        %
        if isfield(data,'err')
            %
            disp(['WARNING : autoTSmetis calculations failed for discharge #',sparams.discharge.shot{ii},'. Error message saved in equil file.']);
            %
            equil.err = data.err;
            %
        elseif isfield(data,'post') && isfield(data,'tprofok')
            %
            post = data.post;
            tprofok = data.tprofok;
            %
            disp(['--> autoTSmetis calculations successfully done for discharge #',sparams.discharge.shot{ii},'.']);
            %
            [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = sluke_metis2luke(sparams,ii,post,tprofok);
            %
            if isfield(sparams,'equil') && isfield(sparams.equil,'autoTSmetis') && isfield(sparams.equil.autoTSmetis,'save') && sparams.equil.autoTSmetis.save{ii} == 1
                %
                post.tprofok = tprofok;
                %
                if isfield(sparams,'equil') && isfield(sparams.equil,'autoTSmetis') && isfield(sparams.equil.autoTSmetis,'path')
                    %
                    if ~exist(sparams.equil.autoTSmetis.path{ii})
                        %
                        mkdir(sparams.equil.autoTSmetis.path{ii});
                        %
                    end
                    %
                    if isfield(sparams.equil.autoTSmetis,'id')
                        %
                        filename = [sparams.equil.autoTSmetis.path{ii},'/autoTSmetis_',sparams.discharge.shot{ii},'_',sparams.equil.autoTSmetis.id{ii}];
                        %
                    else
                        %
                        filename = [sparams.equil.autoTSmetis.path{ii},'/autoTSmetis_',sparams.discharge.shot{ii}];
                        %
                    end
                    %
                else
                    %
                    if isfield(sparams,'equil') && isfield(sparams.equil,'path')
                        %
                        if ~exist(sparams.equil.path{ii})
                            %
                            mkdir(sparams.equil.path{ii});
                            %
                        end
                        %
                        if isfield(sparams.equil.autoTSmetis,'id')
                            %
                            
                            filename = [sparams.equil.path{ii},'/autoTSmetis_',sparams.discharge.shot{ii},'_',sparams.equil.autoTSmetis.id{ii}];
                            %
                        else
                            %
                            filename = [sparams.equil.path{ii},'/autoTSmetis_',sparams.discharge.shot{ii}];
                            %
                        end
                        %
                    else
                        %
                        if isfield(sparams.equil.autoTSmetis,'id')
                            %
                            filename = ['./autoTSmetis_',sparams.discharge.shot{ii},'_',sparams.equil.autoTSmetis.id{ii}];
                            %
                        else
                            %
                            filename = ['./autoTSmetis_',sparams.discharge.shot{ii}];
                            %
                        end
                    end
                    %
                end
                %
                
                %
                save(filename,'post');
                disp(['--> autoTSmetis calculations successfully saved for discharge #',sparams.discharge.shot{ii},' in ',filename,'.mat']);
                %
            end
            %
        else
            %
            disp(['WARNING : autoTSmetis calculations failed for discharge #',sparams.discharge.shot{ii},'. No data.']);
            %
        end
        %
    end
    %
else
    %
    disp(['WARNING : the code ',sparams.equil.code{ii},' is for Tore SUPRA (TS) tokamak only.'])
    %
end
