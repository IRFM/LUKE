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
function zF = raypath_jd(xyF,xyprop_dke,yb,r_dke);
%
[nr_dke,ny] = size(xyprop_dke);
%
xymask_prop_dke = xyprop_dke ~= 0;%DKE points visited by the ray
%
ib = 0;
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
        ib = ib + 1;
        zF{ib} = [];
    end
    %    
    while ir_dke <= nr_dke & ir_dke >= 1 & xyprop_dke(ir_dke,iy) ~= 0 % stay on current ray 
        ir = r_dke(ir_dke);
        %
        zF{ib} = [zF{ib},xyF(ir,iy)];
        % 
        % next FS
        %
        ir_dke = ir_dke + xyprop_dke(ir_dke,iy);
    end
    %
    % interpolation for the FP positions (only necessary if dke_mode == 1)
    %
    %if dke_mode == 1  
        %        
    %end
end
        

