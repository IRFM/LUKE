function [wavestructss,wavestructids] = iluke_mod_P0_wavestructs(wavestructss,wavestructids,status,iw,P0_kW)
%
P0str = ['_P0_',num2str(P0_kW),'_kW'];
%
flag_shotimes = find(status.wavestructs(iw,:) == 1);
%
for it = flag_shotimes,
    %
    wavestructss{iw,it}.launch.angles.P0 = P0_kW*1e3;
    wavestructss{iw,it}.launch.angles.id = [wavestructss{iw,it}.launch.angles.id,P0str];
    %
    wavestructss{iw,it}.launch.yP_L = P0_kW*1e3;
    wavestructss{iw,it}.launch.id = [wavestructss{iw,it}.launch.id,P0str];
    %
    wavestructss{iw,it}.id = [wavestructss{iw,it}.id,P0str];
    %
end
%
wavestructids{iw} = wavestructss{iw,it}.id;
%       
    
    
    
    
    