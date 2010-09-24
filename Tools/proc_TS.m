function proc_TS(shotnum,t0,tscan,p_opt)
%
if nargin < 4,
    p_opt = -1;
end
%
if strcmp(shotnum,'40816'),
    cronos_file = 'zineb40816ts2de35a27850_resultat.mat';
    luke_file = 'LUKE_DATA_TS_40816_14.9000_C3PO_Coupleur_C1_C3PO_Coupleur_C2_OHM_RIPPLE.mat';
elseif strcmp(shotnum,'41125'),
    cronos_file = 'base/zineb41125ts0de38a21687_resultat.mat';
    luke_file = 'LUKE_DATA_TS_41125_18.9000_C3PO_Coupleur_C1_OHM_RIPPLE.mat';
elseif strcmp(shotnum,'43107'),
    cronos_file = 'zineb43107ts2_optimised_2_resultat.mat';
    if t0 == 11.5427,
        luke_file = 'LUKE_DATA_TS_43107_11.5427_C3PO_Coupleur_C1_C3PO_Coupleur_C2_OHM_RIPPLE.mat';
    elseif  t0 == 13.6225,
        luke_file = 'LUKE_DATA_TS_43107_13.6225_C3PO_Coupleur_C1_C3PO_Coupleur_C2_OHM_RIPPLE.mat';
    elseif  t0 == 15.0178,
        luke_file = 'LUKE_DATA_TS_43107_15.0178_C3PO_Coupleur_C1_C3PO_Coupleur_C2_OHM_RIPPLE.mat';
    else
        error('No LUKE run for this time')
    end
end
%
cronos_path = '~/zineb/data/TS/';
%
cronos_filename = [cronos_path,shotnum,'/',cronos_file];
%
luke_filename = [shotnum,'/',luke_file];
%
data_cronos = load(cronos_filename);
data_luke = load(luke_filename);
%
t = data_cronos.data.gene.temps;
dt = diff(t);
th = (t(1:end-1) + t(2:end))/2;
nt = length(t);
%
rho = data_cronos.param.gene.x;
%
Te = data_cronos.data.prof.te/1000;
q = data_cronos.data.prof.q;
qeq = data_cronos.data.equi.q;
%
j_ohm = data_cronos.data.prof.jmoy - data_cronos.data.neo.jboot - data_cronos.data.source.hyb.j;
j_hyb = data_cronos.data.source.hyb.j;
%
rho_luke = data_luke.output.equilDKE.xrhoT;
j_luke = data_luke.output.Zcurr.x_0_vcfsav*data_luke.output.mksa.j_ref;
%
q0 = q(:,1);
q0eq = qeq(:,1);
%
qmin = min(q,[],2);
qeqmin = min(qeq,[],2);
%
rho1 = NaN(nt,5);
rhoeq1 = NaN(nt,5);
%
for it = 1:nt,
    irho = find((q(it,2:end) - 1).*(q(it,1:end-1) - 1) <= 0);
    rho1(it,1:length(irho)) = (rho(irho).*abs(q(it,irho + 1) - 1) + rho(irho + 1).*abs(q(it,irho) - 1))./abs(q(it,irho + 1) - q(it,irho));
    %
    irhoeq = find((qeq(it,2:end) - 1).*(qeq(it,1:end-1) - 1) <= 0);
    rhoeq1(it,1:length(irhoeq)) = (rho(irhoeq).*abs(qeq(it,irhoeq + 1) - 1) + rho(irhoeq + 1).*abs(qeq(it,irhoeq) - 1))./abs(qeq(it,irhoeq + 1) - qeq(it,irhoeq));
end
%
if nargin < 3,
    tscan = [t(1),t(end)];
end
%
if nargin < 2,
    t0 = (t(1) + t(end))/2;
end
%
mask = t >=tscan(1) & t <= tscan(2);
it0 = find(t > t0,1,'first');
%
style0 = 'none';
style = '-';
style2 = '--';
marker = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = '.';
markers = {marker1,marker2,marker3};
color = NaN;
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
colors = {color2,color3,color4};
%
width = 0.5;
width2 = 2;
siz = 20+14*1i;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
%
figure(1),clf,set(1,'name','time steps')
%
x = th;
xlab = 't (s)';
xlim = NaN;
y = dt*1000;
ylab = '\Delta t (ms)';
tit = shotnum;
ylim = NaN;
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_dt'],[shotnum,'/figures'],1);
%
%
figure(2),clf,set(2,'name','Te0')
%
x = t;
xlab = 't (s)';
xlim = NaN;
y = Te(:,1);
ylab = 'T_{e0} (keV)';
tit = shotnum;
ylim = NaN;
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_te0'],[shotnum,'/figures'],2);
%
%
figure(3),clf,set(3,'name','Te0 zoom')
%
x = t(mask);
xlab = 't (s)';
xlim = NaN;
y = Te(mask,1);
ylab = 'T_{e0} (keV)';
tit = shotnum;
ylim = NaN;
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_te0_zoom'],[shotnum,'/figures'],3);
%
%
figure(4),clf,set(4,'name','q')
%
x = rho;
xlab = '\rho_T';
xlim = NaN;
y = [q(it0,:).',qeq(it0,:).'];
ylab = 'q';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_q'],[shotnum,'/figures'],4);
%
%
figure(5),clf,set(5,'name','q0')
%
x = t;
xlab = 't (s)';
xlim = NaN;
y = [q0,q0eq];
ylab = 'q_0';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_q0'],[shotnum,'/figures'],5);
%
%
figure(6),clf,set(6,'name','q0 Zoom')
%
x = t(mask);
xlab = 't (s)';
xlim = NaN;
y = [q0(mask),q0eq(mask)];
ylab = 'q_0';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_q0_zoom'],[shotnum,'/figures'],6);
%
%
figure(7),clf,set(7,'name','qmin')
%
x = t;
xlab = 't (s)';
xlim = NaN;
y = [qmin,qeqmin];
ylab = 'q_{min}';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_qmin'],[shotnum,'/figures'],7);
%
%
figure(8),clf,set(8,'name','qmin Zoom')
%
x = t(mask);
xlab = 't (s)';
xlim = NaN;
y = [qeqmin(mask),qmin(mask)];
ylab = 'q_{min}';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width2,siz,gca,red,lspace,bspace2);
%
print_jd(p_opt,['Fig_',shotnum,'_qmin_zoom'],[shotnum,'/figures'],8);
%
%
figure(9),clf,set(9,'name','rho1')
%
x = t;
xlab = 't (s)';
xlim = NaN;
y1 = rho1;
y2 = rhoeq1;
ylab = 'rho_1';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y1(:,1),0,0,xlab,ylab,tit,NaN,xlim,ylim,style0,marker1,color2,width2,siz,gca,red,lspace,bspace2);
graph1D_jd(x,y2(:,1),0,0,'','','',leg,xlim,ylim,style0,marker2,color3,width2,siz);
%
graph1D_jd(x,y1(:,2:end),0,0,xlab,ylab,tit,NaN,xlim,ylim,style0,marker1,color2,width2,siz);
graph1D_jd(x,y2(:,2:end),0,0,'','','',NaN,xlim,ylim,style0,marker2,color3,width2,siz);
%
print_jd(p_opt,['Fig_',shotnum,'_rho1'],[shotnum,'/figures'],9);
%
%
figure(10),clf,set(10,'name','rho1 Zoom')
%
x = t(mask);
xlab = 't (s)';
xlim = NaN;
y1 = rho1(mask,:);
y2 = rhoeq1(mask,:);
ylab = 'rho_1';
tit = shotnum;
ylim = NaN;
leg = {'prof','equi'};
%
graph1D_jd(x,y1(:,1),0,0,xlab,ylab,tit,NaN,xlim,ylim,style0,marker1,color2,width2,siz,gca,red,lspace,bspace2);
graph1D_jd(x,y2(:,1),0,0,'','','',leg,xlim,ylim,style0,marker2,color3,width2,siz);
%
graph1D_jd(x,y1(:,2:end),0,0,xlab,ylab,tit,NaN,xlim,ylim,style0,marker1,color2,width2,siz);
graph1D_jd(x,y2(:,2:end),0,0,'','','',NaN,xlim,ylim,style0,marker2,color3,width2,siz);
%
print_jd(p_opt,['Fig_',shotnum,'_rho1_zoom'],[shotnum,'/figures'],10);
%
%
figure(11),clf,set(11,'name','j')
%
x1 = rho;
x2 = rho;
x3 = rho_luke;
xlab = '\rho_T';
xlim = NaN;
y1 = j_ohm(it0,:)/1e6;
y2 = j_hyb(it0,:)/1e6;
y3 = j_luke;
ylab = 'J (MA/m^2)';
tit = shotnum;
ylim = NaN;
leg = {'OHM','LH','LUKE'};
%
graph1D_jd(x1,y1,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
graph1D_jd(x2,y2,0,0,'','','',NaN,xlim,ylim,style,marker1,color3,width2,siz);
graph1D_jd(x3,y3,0,0,'','','',leg,xlim,ylim,style,marker2,color4,width2,siz);
%
print_jd(p_opt,['Fig_',shotnum,'_J'],[shotnum,'/figures'],11);
%
