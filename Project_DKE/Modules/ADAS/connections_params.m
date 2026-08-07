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
function [ip,id,code] = connections_params(code,user,address)
%
% Simple connection tool to be customized for remote or local GAUSSIAN 
% or GRASP calculations. Default ssh port 22 is assumed to be used. 
%
% INPUT :
%       - code : 'GAUSSIAN' or 'GRASP2018'
%           (default : 'GAUSSIAN')
%       - user : user name. If user argument, default local calculations with session id
%       - address : If empty, local calculations, otherwise address of the machine on calculations are performed
% 
% OUTPUT :
%
%       - id : user id (or session id if default value)
%       - ip : ip address (or from hostname if default value)
%       - code : code name
%
% By Y. Savoye-Peysson CEA-IRFM <yves.savoye-peysson@cea.fr>
%
[~,hostname] = unix('hostname');
[~,whoami] = unix('whoami');
%
if nargin == 0
    %
    code = 'GAUSSIAN';
    %
    ip = {deblank(hostname)};
    id = {deblank(whoami)};
    %
else
    %
    if isempty(code) || (strcmp(code,'GAUSSIAN') == 0 && strcmp(code,'GRASP2018') == 0)
        %
        code = 'GAUSSIAN';
        %
    end
    %
    if nargin > 1
        %
        if isempty(user) 
            %
            id = {deblank(whoami)};
            %
        else
            %
            id = user; 
            %
        end
        %
    else
        %
        id = {deblank(whoami)};     
        %
    end
    %
    if nargin > 2
        %
        if isempty(address) 
            %
            ip = {deblank(hostname)};
            %
        else
            %
            ip = {address};
            %
        end
    else
        %
        ip = {deblank(hostname)};
        %
    end
    %
end
%