%
%test access to MDS+ database 
%
clear all
close all
clc
%
% Direct access
%
%
% JET Tokamak
%
mdsconnect('mdsplus.jet.efda.org');%JET
shot = 84744;
%
[picrh,status] = mdsvalue(sprintf('_sig7=jet("ppf/ICRH/PTOT",%d)',shot));
[ticrh,status] = mdsvalue('dim_of(_sig7)');  picrh=picrh/1e6;
%
mdsclose;
mdsdisconnect;
%
figure, plot(ticrh,picrh)
title('JET discharge #84744');
xlabel('time (s)');ylabel('P_{icrh} (MW')
%
% EAST tokamak
%
mdsconnect('202.127.204.42');%EAST
shot = 43326;
%               
mdsopen('pcs_EAST',shot);
%
Ip = mdsvalue('\pcrl01'); % plasma current
time = mdsvalue('dim_of(\pcrl01)'); 
%
mdsclose;
mdsdisconnect;
%
figure, plot(time,Ip/1e6,'r-')
title('EAST discharge #43326');
xlabel('time (s)');ylabel('|I_p| (MA)')

%
% Remote access
%
% Alcator C-Mod (because PSFC database accessible from a local workstation
% only). Use 'traverser' application in a terminal on a local workstation to get all
% the tree structures (not the data). Type cmod, and -1 for the shot. Use
% scope to see data locally. It can be done also in matlab on the
% workstation, 
%
% mdsopen('cmod',1160727011)
% mdstcl
% dir
% set def .MHD
% dir
%... until \ANALYSIS::EFIT_GEQDSK
%
% the exit TCL mode and type   a = mdsvalue('\nameofdata') for the data and
% t = mdsvalue(dim_of(\nameofdata,xx)') wiith xx= 1 or 2, or for the time. 
%
sinputs.remote.profile = 'PSFC_CMODWS85';% 
sinputs.remote.profilename = NaN;%may be yves, joan, ypeysson or NaN
sinputs.remote.link_mode = NaN;% use value from remote.link_mode
sinputs.mdsplus.ipserver = 'alcdata.psfc.mit.edu';
sinputs.mdsplus.shotnumber = '1160727001';
sinputs.mdsplus.tree(1).name = 'magnetics';
sinputs.mdsplus.tree(1).values = {'\ip','\btor'};
sinputs.mdsplus.tree(1).units = {'A','T'};
sinputs.mdsplus.tree(2).name = 'electrons';
sinputs.mdsplus.tree(2).values = {'\top.tci.results:nl_04','\electrons::top.tci.results.inversion.nebar_efit','\gpc2_te0','\thom_midpln:te_t'};
sinputs.mdsplus.tree(2).units = {'m^2','m^3','keV','keV'};
sinputs.mdsplus.tree(3).name = 'analysis';
sinputs.mdsplus.tree(3).values = {'\top.mflux:v0'};
sinputs.mdsplus.tree(3).units = {'V'};
sinputs.mdsplus.tree(4).name = 'LH';
sinputs.mdsplus.tree(4).values = {'\top.hxr.results:'};
sinputs.mdsplus.tree(4).units = {'V'};
%
% \ip -> plasma current (A)
% \btor') -> toroidal magnetic field (T)
% \top.tci.results:nl_04 -> line integrated density (m^-2), dividing nl_04 by 0.6 m for getting ne (the length of the chord integrated over).
% \electrons::top.tci.results.inversion.nebar_efit -> line averaged electron density calculated from EFIT (m^-3) 
% \gpc2_te0 -> electron temperature on axis (keV) from ECE
% \thom_midpln:te_t -> electron T on axis (keV) from Thomson scattering
% \top.mflux:v0 -> loop voltage on axis (V)
%
soutputs = remotemdsplus(sinputs);
%
if isfield(soutputs,'err'),
    %
    disperr_jd(soutputs.err)
    %
else
    %
    figure,plot(soutputs.mdsplus.tree(1).values(1).time,abs(soutputs.mdsplus.tree(1).values(1).data)/1e6);
    xlabel('time (s)');ylabel('|I_p| (MA)')
    title(['Alcator C-Mod discharge #',sinputs.mdsplus.shotnumber]);
    %
end
%
