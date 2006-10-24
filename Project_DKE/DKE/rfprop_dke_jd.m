function [xyP0_2piRp_out,xyP0_2piRp_mod] = rfprop_dke_jd(yb,xyprop_dke,xyP0_2piRp_in,xyPabs_dke,xdV_2piRp_dke,xpsin,xpsin_dke,r_dke,dke_mode);
%
% This function ensures consistency between the power travelling with RF
% rays and the power absorbed by the plasma. Iterations between
% rfprop_dke_jd and dke_yp are required to reach consistency.
%
%   INPUTS:
%
%       - yb: list of ray starts
%       - xyprop_dke: propagation factors at DKE FS
%       - xyP0_2piRp_in: input incident power at each FP position
%       - xyPabs: absorbed power density in the DKE FS
%       - xydV_dke: incremental volume in the DKE FS
%
%   OUTPUTS:
%
%       - xyP0_2piRp_out: calculated current step incident power at each FP position
%       - xyP0_2piRp_mod: estimated next step incident power at each FP position
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
[nr_dke,ny] = size(xyprop_dke);
%
xyP0_2piRp_out = xyP0_2piRp_in;%default values
xyP0_2piRp_mod = xyP0_2piRp_in;%default values
%
xydV_2piRp_dke = xdV_2piRp_dke'*ones(1,ny);
xyPrf_dke = xyPabs_dke.*xydV_2piRp_dke;%power absorbed from each ray within each FS
xyPrf_dke(xyPrf_dke < 0) = 0;
%
xymask_prop_dke = xyprop_dke ~= 0;%DKE points visited by the ray
%
for iy = 1:ny 
    if max(xyprop_dke(:,iy)) == 1 %ray portion is propagating outward
        ir_dke = min(find(xyprop_dke(:,iy) == 1)); %position of ray start
    %    
    elseif min(xyprop_dke(:,iy)) == -1 %ray portion is propagating inward
        ir_dke = max(find(xyprop_dke(:,iy) == -1)); %position of ray start
        %    
    else %no RT-DKE consistency seeked for current ray
        continue
    end
    ir = r_dke(ir_dke);
    %   
    % check if new ray or only new portion
    %
    if ~isempty(find(iy == yb)); %new ray
        bPrf = xyP0_2piRp_in(ir,iy); %initial power in the ray
        bPrf_mod = bPrf; %initial power in the ray
    end
    %    
    while ir_dke <= nr_dke & ir_dke >= 1 & xyprop_dke(ir_dke,iy) ~= 0 % stay on current ray 
        ir = r_dke(ir_dke);
        %
        Pabs = xyPrf_dke(ir_dke,iy);% absorbed power in this step
        %
        if Pabs <= bPrf % absorbed power cannot be more than incident power
            %
            xyP0_2piRp_out(ir,iy) = bPrf - Pabs/2; %incident power consistent with absorbed power
            %
        else
            %
            xyP0_2piRp_out(ir,iy) = xyP0_2piRp_in(ir,iy)*bPrf/Pabs; %linear anticipation
            %
            Pabs = bPrf;
            %
        end
        %
        bPrf = bPrf - Pabs;%remaining power for next step
        %
        % estimated absorbed power in this step
        % anticipating the effect of variations in incident power compared
        % to previous QL iteration. This estimate 
        % assumes linear power absorbed vs incident power dependence.
        %
        if xyP0_2piRp_in(ir,iy) > 0
            Pabs_mod = xyPrf_dke(ir_dke,iy)*bPrf_mod/(xyP0_2piRp_in(ir,iy) + xyPrf_dke(ir_dke,iy)/2);% absorbed power in this step
        else
            Pabs_mod = xyPrf_dke(ir_dke,iy);% absorbed power in this step
        end
        %
        if Pabs_mod <= bPrf_mod % absorbed power cannot be more than incident power
            %
            xyP0_2piRp_mod(ir,iy) = bPrf_mod - Pabs_mod/2; %incident power consistent with absorbed power
            %
        else
            %
            xyP0_2piRp_mod(ir,iy) = xyP0_2piRp_in(ir,iy)*bPrf_mod/xyPrf_dke(ir_dke,iy); %linear anticipation
            %
            Pabs_mod = bPrf_mod;
            %
        end
        %
        bPrf_mod = bPrf_mod - Pabs_mod;
        % 
        % next FS
        %
        ir_dke = ir_dke + xyprop_dke(ir_dke,iy);
    end
    %
    % interpolation for the FP positions (only necessary if dke_mode == 1)
    %
    if dke_mode == 1  
        xmask_prop_fp = [(min(r_dke(xymask_prop_dke(:,iy))) - 1):(max(r_dke(xymask_prop_dke(:,iy))) + 1)];%corresponding FP points
        %        
        xyP0_2piRp_out(xmask_prop_fp,iy) = interp(xpsin_dke(xymask_prop_dke(:,iy)),xyP0_2piRp_out(xymask_prop_dke(:,iy)),xpsin(xmask_prop_fp),method);
        xyP0_2piRp_mod(xmask_prop_fp,iy) = interp(xpsin_dke(xymask_prop_dke(:,iy)),xyP0_2piRp_mod(xymask_prop_dke(:,iy)),xpsin(xmask_prop_fp),method);
    end
end
        

        

