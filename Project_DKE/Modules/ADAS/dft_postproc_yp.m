function dft = dft_postproc_yp(Z_in,enforce,display,print_opt)
%
% DFT calculation post-processing. Reorganize the structure to make fields
% clear, and add necessary coefficients for further calculations (Fokker-Planck or bremsstrahlung)
%
%   INPUTS:
%
%       - Z_in : atomic charge of the considered element
%       - enforce : (0) no enforcement (1) all calculations are enforced
%       - display : display mode
%       - print_opt :  (opt = 0) and (opt = 1) / or (opt = 2, default) saves to file the current figure under the name savename 
%
%   OUTPUTS:
%
%       - dft : updated dft structure 
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, Krzysztof Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin < 1
    %
    error('Error : wrong number of input arguments in dft_postproc_yp.m');
    %
end
%
if nargin < 2
    %
    enforce = 0; 
    display = 1; %no display
    print_opt = -1; %no saving/printing
    %
end
%
if nargin < 3
    %
    display = 0; %no display
    print_opt = -1; %no saving/printing
    %
end
%
if nargin < 4
    %
    print_opt = -1; %no saving/printing
    %
end
%
if display > 0
    %
    close all
    %
end
%
symbol = elements('atomic_number',Z_in, 'symbol');
name = elements('atomic_number',Z_in, 'name');
%
filename = ['DFT/dft_',int2str(Z_in),'_',symbol,'_',name];
filename1 = ['dft_',int2str(Z_in),'_',symbol,'_',name,'_*'];
%
if exist([filename,'.mat'],'file') % already processed data
    %
    load([filename,'.mat'],'dft');
    %
    if exist('dft','var')
        %
        unix(['cp ',filename,'.mat ' filename,'_old.mat ']);
        %
    end
    %
elseif isstruct(dir(fullfile('', filename1))) % for raw Gaussian data
    %
    temp = dir(fullfile('', filename1));
    load([temp.folder,filesep,temp.name],'dft');
    %
end
%
if ~isfield(dft,'name')
    %
    dft.name = name;
    %
end
%
if ~isfield(dft,'symbol')
    %
    dft.symbol = symbol;
    %
end
%
if ~isfield(dft,'r')
    %
    dft.dft_data = dft.ne;% store raw DFT output
    %
    dft.r = dft.ne(:,2);% radius [a0]
    dft.ne = dft.ne(:,3:end);% electron density [a0-3]
    %
    dft.N = dft.Z-dft.Z0;%number of bound electrons
    %
end
%
if ~isfield(dft,'I1') || enforce == 1
    %
    nZ0 = length(dft.Z0);
    nM = length(dft.M);
    nne = size(dft.ne,2);
    %
    if nZ0 ~= nM || nZ0 ~= nne || nM ~= nne
        error('Error :  dft structure is not consistent.')
    end
    %
    [~,~,~,~,~,~,~,~,~,alpha,~,~] = pc_dke_yp;%Universal physics constants
    %
    if enforce == 1
        %
        dft = rmfield(dft,'q');
        dft = rmfield(dft,'ff_DFT');
        %

    end
    %
    for i = 1:length(dft.Z0)
        %
        N_dft = 4*pi*simps(dft.r,dft.ne(:,i).*dft.r.*dft.r);
        N_exact = dft.N(i);
        %
        dft.ne(:,i) = dft.ne(:,i)*N_exact/N_dft; %normalization to exact N value   
        %
        [~,out] = dft_integrals_yp(dft.r,dft.ne(:,i),dft.Z,dft.N(i),dft.Z0(i));
        %
        dft.I1(i) = out.I1;
        dft.I2(i) = out.I2;
        %
        dft.a_TF_DFT(i) = out.a_TF_DFT;%Thomas-Fermi-Kirillov (from Hesslow integrals)
        dft.a_TP_DFT(i) = out.a_TP_DFT;%Tseng-Pratt-Botto (from Hesslow integrals)
        %
        [q,ff_DFT] = formfactornum_yp(dft.r,dft.ne(:,i));%exact form factor
        %
        ff_DFT = ff_DFT*N_exact/max(ff_DFT);% normalization to the total charge
        %
        dft.q = q;
        dft.ff_DFT(:,i) = ff_DFT(:);
        %
        fun_ff_TF = @(a,q) formfactor_yp(a,q,dft.Z-dft.Z0(i),3/2);%a is the free parameter
        fun_ff_TP = @(a,q) formfactor_yp(a,q,dft.Z-dft.Z0(i),2);%a is the free parameter
        %
        norm_ff_TF = @(a) norm(ff_DFT(:) - fun_ff_TF(a,q));% Thomas-Fermi-Kirillov
        norm_ff_TP = @(a) norm(ff_DFT(:) - fun_ff_TP(a,q));% Tseng-Pratt
        %
        dft.a_optim_TF(i) = fminsearch(norm_ff_TF, dft.a_TF_DFT(i));
        dft.a_optim_TP(i) = fminsearch(norm_ff_TP, dft.a_TP_DFT(i));
        %
        ff_optim_TF = fun_ff_TF(dft.a_optim_TF(i),q);
        ff_optim_TP = fun_ff_TP(dft.a_optim_TP(i),q);
        %
        dft.chi2_optim_TF(i) = sum((ff_optim_TF(:) - ff_DFT(:)).^2)/length(q)./(dft.N(i))^2; 
        dft.chi2_optim_TP(i) = sum((ff_optim_TP(:) - ff_DFT(:)).^2)/length(q)./(dft.N(i))^2; 
        %
        if display == 2
            figure('Name',['Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i))]),
            semilogx(dft.q,ff_DFT,'r-',q,ff_optim_TF,'b--',q,ff_optim_TP,'g--');
            xlabel('q'),ylabel('form factor'),
            title(['Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i))]);
            legend('Exact DFT',['Best fit Thomas-Fermi-Kirillov model, \chi^2/N_q/N_Z^2 = ',num2str(dft.chi2_optim_TF(i))],['Best fit Tseng-Pratt model,  \chi^2/N_q/N_Z^2 = ',num2str(dft.chi2_optim_TP(i))]);
            grid on
            drawnow
        end
        %
        disp(['Fit for Z0 = ',int2str(dft.Z0(i)),' done.']);
        %
    end
    %
end
%
if ~isfield(dft,'I_meanexcitationenergy') || enforce == 1
    %
    [dft.I_meanexcitationenergy,dft.I_meanexcitationenergy_s] = meanexcitationenergy_yp(dft.Z);% Mean ion excitation energy for inelastic scattering
    %
end    
%
if ~isfield(dft,'models') || enforce == 1
    %
    dft.models = {'Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'};
    %
    for imodel = 1:length(dft.models)
        %
        ionradius = ionradius_yp(dft.Z,dft.models{imodel});
        dft.ionradius{imodel} = ionradius;
        %
    end
end
%
save(['DFT/dft_',int2str(dft.Z),'_',dft.symbol,'_',dft.name,'.mat'],'dft');
disp(['Updated dft structure saved in ','DFT/dft_',int2str(dft.Z),'_',dft.symbol,'_',dft.name,'.mat'])
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
linestyle(6) = {'--'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
linecolor(6) = {'k'};
%
marker(1) = {'o'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
siz = 20+14i;
%
xlab = 'Z_0';
ylab = '\chi^2/N_q/N_Z^2';
tit = ['Fit accuracy of the exact DFT form factor for Z = ',int2str(dft.Z)];
leg = {};
%
figure('Name',['chi2, Z = ',int2str(dft.Z)]);
%
leg = [leg,'Thomas-Fermi'];
graph1D_jd(dft.Z0,dft.chi2_optim_TF,0,1,xlab,ylab,tit,leg,'','','none',marker{1},linecolor{1},2,siz,gca); 
leg = [leg,'Tseng-Pratt'];
graph1D_jd(dft.Z0,dft.chi2_optim_TP,0,1,xlab,ylab,tit,leg,'','','none',marker{2},linecolor{2},2,siz,gca); 
%
drawnow
%
print_jd(print_opt,['fit_chi2_',int2str(dft.Z)],'./Figs',get(gcf,'Number'))
%
xlab = 'Z_0';
ylab = '2*a/\alpha [a_0]';
tit = ['Normalized ion radius (DFT, Thomas-Fermi) for Z = ',int2str(dft.Z)];
leg = {};
%
figure('Name',['Normalized ion radius (DFT, Thomas-Fermi) for Z = ',int2str(dft.Z)]);
%
leg = [leg,'DFT-TF (Hesslow integrals, Thomas-Fermi-Kirillov form factor)'];
graph1D_jd(dft.Z0,dft.a_TF_DFT,0,0,xlab,ylab,tit,leg,'','','none',marker{1},linecolor{1},2,siz,gca); 
leg = [leg,'DHFS fit (Thomas-Fermi-Kirillov form factor)'];
graph1D_jd(dft.Z0,dft.a_optim_TF,0,0,xlab,ylab,tit,leg,'','',linestyle{1},'none',linecolor{1},2,siz,gca); 
iref = find(ismember(dft.models,{'Thomas-Fermi-Kirillov'})==1);
leg = [leg,'Thomas-Fermi-Kirillov'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','','none',marker{2},linecolor{2},2,siz,gca); 
iref = find(ismember(dft.models,{'Thomas-Fermi'})==1);
leg = [leg,'Thomas-Fermi'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%
figure('Name',['Normalized ion radius (DFT, Tseng-Pratt) for Z = ',int2str(dft.Z)]);
%
leg = {};
tit = ['Normalized ion radius (DFT, Tseng-Pratt) for Z = ',int2str(dft.Z)];
%
leg = [leg,'DFT-TP (Hesslow integrals, Tseng-Pratt form factor)'];
graph1D_jd(dft.Z0,dft.a_TP_DFT,0,0,xlab,ylab,tit,leg,'','','none',marker{1},linecolor{1},2,siz,gca); 
leg = [leg,'DHFS fit (Tseng-Pratt form factor)'];
graph1D_jd(dft.Z0,dft.a_optim_TP,0,0,xlab,ylab,tit,leg,'','',linestyle{1},'none',linecolor{1},2,siz,gca); 
iref = find(ismember(dft.models,{'Tseng-Pratt-Botto'})==1);
leg = [leg,'Tseng-Pratt-Botto'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','','none',marker{2},linecolor{2},2,siz,gca); 
iref = find(ismember(dft.models,{'Tseng-Pratt-Thomas-Fermi'})==1);
leg = [leg,'Tseng-Pratt-Thomas-Fermi'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%
drawnow
%
print_jd(print_opt,['ion_radius_',int2str(dft.Z)],'./Figs',get(gcf,'Number'))
%
if isfield(dft,'dft_data')
    %
    figure('Name',['DFT electron density, Z = ',int2str(dft.Z)]);
    %
    xlab = 'r [a_0]';
    ylab = 'n_e [a_0^{-3}]';
    tit = ['DFT electron density, Z = ',int2str(dft.Z)];
    %
    graph1D_jd(dft.r,dft.ne,0,1,xlab,ylab,tit,NaN,[0,max(dft.r)],[1e-4,1e4],linestyle{1},'none',linecolor{1},2,siz,gca); 
    %
    drawnow
    %
    print_jd(print_opt,['ion_radius_',int2str(dft.Z)],'./Figs',get(gcf,'Number'))
    %
end




