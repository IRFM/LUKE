function [flag,tmdce,texe,test] = run_mdce(scheduler,modes,tpause,nX,datamode,Nmax,N,display_mode)
%
% Script for testing the distributed calculations within MatLab (using the distributed MatLab toolbox)
%
% INPUTS : 
%       - scheduler : override scheduler properties (type,enforce,display,...) [struct]
%       - modes : list of mdce modes to test (0) : sequential, (1) mdce jobs, (2) dcluke, (3) mdce parfor [1,nmodes] 
%       - tpause : pause time in function (s) [1,1]
%       - mode : data transert mode : 0 (back and forth); (1) forth; (-1) back [1,1]
%       - nX : size of transfer matrix (related memory = 8*nX^2 Bytes) [1,1]
%       - datamode = 0 : data transert mode : 0 (back and forth); (1) forth; (-1) back [1,1]
%       - Nmax : maximum cluster size [1,1]
%       - N : number of iterations [1,1]
%       - display_mode : (0) no figure display, (1) figure display [1,1]
%
% OUTPUTS : 
%       - flag : list of output flags {nmodes,N}[1,n]
%       - tmdce : total MDCE calculation time [nmodes,N]
%       - texe : Internatal execution calculation time {nmodes,N}[1,n]
%       - test : test for correct outputs [nmodes,N]
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 1,
    scheduler.type = 'local';%'local','pbspro','xgrid',...
    scheduler.enforce = 0;% 1 to enforce sequential calculation if mdce problem
    scheduler.display = 1;
end   
if nargin < 2,
    modes = 0:3; 
end   
if nargin < 3,
    tpause = 10;
end   
if nargin < 4,
    nX = 100;
end   
if nargin < 5,
    datamode = 0;
end   
if nargin < 6,
    Nmax = Inf;
end
if nargin < 7,
    N = 16;
end   
if nargin < 8,
    display_mode = 2;% (0) no figure display, (1) figure display
end 
%
if ~isstruct(scheduler),
    %
    scheduler.type = scheduler;
    scheduler.enforce = 0;% 1 to enforce sequential calculation if mdce problem
    scheduler.display = 1;
    %
end
%
if ~isfield(scheduler,'memory'),
    scheduler.memory = 500 + round(8*nX^2/1e6);
end
%
dkepath = load_structures_yp('dkepath','','');
%
modestrs = {'SEQUENTIAL','MDCE JOBS','DCLUKE','MDCE PARFOR'};
colors = {'k','b','r','g'};
markers = {'o','+','s','d'};
%
nmodes = length(modes);
%
tmdce = NaN*ones(nmodes,N);
test = NaN*ones(nmodes,N);
flag = cell(nmodes,N);
texe = cell(nmodes,N);
%
X_in = cell(1,N);
for j = 1:N,
    if datamode >= 0,%data transfered forth
        X_in{j} = rand(nX);
    else
        X_in{j} = nX;
    end
end
%
for n=[1,1:N],% case 1 calculated twice to avoid preallocation time delays
    %
    for imode = 1:nmodes,
        %
        mode = modes(imode);
        modeindex = mode+1;
        modestr = modestrs{modeindex};
        %
        scheduler.mode = mode;
        scheduler.clustersize = min(n,Nmax);
        %
        [flag{imode,n},tmdce(imode,n),texe{imode,n},test(imode,n)] = nloop_mdce(modestr,dkepath,scheduler,X_in(1:n),tpause,datamode);
        %
    end
end
%
if display_mode > 0,
    %
    figure(1),clf,set(1,'Name','Calculation time (s)')
    %
    % display total mdce time
    %
    leg = cell(1,nmodes);
    %
    for imode = 1:nmodes,
        %
        mode = modes(imode);
        modeindex = mode+1;
        mask = find(test(imode,:));
        leg{imode} = modestrs{modeindex};
        %
        if imode < nmodes,
            graph1D_jd(mask,tmdce(imode,mask),0,0,'','','',NaN,[0,N+1],NaN,'-',markers{modeindex},colors{modeindex},2,20+14i,gca);
        else
            leg = [leg,'Location','NorthWest'];
            graph1D_jd(mask,tmdce(imode,mask),0,0,'N processors','time (s)','Distributed computing calculations',leg,[0,N+1],NaN,'-',markers{modeindex},colors{modeindex},2,20+14i,gca,0.9,0.7,0.5);
        end
        %
    end
    %
    % display execution time
    %
    for imode = 1:nmodes,
        %
        mode = modes(imode);
        modeindex = mode+1;
        mask = find(test(imode,:));
        %
        texemax = NaN(1,N);
        for n=mask,
            texemax(n) = max(texe{imode,n});
        end
        %
        graph1D_jd(mask,texemax(mask),0,0,'','','',NaN,[0,N+1],NaN,'--','none',colors{modeindex},0.5,20+14i,gca);
        %
        print_jd(display_mode,'mdce_evaluation','./figures',1)
    end
end
end
%
function [flag,tmdce,texe,test] = nloop_mdce(modestr,dkepath,scheduler,X_in,tpause,datamode)
    %
    [dkecluster] = clustermode_luke(scheduler,'',dkepath,scheduler.type);%All cluster parameters and paths
    %
    dkecluster.scheduler.clustersize = length(X_in);
    %
    tinit = tic;
    [flag,X_out,texe] = mdce_luke(@frun_mdce,{tpause,datamode,''},3,X_in,dkecluster);
    tmdce = toc(tinit);
    texe = cell2mat(texe.');
    %
    if ~all(flag == scheduler.mode),
        disp('   --> WARNING: Distributed calculation problem occured.');
        disp(['   --> flag : ',num2str(flag)]);
    end        
    %
    if datamode == 0,% back and forth, test result
        test = comp_struct_jd(X_in,X_out.',0);
        if test == 1,
            disp('   --> Outputs and Inputs are identical');
        else
            disp('   --> WARNING: Outputs are different from inputs. Verify workflow.');
        end
    else
        test = 1;
    end
    %
    disp(['   --> time for n = ',int2str(length(X_in)),' ',modestr,' calculations on ',int2str(dkecluster.scheduler.clustersize),' proc. : ',num2str(tmdce),' s'])
    disp(['   --> Execution time for frun_mdce : min ',num2str(min(texe)),'; max ',num2str(max(texe)),'; mean ',num2str(mean(texe)),' s'])
    disp('-------------------------------------------------------------------------')
	%
end
