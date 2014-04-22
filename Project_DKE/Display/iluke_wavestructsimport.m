% script iluke_wavestructsimport
% 
% it assumes (from the enabling of import pushbutton) that external.wave
% exists for the specific curtime
%
select = struct;
select.style = style;
%
if curtime == 0,% treat all times from external structure if available
    flag_calc = find(status.equil == 1);
    [~,flag_calctimes,flag_external] = intersect(shotimes(flag_calc),external.times);
    flag_shotimes = flag_calc(flag_calctimes);
    %
    clear flag_calc flag_calctimes
else% select one time
    flag_external = find(external.times == shotimes(curtime));
    flag_shotimes = curtime;
end
%
external_wave = external.wave(flag_external);
nt = length(external_wave);
%
for it = 1:nt,
     external_wave(it).equil = equils{flag_shotimes(it)};% for distributed computing
end
%
clear flag_calc flag_calctimes it nt
%
if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
    %
    mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
    %
    if mdce_mode > 2,
        mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
    end
    %
    dkecluster = clustermode_luke(mdce_mode,'',dkepath);%MatLab distributed computing environment
    %
    set(lukeobj.busy.handle,'Visible','on');drawnow;
    [flag,launchs] = mdce_run('imake_launch_jd',{dkepath,tokamak,'','',workdir,lukeobj.infopanel.handle,select},4,external_wave,dkecluster);
    set(lukeobj.busy.handle,'Visible','off');drawnow;
    %
    clear mdce_mode dkecluster flag 
    %            
elseif length(flag_shotimes) == 1% treat one time 
    %
    launchs{1} = imake_launch_jd(dkepath,tokamak,'',external_wave,workdir,lukeobj.infopanel.handle,select);
    %
end
%
if isfield(launchs,'err'),
    lukeobj.infotext.string = {'Error creating structure(s) ''launchs'' : ',launchs.err};
elseif ~isempty(launchs),
    %
    iluke_newwavestructs;% update wavestructs, status and wavestructids
    %
end
%
clear select launchs external_wave flag_shotimes
