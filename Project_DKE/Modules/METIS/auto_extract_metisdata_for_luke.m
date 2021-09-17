function [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = auto_extract_metisdata_for_luke(post,shotime,bsigne,auto_mode,equilconsistency)
%
if nargin < 2
    error('')
elseif nargin < 3
    bsigne = 1;%
    auto_mode = 1;
    equilconsistency = '';
elseif nargin < 4
    auto_mode = 1;
    equilconsistency = '';
elseif nargin < 5
    equilconsistency = '';
end
%
time = post.profil0d.temps;
nt = length(time);
tmask = NaN(1,nt);
for it = 1:nt,
    tmask(it) = find(abs((post.zerod.temps - time(it))/(time(it)+eps)) < 10*eps,1,'first');
end
%
itsel = [];
%
it = find(abs(time - shotime) == min(abs(time - shotime)),1,'first');
tdisp(it) = time(it);
itsel = tdisp > 0;
it = length(itsel);
%
post.z0dinput.option.luke_mode = 2;%save without LUKE calculation
%
post.z0dinput.option.luke_helena = 0;%(0) use metis equilibrium, (1) use helena to recalculate the equilibrium, (2) load an existing equilibrium\n ?',0,0:2);
post.z0dinput.option.bsigne = bsigne;%Direction of the toroidal magnetic field viewed from top, (1) clockwise, (-1) anti-clockwise
%
[dummy,lukestructs] = metis2luke(post,it,auto_mode,equilconsistency);
%
dkeparam = lukestructs.dkeparam;
dkedisplay = lukestructs.dkedisplay;
equil = lukestructs.equil;
ohm = lukestructs.ohm;
transpfaste = lukestructs.transpfaste;
ripple = lukestructs.ripple;
wavestructs = lukestructs.wavestructs;
%
