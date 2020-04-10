function [equil,flag] = equilcompatibility_yp(equil,display_mode)
%
% LUKE - Test the compatibility of the toroidal magnetic equilibrium with LUKE code
%
% Test the compatibility of the toroidal magnetic equilibrium with LUKE code
%
% INPUT
%
%    - equil: numerical magnetic equilibrium structure
%    - display_mode: display the results
%       (default display_mode = 0)
%
% OUTPUT: 
%
%    - equil: equilibrium with possibly some simple fix
%    - flag: equil status (-1: fully incompatible, 0 incompatible but has been fixed, 1: compatible
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 1
    error('ERROR: not enough input arguments in equilcompatibility_yp.m.');
end
%
if nargin < 2
    display_mode = 0;
end
%
ntheta = length(equil.theta);
npsi = length(equil.psi_apRp);
%
flag_test = 0;
%
for j = 1:2
    %
    BP_test = sqrt(equil.ptBx.^2 +equil.ptBy.^2);
    B_test = equil.ptBPHI + BP_test;
    %
    for ipsi = npsi:-1:1
        %
        test = find(B_test(ipsi,:)==min(B_test(ipsi,:)));
        %
        if test(1) ~= 1 || test(end) ~= ntheta
            %
            if test == 2
                equil.ptBx(ipsi,2) = (equil.ptBx(ipsi,1)+equil.ptBx(ipsi,3))/2;
                equil.ptBy(ipsi,2) = (equil.ptBy(ipsi,1)+equil.ptBy(ipsi,3))/2;
                equil.ptBPHI(ipsi,2) = (equil.ptBPHI(ipsi,1)+equil.ptBPHI(ipsi,3))/2;
                disp(['WARNING: Bfield structure is not compatible with LUKE @ i_psi = ',int2str(ipsi),' and j_theta = ',int2str(test)])
                flag_test = 1;
                if j==2
                    disp(['ERROR : A local fix cannot be enforced. Check the equilibrium.'])
                    flag = -1;
                    return
                end
            elseif test == ntheta-1
                equil.ptBx(ipsi,ntheta-1) = (equil.ptBx(ipsi,ntheta)+equil.ptBx(ipsi,ntheta-2))/2;
                equil.ptBy(ipsi,ntheta-1) = (equil.ptBy(ipsi,ntheta)+equil.ptBy(ipsi,ntheta-2))/2;
                equil.ptBPHI(ipsi,ntheta-1) = (equil.ptBPHI(ipsi,ntheta)+equil.ptBPHI(ipsi,ntheta-2))/2;
                disp(['WARNING: Bfield structure is not compatible with LUKE @ i_psi = ',int2str(ipsi),' and j_theta = ',int2str(test)])
                flag_test = 1;
                if j==2
                    disp(['ERROR : A local fix cannot be enforced. Check the equilibrium.'])
                    flag = -1;
                    return
                end
            elseif test == ntheta || test == 1
                equil.ptBx(ipsi,ntheta) = equil.ptBx(ipsi,1);
                equil.ptBy(ipsi,ntheta) = equil.ptBy(ipsi,1);
                equil.ptBPHI(ipsi,ntheta) = equil.ptBPHI(ipsi,1);
                disp(['WARNING: Bfield structure is not compatible with LUKE @ i_psi = ',int2str(ipsi),' and j_theta = ',int2str(test)])
                flag_test = 1;
                if j==2
                    disp(['ERROR : A local fix cannot be enforced. Check the equilibrium.'])
                    flag = -1;
                    return
                end
            else
                if nargin < 3
                    display_mode = 0;
                end
                %
                if display_mode == 2
                    figure,plot(equil.theta,B_test(ipsi,:))
                    xlabel('\theta_pol (rad)')
                    ylabel('B (T)')
                    grid on
                end
                flag = -1;
                disp('*****************')
                disp(['ERROR: Bfield structure is not compatible with LUKE @ i_psi = ',int2str(ipsi),' -> min(B) is not at theta = 0 (or 2*pi)'])
                disp('*****************')
                return
            end
            %
        end
    end
end
%
if flag_test == 1
    disp('*****************')
    disp(['WARNING : A local fix has been be enforced ---> the equilibrium is compatible with LUKE.'])
    disp('*****************')
    %
    flag = 0;
else
    flag = 1;
end
%