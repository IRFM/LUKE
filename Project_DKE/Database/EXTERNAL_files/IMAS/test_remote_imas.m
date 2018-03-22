close all
clear all
clc
dkepath = load_structures_yp('dkepath','','');
opt_gui = false;
select.style = struct;
scheduler.remnum = iselect_jd(dkepath.remprofiles,'Remote calculation mode (mdce_remote): ',opt_gui,select.style,1)-1;
if scheduler.remnum > 1,
    remote = dkepath.remote(scheduler.remnum);
    %remote.link_mode=1;%ssh bridge otherwise 0 (direct ssh)
    job = matstandardjob_jd('runmat');
    [err,job,phyb,tlh] = matremote_jd('tsbase',{45525,'gphyb'},remote,job);%find remotely the optimum density in front of the grill consistent with RC measurements
else
    disp('WARNING: direct connexion to the CEA network is necessary');
    [phyb,tlh] = tsbase(45525,'gphyb');%
end
%
plot(tlh,phyb);title('WEST, #52702'),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');