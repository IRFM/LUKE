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
function diags = sluke_diagnostics(sparams,ii,lukestructs,equil)
%
diags = [];
%
if nargin < 3
    %
    lukestructs = '';
    equil = '';
    %
end
%
if nargin < 4
    %
    equil = '';
    %
end
%
if ~isfield(sparams,'diags')
    %
    cprintf([1,0.5,0],'No diagnostic is defined in sparams');disp(' ');
    return
    %
end
%
simul_id = sluke_id(sparams,ii);
%
% Synthetic diagnostic : fast electron bremsstrahlung in the hard x-ray photon energy range DSPX
%
if ~exist(['SLUKE_DIAGNOSTICS/DSPX_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'DSPX')
        %
        if ~isfield(sparams.diags.DSPX,'enable') || (isfield(sparams.diags.DSPX,'enable') && sparams.diags.DSPX.enable{ii} == 1)
            %
            DSPX = sluke_dspx(sparams,lukestructs,ii,equil);
            %
            if ~isempty(DSPX)
                %
                if ~isempty(lukestructs)
                    %
                    save(['SLUKE_DIAGNOSTICS/DSPX_RESULTS_',simul_id,'.mat'],'DSPX');
                    %
                    cprintf('*green',['---> DSPX synthetic diagnostic calculations has been completed : results are saved.']);disp(' ')
                    %
                end
                %
                diags.DSPX = DSPX;
                %
            else
                %
                cprintf('red','WARNING : DSPX calculations from LUKE results failed.');disp(' ');
                %
            end
        else
            %
            cprintf([1,0.5,0],'DSPX calculations are not enabled in sparams');disp(' ');
            diags.DSPX = [];
            %
        end
        %
    end
    %
else
    %
    cprintf('green','DSPX calculations are already done');disp(' ');
    diags.DSPX = [];
    %
end
%
if isfield(diags,'DSPX') && isempty(diags.DSPX)
    %
    diags = rmfield(diags,'DSPX');%remove DSPX diag is not enabled or empty structure
    %
end
%
% Synthetic diagnostic : fast electron bremsstrahlung in the hard x-ray photon energy range MEHXR
%
if ~exist(['SLUKE_DIAGNOSTICS/MEHXR_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'MEHXR')
        %
        if ~isfield(sparams.diags.MEHXR,'enable') || (isfield(sparams.diags.MEHXR,'enable') && sparams.diags.MEHXR.enable{ii} == 1)
            %
            MEHXR = sluke_mehxr(sparams,lukestructs,ii,equil);
            %
            if ~isempty(MEHXR)
                %
                if ~isempty(lukestructs)
                    %
                    save(['SLUKE_DIAGNOSTICS/MEHXR_RESULTS_',simul_id,'.mat'],'MEHXR');
                    %
                    cprintf('*green',['---> MEHXR synthetic diagnostic calculations has been completed : results are saved.']);disp(' ')
                    %
                end
                %
                diags.MEHXR = MEHXR;
                %
            else
                %
                cprintf('red','WARNING : MEHXR calculations from LUKE results failed.');disp(' ');
                %
            end
            %
        else
            %
            cprintf([1,0.5,0],'MEHXR calculations are not enabled in sparams');disp(' ');
            diags.MEHXR = [];
            %
        end
        %
    end
    %
else
    %
    cprintf('green','MEHXR calculations are already done');disp(' ');
    diags.MEHXR = [];
    %
end
%
if isfield(diags,'MEHXR') && isempty(diags.MEHXR)
    %
    diags = rmfield(diags,'MEHXR');%remove MEHXR diag is not enabled or empty structure
    %
end
