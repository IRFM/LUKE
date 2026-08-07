% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function plot_spectrum_from_launch_jd(launch,xlim,p_opt,select)
%
if nargin < 4,
    select = struct;
end
%
if nargin < 3,
    p_opt = -1;
end
%
if nargin < 2,
    xlim = NaN;
end
%
if isfield(select,'style'),
    style = select.style;
else
    style = struct;
end
%
if isfield(launch,'yrho0'),%
    yN = launch.yNpar0;
    ydN = launch.ydNpar0;
    yP = launch.yP0_2piRp*2*pi*launch.Rp/1e6;
    %
    if isfield(launch,'launch'),%
        yN0 = launch.launch.bNpar0;
        ydN0 = launch.launch.bdNpar0;
        yP0 = launch.launch.bPlhtot/1e6;
    else
        yN0 = NaN;
        ydN0 = NaN;
        yP0 = NaN;
    end
    %
else
    yN = launch.bNpar0;
    ydN = launch.bdNpar0;
    yP = launch.bPlhtot/1e6;
end
%
ny = length(yN);
%
dx = min(ydN)/10;
x = (min(yN) - 4*max(ydN)):dx:(max(yN) + 4*max(ydN));
nx = length(x);
%
xyN = repmat(yN,[nx,1]);
xyP = repmat(yP,[nx,1]);
xydN = repmat(ydN,[nx,1]);
xy = repmat(x.',[1,ny]);
%
xyf = xyP.*exp(-(xy - xyN).^2./xydN.^2)./sqrt(pi)./xydN;
xf = sum(xyf,2);
%
if isfield(launch,'yrho0'),%
    ny0 = length(yN0);
    %
    dx0 = min(ydN0)/10;
    x0 = (min(yN0) - 4*max(ydN0)):dx:(max(yN0) + 4*max(ydN0));
    nx0 = length(x0);
    %
    xyN0 = repmat(yN0,[nx0,1]);
    xyP0 = repmat(yP0,[nx0,1]);
    xydN0 = repmat(ydN0,[nx0,1]);
    xy0 = repmat(x0.',[1,ny0]);
    %
    xyf0 = xyP0.*exp(-(xy0 - xyN0).^2./xydN0.^2)./sqrt(pi)./xydN0;
    xf0 = sum(xyf0,2);    
end
%
if isfield(select,'axs'),
    ax = select.axs(1);
    set(ax,'Visible','on');
    red = 1;
    lspace = NaN;
    bspace = NaN;
else
    if isfield(launch,'yrho0'),%
        fig1 = figure('Name','Tail power spectrum');
    else
        fig1 = figure('Name','Gaussian fit vs. ALOHA');
    end
    ax = gca;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.5;
end
%
if isfield(launch,'launch') && isfield(launch.launch,'aloha')
    %
    if isfield(launch.launch.aloha,'optim')
        %
        launch.id = launch.launch.aloha(1).optim.id;
        %
    else
        %
        launch.id = [launch.launch.aloha(1).options.TSport,'_',launch.launch.aloha(1).antenna.architecture];
        %
    end
    %
else
    %
    launch.id = 'Launching power spectrum';
    %
end    
%
if isfield(launch,'yrho0'),%
    graph1D_jd(x0,xf0,0,0,'n_{||}','dP/dn_{||} (MW)',strrep(launch.id,'_','-'),NaN,xlim,NaN,'-','none','b',2,style,ax,red,lspace,bspace);
	graph1D_jd(x,xf,0,0,'n_{||}','dP/dn_{||} (MW)',strrep(launch.id,'_','-'),NaN,xlim,NaN,'-','none','r',2,style,ax,red,lspace,bspace);
    legend(['Initial spectrum, P_{LH} = ',num2str(sum(yP0)),' (MW)'],['Tail spectrum, P_{LH} = ',num2str(sum(yP)),' (MW)'])
else
    graph1D_jd(x,xf,0,0,'n_{||}','dP/dn_{||} (MW)',strrep(launch.id,'_','-'),NaN,xlim,NaN,'-','none','r',2,style,ax,red,lspace,bspace);
    legend(['Initial spectrum, P_{LH} = ',num2str(sum(yP)),' (MW)'])
end
graph1D_jd([0,0],get(gca,'ylim'),0,0,'','','',NaN,xlim,NaN,'-','none','k',2,style,ax);
set(gca,'xtick',[-16:2:16])
%
print_jd(p_opt,['Fig_',launch.id,'_spectrum'],NaN,1);
