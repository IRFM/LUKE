function comp_hxr_jd(hxr_path,filename,p_opt,n1,n2)
%
if nargin < 5,
    n1 = 3;
    n2 = 3;
end
if nargin < 3,
    p_opt = -1;
end
%
%load([hxr_path,'HXR_RESULTS_',id,'.mat'],'Zbremdiag','hxrexp');
%
if strfind(filename,'HXR_RESULTS'),
    id = filename(13:strfind(filename,'.mat')-1);
    load([hxr_path,filename],'Zbremdiag','hxrexp');
    %
    kfit = Zbremdiag.kfit;
    brem_bd_diag = Zbremdiag.brem_bd_diag;
    %
elseif strfind(filename,'PROC_LUKE'),
    id = filename(19:strfind(filename,'.mat')-1);
    load([hxr_path,filename],'data_proc');
    %
    kfit = data_proc.hxr.kfit;
    brem_bd_diag = data_proc.hxr.brem_bd_diag;
    hxrexp = data_proc.hxr.hxrexp.';
    %
end
%
nc = size(brem_bd_diag,1);
leg = {'sim.','exp.'};
%
figure(1), clf
%
siz = 14+10*1i;
%
for ik = 1:length(kfit),
    %
    %figure(ik), clf
    subplot(n1,n2,ik)
    %
    graph1D_jd(1:nc,brem_bd_diag(:,ik),0,0,'Chord number','dN_{pulse}/dt [s^{-1}]',['Pulse count rate, E=',num2str(kfit(ik)),' keV'],NaN,'','','-','none','b',2,siz,gca,0.9);
    graph1D_jd(1:nc,hxrexp(ik,1:nc),0,0,'','','',leg,'','','-','none','r',2,siz);
    %
    %keyboard
    %
end
%
print_jd(p_opt,['Fig_hxrcomp_',id],[hxr_path,'figures'],1);
%
            