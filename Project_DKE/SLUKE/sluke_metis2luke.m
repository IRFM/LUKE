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
function [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = sluke_metis2luke(sparams,ii,post,tprofok)
%
% LUKE - Extraction of of the toroidal MHD equilibrium from METIS calculations for sluke. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin{1} : initial 'sparams' structure
%   - varargin{2} : simulation index in the sparams structure
%   - varargin{3} : METIS post structure
%   - varargin{4} : METIS flag on the use of tprof data (Tore Supra only)
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
sparams_tmp = sluke_params_extract(sparams,ii);
sparams_tmp.equil.equilconsistency.fit = {sparams_tmp.equil.fit};
sparams_tmp.equil.equilconsistency.run = {1};
%
[dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = auto_extract_metisdata_for_luke(post,sparams.discharge.tmin{ii},1,1,sparams_tmp.equil.equilconsistency);
%
movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
%
if isfield(sparams.equil,'equilconsistency')
    %
    equil1 = rmfield(sparams.equil,'equilconsistency');
    equilconsistency = sluke_params_value(sparams.equil.equilconsistency,ii);
    %
else
    %
    equil1 = sparams.equil;
    equilconsistency = '';
    %
end
%
if isfield(equil1,'fit') || isfield(equil1,'ripple')
    %
    if isfield(equil1,'fit')
        equil2 = rmfield(equil1,'fit');
        fit = sluke_params_value(sparams.equil.fit,ii);
    else
        equil2 = equil1;
        fit = '';
    end
    %
    if isfield(equil2,'ripple')
        equil2 = rmfield(equil2,'ripple');
        ripple = sluke_params_value(sparams.equil.ripple,ii);
    end
    %
else
    equil2 = equil1;
    fit = '';
end
%
fns = fieldnames(equil2);
%
for jj = 1:length(fns)
    %
    if ~isstruct(eval(['equil2.',fns{jj}]))
        %
        eval(['source.',fns{jj},' = equil2.',fns{jj},'{',int2str(ii),'};']);
        %
    else 
        %
        fnames = fieldnames(eval(['equil2.',fns{jj}]));
        for kk = 1:length(fnames)
            %
            eval(['source.',fns{jj},'.',fnames{kk},' = equil2.',fns{jj},'.',fnames{kk},'{',int2str(ii),'};']);
            %
        end
        %
    end
    %
end
%
equil.source = source;
%
if nargin == 4
    %
    equil.source.tprofok = tprofok;
    %
end
%
if isfield(sparams.equil,'equilconsistency')
    %
    equilconsistency_id = sluke_id(sparams,ii);
    equil.source.equilconsistency = ['SLUKE_EQUILS/EQUILCONSISTENCY_',equilconsistency_id,'.mat'];
    save(['SLUKE_EQUILS/EQUILCONSISTENCY_',equilconsistency_id,'.mat'],'equilconsistency');
    %
end
%
if isfield(sparams.equil,'fit')
    % 
    fit_id = sluke_id(sparams,ii);
    equil.source.fit = ['SLUKE_FITEQUILS/FITEQUIL_',fit_id,'.mat'];
    save(['SLUKE_EQUILS/FITEQUIL_',fit_id,'.mat'],'fit');
    %
end
%

                