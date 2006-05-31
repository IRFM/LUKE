function [xyPinc_out,xyPinc_mod] = rfprop_dke_jd(yb,xyprop_dke,xyPinc_in,xyPabs_dke,xdV_dke,xpsin,xpsin_dke,r_dke,dke_mode);
%
% This function ensures consistency between the power travelling with RF
% rays and the power absorbed by the plasma. Iterations between
% rfprop_dke_jd and dke_yp are required to reach consistency.
%
%   INPUTS:
%
%       - yb: list of ray starts
%       - xyprop_dke: propagation factors at DKE FS
%       - xyPinc_in: input incident power at each FP position
%       - xyPabs: absorbed power density in the DKE FS
%       - xydV_dke: incremental volume in the DKE FS
%
%   OUTPUTS:
%
%       - xyPinc_out: calculated current step incident power at each FP position
%       - xyPinc_mod: estimated next step incident power at each FP position
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
[nr_dke,ny] = size(xyprop_dke);
%
xyPinc_out = xyPinc_in;%default values
xyPinc_mod = xyPinc_in;%default values
%
xydV_dke = xdV_dke'*ones(1,ny);
xyPrf_dke = xyPabs_dke.*xydV_dke;%power absorbed from each ray within each FS
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
        bPrf = xyPinc_in(ir,iy); %initial power in the ray
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
            xyPinc_out(ir,iy) = bPrf - Pabs/2; %incident power consistent with absorbed power
            %
        else
            %
            xyPinc_out(ir,iy) = xyPinc_in(ir,iy)*bPrf/Pabs; %linear anticipation
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
        if xyPinc_in(ir,iy) > 0
            Pabs_mod = xyPrf_dke(ir_dke,iy)*bPrf_mod/(xyPinc_in(ir,iy) + xyPrf_dke(ir_dke,iy)/2);% absorbed power in this step
        else
            Pabs_mod = xyPrf_dke(ir_dke,iy);% absorbed power in this step
        end
        %
        if Pabs_mod <= bPrf_mod % absorbed power cannot be more than incident power
            %
            xyPinc_mod(ir,iy) = bPrf_mod - Pabs_mod/2; %incident power consistent with absorbed power
            %
        else
            %
            xyPinc_out(ir,iy) = xyPinc_in(ir,iy)*bPrf_mod/xyPrf_dke(ir_dke,iy); %linear anticipation
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
        xyPinc_out(xmask_prop_fp,iy) = interp(xpsin_dke(xymask_prop_dke(:,iy)),xyPinc_out(xymask_prop_dke(:,iy)),xpsin(xmask_prop_fp),method);
        xyPinc_mod(xmask_prop_fp,iy) = interp(xpsin_dke(xymask_prop_dke(:,iy)),xyPinc_mod(xymask_prop_dke(:,iy)),xpsin(xmask_prop_fp),method);
    end
end
        

        

