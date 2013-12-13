function [bNpar0,bdNpar0,bPlhtot,param_tor,param_pol] = iproc_spectrum_jd(spectrum,select,signs)
%
if nargin < 3,% to keep main lobe positive if no sign specified
    signs.ip = 1;
    signs.b0 = -1;
end
%
if nargin < 2,
    select = struct;
end
%
if ~isfield(spectrum,'Plhtot'),
    spectrum.Plhtot = 1e6;% default power : 1 MW
end
%
% This function processes spectral data into a series of toroidal (and
% possibly poloidal) lobes for ray-tracing application
%
[bNtor0,bdNtor0,bPlhtor,param_tor] = proc_aloha_spec_jd(spectrum.nz,NaN,real(spectrum.dP_nz),spectrum.Plhtot,spectrum.param_tor,0,select);
%
if ~isfield(spectrum,'ny') || ~isfield(spectrum,'dP'),
    opt_ny = 0;
elseif ~isfield(select,'inter') || ~select.inter,% no interactive mode
    opt_ny = spectrum.param_pol.opt_ny;
else
    opt_ny = iselect_jd({'With multiple vertical positions','With poloidal spectrum'},'How do you want to describe the wave poloidally ?',select.opt_gui,select.style,1) - 1;
end
%
if opt_ny == 1,% process poloidal aloha spectrum for LUKE
    [bNpol0,bdNpol0,bPlhpol,param_pol] = proc_aloha_spec_jd(spectrum.ny,NaN,sum(real(spectrum.dP.')),1,spectrum.param_pol,0,select);     
else
    bNpol0 = 0;
    bdNpol0 = 0;
    bPlhpol = 1;                
end
%
param_pol.opt_ny = opt_ny;
%
% Since N// is not strictly speaking Ntor, we make it imaginary to notify init_RT_jd. In this case, the real part is Ns and the imaginary part is Nz
%
nlobes_tor = length(bNtor0);
nlobes_pol = length(bNpol0);
%
bNpar0 = NaN(1,nlobes_tor*nlobes_pol);
bdNpar0 = NaN(1,nlobes_tor*nlobes_pol);
bPlhtot = NaN(1,nlobes_tor*nlobes_pol);
%
% The number of rays is nlobes_tor x nlobes_pol. The toroidal sign is
% assumed to be for co-current
%
for iy = 1:nlobes_tor,
    bNpar0((iy - 1)*nlobes_pol + (1:nlobes_pol)) = - 1i*bNtor0(iy)*signs.ip + bNpol0;
    %
    % the combined spectral width effect is not yet implemented
    % (TODO) see how to include it, maybe in init_RT_jd
    % watch for possible conflicts with square spectrum prescriptions
    %
%   bdNpar0((iy - 1)*nlobes_pol + (1:nlobes_pol)) = 1i*bdNtor0(iy) + bdNpol0;
    %
    bdNpar0((iy - 1)*nlobes_pol + (1:nlobes_pol)) = bdNtor0(iy)*ones(1,length(bdNpol0));
    %
    bPlhtot((iy - 1)*nlobes_pol + (1:nlobes_pol)) = bPlhtor(iy)*bPlhpol;
end
%
