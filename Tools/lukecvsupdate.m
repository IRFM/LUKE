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
function lukecvsupdate(dkepath,debugmode,link_mode)
%
% This function updates LUKE and associated toolboxes remotely for the profiles stored
% in dkepath
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%       - debugmode
%       - link_mode : connection mode prescription
%           o -2  : disable remote profiles
%           o -1  : local profiles only
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%
if nargin < 3,
    link_mode = NaN;
end
if nargin < 2,
    debugmode = 0;  
end
if nargin < 1,
    dkepath = '';
end
%
if isempty(dkepath)
    dkepath = setpath_luke_jd(dkepath,link_mode);
end
%
nrem = length(dkepath.remote);
%
disp (' ')
info_dke_yp(2,'List of remote profiles tagged for cvs update :')
disp(' ')
%
flag_cvsupdate = false(1,nrem);
%
for irem = 1:nrem,
    if isfield(dkepath.remote(irem),'cvsupdate') && ~isempty(dkepath.remote(irem).cvsupdate) && dkepath.remote(irem).cvsupdate,
        flag_cvsupdate(irem) = true;
    end
end
remote_index = find(flag_cvsupdate);
nrem = length(remote_index);
%
for irem = 1:nrem,
    info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{remote_index(irem)},' for LUKE root : ',dkepath.remote(remote_index(irem)).env.luke_root]);
end
disp(' ')
%  
remlist = input_dke_yp('Please identify profiles to be updated',1:nrem,[1;nrem]);
disp(' ')
%
remote = dkepath.remote(remote_index(remlist));
nrem = length(remote);
%
for irem = 1:nrem,
    remote(irem).debugmode = debugmode;
end
%
% ----------------------------
%
remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m','make_help.m','luke_root'};% update MatTools, MatRemote, MatHelp and LUKE
%
display_mode = 3;% show detailed results
%
exclude = {'.mat','~','.mexa64','.mexglx','.mexmaci64','.o','.DS_Store'};
%
flag = remotecvsupdate(remote,remotefunctions,display_mode,exclude);
%
disp('--------------------------------------')
disp('           GLOBAL RESULTS             ')
disp('--------------------------------------')
disp(' ')
disp('  -2 : the remote process failed')
disp('  -1 : the cvs update process failed')
disp('   0 : the cvs update succeeded without remote conflicts or remote modified files')
disp('   1 : the cvs update succeeded without remote conflicts and with remote modified files')
disp('   2 : the cvs update succeeded with remote conflicts')
disp(' ')
disp(' Results for : MatTools / MatRemote / MatHelp / LUKE ')
disp(' ')
disp('--------------------------------------')
disp(' ')
disp(' ')
disp(' ')
%
flag1 = num2str(flag(:,1));
flag2 = num2str(flag(:,2));
flag3 = num2str(flag(:,3));
flag4 = num2str(flag(:,4));
%
for irem = 1:nrem,
    disp([flag1(irem,:),' / ',flag2(irem,:),' / ',flag3(irem,:),' / ',flag4(irem,:),' : ',dkepath.profilestr{remote_index(remlist(irem))}])
end
%