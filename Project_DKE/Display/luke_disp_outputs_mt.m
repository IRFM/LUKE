function outputs = luke_disp_outputs_mt(equils,outputs,style,axs)
%
nt = length(equils);
%
waveids = {};
%
t = NaN(1,nt);
Ip = NaN(1,nt);
%
I_tot = NaN(1,nt);
P0_rf = NaN(1,nt);
P_rf = NaN(1,nt);
P_e = NaN(1,nt);
%
for it = 1:nt,
    if isempty(outputs{it}),% times for which LUKE is not run
        if ~isempty(waveids),
            %
            wP0_rf(it,:) = NaN;
            wP_rf(it,:) = NaN;
            wrhoP_rf(it,:) = NaN;
            %
            wP_rf_lin(it,:) = NaN;
            wrhoP_rf_lin(it,:) = NaN;
            %
        end
        %
    else% times for which LUKE is run
        %
        if ~isfield(outputs{it},'data_proc'),% times for which LUKE is not processed
            outputs{it}.data_proc = proc_luke_jd(outputs{it},struct);
        end
        %
        t(it) = equils{it}.shotime;
        Ip(it) = equils{it}.ip/1e6;
        %
        scalar = outputs{it}.data_proc.scalar;
        wave = outputs{it}.data_proc.wave;
        id = [outputs{it}.data_proc.simul.id,'_'];
        %
        I_tot(it) = -scalar.I_tot;%%%%%%%%%%%%%%%
        P0_rf(it) = scalar.p0_rf_2piRp*(2*pi*scalar.Rp);
        P_rf(it) = scalar.p_rf_2piRp*(2*pi*scalar.Rp);
        P_e(it) = scalar.p_e_2piRp*(2*pi*scalar.Rp);
        %
        nw = length(wave.wp0_rf_2piRp);
        %
        iC3PO = strfind(id,'C3PO');
        %
        if length(iC3PO) ~= nw,
            disp(['Warning : wave identification failed for time : ',num2str(t(it))])
            continue
        elseif nw > 0,
            iiws = zeros(1,nw);
            for iw = 1:nw,
                waveid = id(iC3PO(iw) + 4 + (1:min(strfind(id(iC3PO(iw)+5 : end),'_'))-1));
                iiw = find(strcmp(waveids,waveid));
                if isempty(iiw),
                    waveids = [waveids,waveid];
                    iiws(iw) = length(waveids);
                else
                    iiws(iw) = iiw;
                end
            end
            wP0_rf(it,iiws) = wave.wp0_rf_2piRp*(2*pi*scalar.Rp);
            wP_rf(it,iiws) = wave.wp_rf_2piRp*(2*pi*scalar.Rp);
            wrhoP_rf(it,iiws) = wave.wrhoP;
            %
            wP_rf_lin(it,iiws) = wave.wp_rf_2piRp_lin*(2*pi*scalar.Rp);
            wrhoP_rf_lin(it,iiws) = wave.wrhoP;
        elseif ~isempty(waveids),
            %
            wP0_rf(it,:) = 0;
            wP_rf(it,:) = 0;
            wrhoP_rf(it,:) = 0;
            %
            wP_rf_lin(it,:) = NaN;
            wrhoP_rf_lin(it,:) = NaN;
            %
        end
        %
    end
    %
end
%
colors = {'r','b',[0,0.5,0],'k'};
markers = {'s','d','+','o'};
%
xlab = 't (s)';
xlim = 0;
%
ylim = 0;
%
if nargin < 4,
    red = 0.9;
    lspace = 0.7;
    lspace2 = 0.5;
    bspace = 0.7;
    bspace2 = 0.5;
else
    red = 1;
    lspace = NaN;
    lspace2 = NaN;
    bspace = NaN;
    bspace2 = NaN;
end
%
% current
%
if nargin < 4,
    figure(1),clf,set(1,'Name','Current')
    ax = gca;
else
    ax = axs(1);
end
%
ylab = 'I (MA)';
if any(P_e ~= 0) && any(P_rf ~= 0)
    leg = {'I_p','I_{RF+\Omega}'};
elseif any(P_rf ~= 0)
    leg = {'I_p','I_{RF}'};
elseif any(P_e ~= 0)
    leg = {'I_p','I_{\Omega}'};
else
    leg = {'I_p','I_{luke}'};
end
%
[ax] = graph1D_jd(t,Ip,0,0,'','','',NaN,NaN,NaN,'-',markers{1},colors{1},2,style,ax);
[ax] = graph1D_jd(t,I_tot,0,0,xlab,ylab,'',leg,xlim,ylim,'-',markers{2},colors{2},2,style,ax);
%
% power
%
if nargin < 4,
    figure(2),clf,set(1,'Name','Power')
    ax = gca;
else
    ax = axs(2);
end
%
ylab = 'P (MW)';
leg = {'P_{RF0}','P_{RF}','P_{\Omega}'};
%
[ax] = graph1D_jd(t,P0_rf,0,0,'','','',NaN,NaN,NaN,'-',markers{1},colors{1},2,style,ax);
[ax] = graph1D_jd(t,P_rf,0,0,'','','',NaN,NaN,NaN,'-',markers{2},colors{2},2,style,ax);
[ax] = graph1D_jd(t,P_e,0,0,xlab,ylab,'',leg,xlim,ylim,'-',markers{3},colors{3},2,style,ax);
%
% wave absorption rate
%
if nargin < 4,
    figure(3),clf,set(1,'Name','Power')
    ax = gca;
else
    ax = axs(3);
end
%
wPfrac = wP_rf./wP0_rf;
wPfrac_lin = wP_rf_lin./wP0_rf;
%
ylab = 'P_{RF}/P_{RF0}';
%
nw = length(waveids);
for iw = 1:nw - 1,
    [ax] = graph1D_jd(t,wPfrac(:,iw),0,0,'','','',NaN,NaN,NaN,'--',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(t,wPfrac(:,nw),0,0,'','','',waveids,NaN,NaN,'--',markers{nw},colors{nw},2,style,ax);
%
for iw = 1:nw - 1,
    [ax] = graph1D_jd(t,wPfrac_lin(:,iw),0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},0.5,style,ax);
end
[ax] = graph1D_jd(t,wPfrac_lin(:,nw),0,0,xlab,ylab,'',NaN,xlim,ylim,'-',markers{nw},colors{nw},0.5,style,ax);
%
% wave power deposition location
%
if nargin < 4,
    figure(4),clf,set(1,'Name','Power')
    ax = gca;
else
    ax = axs(4);
end
%
ylab = 'r/a';
%
for iw = 1:nw - 1,
    [ax] = graph1D_jd(t,wrhoP_rf(:,iw),0,0,'','','',NaN,NaN,NaN,'--',markers{iw},colors{iw},2,style,ax);
end
[ax] = graph1D_jd(t,wrhoP_rf(:,nw),0,0,'','','',waveids,NaN,NaN,'--',markers{nw},colors{nw},2,style,ax);
%
for iw = 1:nw - 1,
    [ax] = graph1D_jd(t,wrhoP_rf_lin(:,iw),0,0,'','','',NaN,NaN,NaN,'-',markers{iw},colors{iw},0.5,style,ax);
end
[ax] = graph1D_jd(t,wrhoP_rf_lin(:,nw),0,0,xlab,ylab,'',NaN,xlim,ylim,'-',markers{nw},colors{nw},0.5,style,ax);
