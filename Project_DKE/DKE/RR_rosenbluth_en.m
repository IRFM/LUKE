function [RR_an] = RR_rosenbluth(alpha, Zi, ne, lnc_e_ref, epsi)
%
%   Evaluates Eq. 18 in Rosenbluth Putvinski NF 1997 as a function of alpha
%   or Zi
%
% INPUT:
%   - epsi: inverse aspect ratio r/R
%   - ne: plasma density for collision time calculation
%   - alpha: E/Ec, vector
%   - Zi: charge, vector
%
% OUTPUT:
%
%   - Analytic runaway rate from Eq. 18 in Rosenbluth Putvinski NF 1997
%
%   by E. Nilsson (emelie.nilsson@cea.fr) Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC)   (joan.decker@cea.fr)
%   
[qe,me,dummy,dummy,e0,dummy,dummy,dummy,clum] = pc_dke_yp; %Universal physics constants
%
%tau_c = me^2*clum^3/(4*pi*ne*qe^4*lnl)
tau_c = 4*pi*e0^2*me^2*clum^3/(ne*qe^4*lnc_e_ref); %LUKE def.
%Ec=me*clum/(qe*tau_c);
%
gam = 1/(1+1.47*sqrt(epsi)+1.72*epsi);
%alpha = alpha/1e4*clum;
if Zi == -1
RR_an = 1/(2*tau_c*lnc_e_ref).*(alpha-1); %simplified growth rate, for E/Ec >> 1, see
elseif Zi>1
b= 2*gam/(3*(Zi+1)).*alpha.^2;
RR_an = 1/(tau_c*lnc_e_ref).*sqrt(pi.*b/2).*sqrt(1+8*pi./(9*b)); %simplified growth rate, for E/Ec >> 1, see    
else
RR_an = 1/(tau_c*lnc_e_ref)*sqrt((pi*gam)./(3*(Zi+5))).*(alpha-1)./sqrt((1-1./alpha+4*pi*(Zi+1).^2./(3*gam*(Zi+5).*(alpha.^2+4/gam^2-1))));
end

  
%Eq (7) in RP NF 1997
%