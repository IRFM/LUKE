function filename = helenaequil_f_jd(tokamak,savename)
%
%   This function generates the data file of an equilibrium based on
%   the information stored in ptok_dke_1yp and the magnetic geometry
%   obtained from the helena MHD code. (Use HELMEX77 mexfile version of HELENA)
%
%   INPUTS:
%
%       - tokamak: tokamak scenario selected (in ptok_dke_1yp)
%       - savename: file name for storing the equilibrium 
%           (default: same as tokamak)
%
%   NOTE: 
%
%       - The non-magnetic profiles are obtained from the profile
%       parameters of ptok_dke_1yp, using the profile coordinate rho
%       derived from the magnetic geometry as rho = (R - Rp)/(Rmax - Rp)
%       taken on the outboard midplane.
%
%   By J. Decker <jodecker@mit.edu>, Y. Peysson <yves.peysson@cea.fr> and G. Huysmans <huysman@drfc.cad.cea.fr>
%
if nargin < 1,error('Not enough arguments');end
if nargin < 2,
	savename = tokamak;
end
%
[ap,Rp,Zp,xpoint,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff,...
	 HXR,file_helena] = ptok_dke_1yp(tokamak);        
%
%Run HELENA magnetic equilibrium code (FORTRAN file). 
%
[s,dossier,machine,mexext] = comput_dke_yp;
if exist(['runhel',mexext]) == 3,
	eval ['runhel ',file_helena]);

%
%		
		filename = ['EQUIL_',savename,'.mat'];
%
	eval(['save ',dossier,s,filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi ftra HXR'])   
else
	error(['The script file ''runhel'' for running HELENA does not exists !']);
end





