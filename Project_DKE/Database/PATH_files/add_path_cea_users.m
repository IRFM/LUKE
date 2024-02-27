function dkepath = add_path_cea_users(dkepath,zone)
%
% add external users to CEA PARTENAIRES or INTRA zones for LUKE path
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if strcmp(zone,'INTRA')
    %
    root_folder = '/Home/';
    %
elseif strcmp(zone,'PARTENAIRES')
    %
    root_folder = '/home/';
    %
else
    %
    disp(['This CEA zone : ',zone,' is unknown.'])
    return;
    %
end
%
%Jean-François Artaud, Marc Goniche, Jorge Morales, Tullio Barbui, Krzysiek
%Krol, Riccardo Saura, Patrick Maget, Samuele Mazzi, Pierre Manas, Théo
%Fonghetti, Mathieu Carole
%
users = ['JA132999';'MG270985';'JM240179';'TB263881';'KK019865';'RS272879';'PM156629';'SM253778';'PM258588';'TF267414';'MC263498','JC249570'];
%
for ii = 1:length(users)
    %
    dkepath.(users(ii,:))(1) = dkepath.YP105119(1);
    dkepath.(users(ii,:))(1).luke_root = [root_folder,users(ii,:),'/luke/LUKE_LHCD/'];
    %
    for jj = 1:length(dkepath.YP105119(1).remote)
        %
        dkepath.(users(ii,:))(1).remote(jj).luke_root = dkepath.(users(ii,:))(1).luke_root;
        dkepath.(users(ii,:))(1).remote(jj).profilename = users(ii,:);
        %
    end
    %
end
%