function [ output_args ] = luke_disp_ohms_mt( equils, ohms, ax, style )
%LUKE_DISP_OHMS_MT [ output_args ] = luke_disp_ohms_mt( equils, ohms, ax )
%   plots the ohms information for multi times
%
% INPUT:
%   equils .... cell with equilibrium structures from LUKE (multi times)
%   ohms ...... cell with ohm structures from LUKE (multi times)
%   ax ........ axis handle of axis where the plot should be done.
%               default: open a new figure
%   style ..... plot style parameters for iluke integration (optional) 
%
% OUTPUT:
%   none
%
% PLOT KIND
%   time evolution of Vloop in the center and the edge
%
%
%   J. Kamleitner, CRPP, EPFL, Feb 2014

% dependencies:
% gti_plot_symcol.m

if(nargin<3 || isempty(ax))
    figure;
    ax=gca();
end

% init plt parameters
ntr=2;
% reference values and units
Vloopunit='V';
Vloopref=1;
sVloopref=sprintf('%s',Vloopunit);


% create basic traces and profiles
nohm=numel(ohms);
% nrho=numel(equils{1}.psi_apRp);
time=zeros(1,nohm);
dat=zeros(ntr,nohm);
for i=1:nohm
    time(i)=equils{i}.shotime;
    % data
    dat(:,i)=ohms{i}.epsi([1 end])*2*pi*equils{i}.Rp/Vloopref;
end
% legend
legstr={sprintf('V_{loop,0}/%s',sVloopref),sprintf('V_{loop,edge}/%s',sVloopref)};

% do the plotting
if nargin < 4 || isempty(style),
    for j=1:ntr
        plot(ax,time,dat(j,:),gti_plot_symcol('sym',j,ntr),'Color',gti_plot_symcol('col',j,ntr));
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
    for j=1:ntr-1
        [ax] = graph1D_jd(time,dat(j,:),0,0,'','','',NaN,NaN,NaN,'-',markers{j},colors{j},2,style,ax);
    end
    [ax] = graph1D_jd(time,dat(ntr,:),0,0,'t (s)','','',legstr,0,0,'-',markers{ntr},colors{ntr},2,style,ax);   
end

% end of function

end

