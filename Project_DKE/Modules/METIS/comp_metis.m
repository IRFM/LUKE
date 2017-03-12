function [post_ref,tts] = comp_metis(post,post_ref,fieldlist_time,fieldlist_prof,tmin,tmax,tprof)
%
%
%
close all
%
if nargin == 0,
    disp('Not enough input arguments for comp_metis.m ');
    return;
end
%
if ~isfield(post(1).zerod,'temps'),
    disp('ERROR: the post structure does not correspond to a simulated discharge. Run METIS first.');
    return;
end
%
if nargin == 1,
    post_ref = post;
    fieldlist_time = '';
    fieldlist_prof = '';
    tmin = -Inf;
    tmax = +Inf;
    tprof = '';
end
%
if nargin == 2
    fieldlist_time = '';
    fieldlist_prof = '';
    tmin = -Inf;
    tmax = +Inf;
    tprof = '';
end
%
if nargin == 3,
    fieldlist_prof = '';
    tmin = -Inf;
    tmax = +Inf;
    tprof = '';
end
%
if nargin == 4,
    tmax = +Inf;
    tprof = '';
end
%
if ~isempty(post_ref) && nargin > 1,
    post_ref = [post_ref,post];
    %%%%%comment
else 
    post_ref = post;
    %%%%%comment
end
%
if isempty(fieldlist_time), 
    fieldlist_time = {'pohm','iohm','plh','vloop'};%default field list (time evolution)
end
if isempty(fieldlist_prof), 
    fieldlist_prof = {'pohm','plh','jlh'};%default field list (radial profile)
end
%
flag = 1;
%
tts = '';
%
for ii = 1:length(fieldlist_time),
    %
    fhandle = figure('Name',fieldlist_time{ii});
    %
    leg = '';
    %
    ttmin = [];
    ttmax = [];
    vvmin = [];
    vvmax = [];
    %
    for jj = length(post_ref):-1:1,
        %    
        tt = post_ref(jj).zerod.temps;
        vv = post_ref(jj).zerod.(fieldlist_time{ii});
        %
        imin = max(find(tmin>tt));
        imax = min(find(tmax<tt));
        %
        if isempty(imin), imin = 1;end
        if isempty(imax), imax = length(tt);end
        %
        [cplot,lplot,wplot,splot] = graphclws_yp('clws',jj);
        %
        leg = [leg;[post_ref(jj).z0dinput.machine,', #',int2str(post_ref(jj).z0dinput.shot)]];
        ghandle = graph1D_jd(tt,vv,0,0,'time (s)',fieldlist_time{ii},[post_ref(jj).z0dinput.zsinfo.(fieldlist_time{ii})],leg,[tt(imin),tt(imax)],'',lplot,splot,cplot,wplot,20,gca,1,NaN);        
        %
        if isempty(ttmin) & isempty(ttmax)
            ttmin = tt(imin);
            ttmax = tt(imax);
            vvmin = min(vv);
            vvmax = max(vv);
        else
            ttmin = min([ttmin,tt(imin)]);
            ttmax = max([ttmax,tt(imax)]);
            vvmin = min([vvmin,min(vv)]);
            vvmax = max([vvmax,max(vv)]);
        end
        %
    end
    %
    if flag == 1,
        %
        disp(flag);
        [tts,vvs] = ginput(1);%set one point for radial display
        %
        if (ttmin < tts) & (tts < ttmax),
            disp(['Time ',num2str(tts),' (s) selected.'])
            flag = 0;
        else
            tts = '';
            disp('No time not selected.');
        end
    end
    %
    if ~isempty(tts),%plot reference time
        ax = gca;    
        line([tts,tts],ax.YLim,'LineStyle','--','Color','k')
    end
end
%
profinfo = z0dprofinfo;%get prof definitions
%
for ii = 1:length(fieldlist_prof),
    %
    
    fhandle = figure('Name',[fieldlist_prof{ii},' prof']);
    %
    leg = '';
    %
    for jj = length(post_ref):-1:1,
    %    
        xli = post_ref(jj).profil0d.xli;
        iref = max(find(post_ref(jj).profil0d.temps < tts));
        %
        vvr = post_ref(jj).profil0d.(fieldlist_prof{ii})(iref,:);
        ttr = post_ref(jj).profil0d.temps(iref);
        %
        [cplot,lplot,wplot,splot] = graphclws_yp('clws',jj);
        %
        leg = [leg;[post_ref(jj).z0dinput.machine,', #',int2str(post_ref(jj).z0dinput.shot),', @ ',num2str(ttr),' (s)']];
        ghandle = graph1D_jd(xli,vvr,0,0,'r/a (Li coordinates)',fieldlist_prof{ii},[profinfo.(fieldlist_prof{ii})],leg,[0,1],'',lplot,splot,cplot,wplot,20,gca,1,NaN);
        %
    end
    %
    dtt = max(gradient(post_ref(jj).profil0d.temps));
    %
    set(fhandle,'Units','pixels');
    windowSize = get(fhandle,'Position');
    %
    shandle = uicontrol('Style','slider','Min',ttmin,'Max',ttmax,'Value',ttr,'SliderStep',[dtt dtt*2],'Position', [20 10 windowSize(3)-40 20]);
    addlistener(shandle,'ContinuousValueChange',{@myupdatefcn,ghandle,post_ref,fieldlist_prof{ii}});
   
end

