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
function ripple = imake_ripple_yp(dkepath,basestr,equil,external,workdir,opt_gui)
%
% This function interactively builds the ripple structure
%
ripple = '';
%
mode = input('Magnetic ripple calculation. Yes: 1, No: 0, [0] : ');
if isempty(mode),
    mode = 0;
end
if mode > 1,mode = 1;end
%
ripple.mode = mode;
%
id_ripple_i = 'TScylmodel';
id_ripple = input(['Please specify a name for the ''ripple'' structure : [',id_ripple_i,'] : '],'s');
if isempty(id_ripple),
    id_ripple = id_ripple_i;
end
ripple.id = id_ripple;
%





