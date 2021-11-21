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
    data = remote_autoTSmetis(str2num(sparams.discharge.shot{ii}),sparams.discharge.gas{ii});
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
