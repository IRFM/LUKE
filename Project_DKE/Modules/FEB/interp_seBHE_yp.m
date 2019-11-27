function seBHE = interp_seBHE_yp(seBHE_table,Ec)
%
%	Interpolate the screened differential electron-ion bremstrahlung cross-section (dsigma/dk.domega)
%	for the Bethe-Heitler-Elwert model on a new electron energy grid
%
%	Input:
%
%       - seBHE_table: screened differential electron-ion bremstrahlung cross-section table (structure)
%		- Ec: kinetic energy of the incoming electron (keV) [1,m] 
%
%	Output: 
%
%		- seBHE: screened differential electron-ion bremstrahlung cross-section (m^2) [p,m,n,k]
%
%	Warning: Cross-section units : m^2 but energies are in relativistic units. To get 
%			 cross-sections in standard m^2/keV units, seH or seHC must be divided 
%			 by 511 keV.
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> 
%
if nargin < 2
    error('ERROR: Wrong input arguments in interp_seBHE_yp.m')
end
%
seBHE = zeros(seBHE_table.n_gauleg,length(Ec),length(seBHE_table.kphot),length(seBHE_table.Z0));
%
for i = 1:seBHE_table.n_gauleg
    for j = 1:length(seBHE_table.kphot)
        for k = 1:length(seBHE_table.Z0)
            seBHE(i,:,j,k) = interp1(seBHE_table.Ec,seBHE_table.seBHE(i,:,j,k),Ec);
        end
    end
end
%
display = 0;
%
if display 
    %
    figure
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(1,:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'r-',Ec,seBHE(1,:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(1,:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'r-',Ec,seBHE(1,:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(1,:,1,length(seBHE_table.Z0)),'r-',Ec,seBHE(1,:,1,length(seBHE_table.Z0)),'b*');hold on
    xlabel('Eletron kinetic energy (keV)')
    ylabel('e-i bremsstrahlung cross-section (m^2)')
    title(['BHE formula with screening ',seBHE_table.screening_model.screening_model,' model for ',seBHE_table.element]);
    legend(['Table (cos\theta) = ',num2str(seBHE_table.x_leg(1))],'Interpolation')
    grid on
    %
    figure
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(round(seBHE_table.n_gauleg/2),:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'r-',Ec,seBHE(round(seBHE_table.n_gauleg/2),:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(round(seBHE_table.n_gauleg/2),:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'r-',Ec,seBHE(round(seBHE_table.n_gauleg/2),:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(round(seBHE_table.n_gauleg/2),:,1,length(seBHE_table.Z0)),'r-',Ec,seBHE(round(seBHE_table.n_gauleg/2),:,1,length(seBHE_table.Z0)),'b*');hold on
    xlabel('Eletron kinetic energy (keV)')
    ylabel('e-i bremsstrahlung cross-section (m^2)')
    title(['BHE formula with screening ',seBHE_table.screening_model.screening_model,' model for ',seBHE_table.element]);
    legend(['Table (cos\theta) = ',num2str(seBHE_table.x_leg(round(seBHE_table.n_gauleg/2)))],'Interpolation')
    grid on
    %
    figure
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(seBHE_table.n_gauleg,:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'r-',Ec,seBHE(seBHE_table.n_gauleg,:,length(seBHE_table.kphot),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(seBHE_table.n_gauleg,:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'r-',Ec,seBHE(seBHE_table.n_gauleg,:,round(length(seBHE_table.kphot)/2),length(seBHE_table.Z0)),'b*');hold on
    semilogy(seBHE_table.Ec,seBHE_table.seBHE(seBHE_table.n_gauleg,:,1,length(seBHE_table.Z0)),'r-',Ec,seBHE(seBHE_table.n_gauleg,:,1,length(seBHE_table.Z0)),'b*');hold on
    xlabel('Eletron kinetic energy (keV)')
    ylabel('e-i bremsstrahlung cross-section (m^2)')
    title(['BHE formula with screening ',seBHE_table.screening_model.screening_model,' model for ',seBHE_table.element]);
    legend(['Table (cos\theta) = ',num2str(seBHE_table.x_leg(seBHE_table.n_gauleg))],'Interpolation')
    grid on
end
