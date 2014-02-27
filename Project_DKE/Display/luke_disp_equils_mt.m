function [ output_args ] = luke_disp_equils_mt( equils, plt, ax, style )
%LUKE_DISP_EQUILS_MT [ output_args ] = luke_disp_equils_mt( equils, plt, ax )
%   plots the equilibrium profiles for multi times
%
% INPUT:
%   equils .... cell with equilibrium structures from LUKE (multi times)
%   plt ....... plot type ( 1,2 or 3 )
%   ax ........ axis handle of axis where the plot should be done.
%               default: open a new figure
%   style ..... plot style parameters for iluke integration (optional) 
%
% OUTPUT:
%   none
%
% PLOT KINDS
%   1. time evolution of density, temperature, Zeff
%   2. time evolution of Ip, Bphi, q0 and q95
%   3. time evolution of axis z position, Shafranov shift, kappa, delta
%
%
%   J. Kamleitner, CRPP, EPFL, Feb 2014

% dependencies:
% equilmoments_jd.m
% gti_plot_symcol.m
% qfactors_dke_yp.m

if(nargin<3 || isempty(ax))
    figure;
    ax=gca();
end

% init plt parameters
ntr=[4 4 4];
% reference values and units
Bphiunit='T';
Bphiref=1;
sBphiref=sprintf('%s',Bphiunit);
deltaunit='1';
deltaref=1;
sdeltaref=sprintf('%s',deltaunit);
Deltaunit='1';
Deltaref=0.1;
sDeltaref=sprintf('0.%s',Deltaunit);
ipunit='A';
ipref=1e5;
kappaunit='1';
kapparef=1;
skapparef=sprintf('%s',kappaunit);
sipref=sprintf('100k%s',ipunit);
neunit='m^{-3}';
neref=1e19;
sneref=sprintf('1e19%s',neunit);
qunit='1';
qref=1;
sqref=sprintf('%s',qunit);
Teunit='keV';
Teref=1;
sTeref=sprintf('%s',Teunit);
Tiunit='keV';
Tiref=0.1;
sTiref=sprintf('100%s',Tiunit(2:end));
zunit='m';
zref=1;
szref=sprintf('%s',zunit);
Zeffunit='1';
Zeffref=1;
sZeffref=sprintf('%s',Zeffunit);


% create basic traces and profiles
neq=numel(equils);
% nrho=numel(equils{1}.psi_apRp);
time=zeros(1,neq);
if(any(plt==[1 2 3]))
    dat=zeros(ntr(plt),neq);
end
for i=1:neq
    time(i)=equils{i}.shotime;
    switch plt
        case 1
            % data
            dat(1,i)=equils{i}.pne(1)/neref;
            dat(2,i)=equils{i}.pTe(1)/Teref;
            dat(3,i)=equils{i}.pzTi(1)/Tiref;
%             dat(4,i)=mean(sum(equils{i}.pzni.*repmat(equils{i}.zZi'.^2,1,nrho))./equils{i}.pne);
            dat(4,i)=sum(equils{i}.pzni(:,1).*equils{i}.zZi'.^2)./equils{i}.pne(1)/Zeffref;
            % legend
            legstr={sprintf('n_{e,0}/%s',sneref),sprintf('T_{e,0}/%s',sTeref),sprintf('T_{i,0}/%s',sTiref),sprintf('Z_{eff,0}/%s',sZeffref)};
        case 2
            % data
            dat(1,i)=equils{i}.ip/ipref;
            dat(2,i)=equils{i}.ptBPHI(1)/Bphiref;
            % function qfactors computes q;
            % see also equilibrium_jd function for correct usage
            q=qfactors_dke_yp(1,equils{i}.Rp,equils{i}.ptx(end),equils{i}.ptx,equils{i}.pty,equils{i}.ptBx,equils{i}.ptBy,equils{i}.ptBPHI)* equils{i}.ptx(end)/equils{i}.Rp/qref;
            dat(3,i)=q(2);
            rhopol=sqrt(equils{1}.psi_apRp/equils{1}.psi_apRp(end));
            dat(4,i)=interp1(rhopol(2:end),q(2:end),0.95,'spline');
            % legend
            legstr={sprintf('I_p/%s',sipref),sprintf('B_{\\phi,0}/%s',sBphiref),sprintf('q_0/%s',sqref),sprintf('q_{95}/%s',sqref)};
        case 3
            %data
            dat(1,i)=equils{i}.Zp/zref;
            [pshift,pelong,ptrian]=equilmoments_jd(equils{i}.theta,equils{i}.ptx,equils{i}.pty);
            dat(2,i)=-pshift(end)/Deltaref;
            dat(3,i)=pelong(end)/kapparef;
            dat(4,i)=ptrian(end)/deltaref;
            % legend
            legstr={sprintf('z_{axis}/%s',szref),sprintf('\\Delta/%s',sDeltaref),sprintf('\\kappa/%s',skapparef),sprintf('\\delta/%s',sdeltaref)};
    end
end

% do the plotting
if(any(plt==[1 2 3]))
    if nargin < 4 || isempty(style),
        for j=1:ntr(plt)
            plot(ax,time,dat(j,:),gti_plot_symcol('sym',j,ntr(plt)),'Color',gti_plot_symcol('col',j,ntr(plt)));
            if(j==1)
                hold on;
            end
        end
        hold off;
        legend(legstr);
        YL=ylim;
        if(YL(1)>0)
            ylim([0 YL(2)]);
        elseif(YL(2)<0)
            ylim([YL(1) 0]);
        end
    else
        colors = {'r','b',[0,0.5,0],'k'};
        markers = {'s','d','+','o'};
        for j=1:ntr(plt)-1
            [ax] = graph1D_jd(time,dat(j,:),0,0,'','','',NaN,NaN,NaN,'-',markers{j},colors{j},2,style,ax);
        end
        [ax] = graph1D_jd(time,dat(ntr(plt),:),0,0,'t (s)','','',legstr,0,0,'-',markers{ntr(plt)},colors{ntr(plt)},2,style,ax);   
    end
end

% end of function

end

