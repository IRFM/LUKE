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
function [id] = sluke_id(sparams,ii)
%
id_root = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),'_',num2str(sparams.discharge.tmax{ii}),'_',num2str(sparams.discharge.nt{ii})];
%
if isfield(sparams.simul,'id') && ~isempty(sparams.simul.id)
    %
    id = [id_root,'_',sparams.simul.id{ii},'_'];
    %
else
    %
    id = [id_root,'_'];
    %    
end
%
id = strrep(id,' ','_');
id = strrep(id,',','_');
id = strrep(id,';','_');
%
if isfield(sparams.simul,'signature') && ~isempty(sparams.simul.signature{ii})
    %
    signature_mod = strrep(sparams.simul.signature{ii},' ','');%remove space
    signature_mod = strrep(signature_mod,'-','');%remove - character
    signature_mod = strrep(signature_mod,'_','');%remove _ character
    %
    for count = 1:length(signature_mod)
        %
        if upper(signature_mod(count)) == signature_mod(count)
            %
            isupper(count) = 1;
            %
        else
            %
            isupper(count) = 0;
            %
        end
        %
    end
    %
    signature = signature_mod(find(isupper==1));
    %
    if strcmp(id(end),'_')
        %
        id = [id,signature];
        %
    else
        %
        id = [id,'_',signature];
        %
    end
end
%
if strcmp(id(end),'_')
    %
    id = [id,'#',int2str(ii)];
    %
else
    %
    id = [id,'_#',int2str(ii)];
    %
end
