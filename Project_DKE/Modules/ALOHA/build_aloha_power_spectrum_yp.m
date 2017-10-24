%function antenna = build_aloha_power_spectrum_yp(sc,ptot,edge_ne,rc,eps_rc,dkepath,scheduler)
%
clear all
load toto.mat
%
if isempty(rc)
   sc.plasma.ne0 = edge_ne;
end
%
clustermode.aloha_scenario.scheduler = scheduler;
dkecluster = clustermode_luke(clustermode,'aloha_scenario',dkepath);%MatLab distributed computing environment
%
[flag_aloha_scenario,sc_out] = mdce_run(@aloha_scenario,{sc},1,{sc},dkecluster);
%
sc = sc_out{1};
%



