function launch = imake_launch_LH_jd
%
% This function builts the launch structure for LH waves from user-specified data
%
dNpar0 = 0.2;
%
launch.omega_rf = 2*pi*1e9*input_dke_yp('Wave frequency (GHz)',4.6,[0;Inf],'',[1,1]);
%
launch.LFS = input_dke_yp('Launching side : (-1) high field side, (1) low field side',1,[-1,1],'',[1,1]);    
%
launch.m0 = input_dke_yp('Initial poloidal mode number (enter ''NaN'' to specify toroidal mode number)',0,[],'',[1,1]);
%
if isnan(launch.m0),
    launch.n0 = input_dke_yp('Initial toroidal mode number',0,[],'',[1,1]);
else
    launch.n0 = NaN;
end
%
launch.phi0 = pi/180*input_dke_yp('Initial toroidal angle (in deg.)',0,[],'',[1,1]);
%
n_lobe = input_dke_yp('Number of spectral lobes',1,1:10,'',[1,1]);  
%
launch.bPlhtot = 1e6*input_dke_yp('Initial power in each lobe (MW)',[],[0;Inf],'',[1,n_lobe]);  
launch.bNpar0 = input_dke_yp('Initial Npar in each lobe',[],[],'',[1,n_lobe]);  
launch.bdNpar0 = input_dke_yp(['Spectral width in each lobe :',...
            '\n specify fixed value, or ',...
            '\n type ''0'' if minimum width within numerical constraints'],dNpar0*ones(1,n_lobe),[0;Inf],'',[1,n_lobe]);
%
m_pol = input_dke_yp('Number of vertical launching positions',1,1:10,'',[1,1]);  
%
launch.rZ0 = input_dke_yp('Vertical launching positions (m)',[],[],'',[1,m_pol]).';  
%
launch.id = input_dke_yp('Provide an id for this launching structure','');
%
