function diags = sluke_diagnostics(sparams,ii,lukestructs,equil)
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
    diags = [];
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

