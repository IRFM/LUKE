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
function varargout = F_help_antenna(key)
%   F_help_antenna()
%   help = F_help_antenna(key)
%
%plot help for antenna substruct or find help for specific field of antenna
%expressed by key

tp.type     = "LH' lower hybrid wave or 'EC' electron cyclotron waves, or {'LH','EC'} if both waves are launched";
tp.comment  = "Comments on the antenna structure calculation";
tp.source   = "Source of the waves, 'file', 'code'";
tp.code     = "Code name, needed if source is 'code'";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "File path, needed if source is 'file'";
tp.LH       = {"Specification on launched LH",@F_help_LH};
tp.EC       = {"Specifivation on launched EC",@F_help_EC}; 

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end