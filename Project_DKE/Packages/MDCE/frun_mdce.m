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
function [X,texe] = frun_mdce(tpause,mode,X)
%
% function for run_mdce:
%
% INPUTS : 
%       - tpause : pause time (s)
%       - mode : data transert mode : 0 (back and forth); (1) forth; (-1) back
%       - X : input matrix
%
% OUTPUTS : 
%       - X : output matrix
%       - toc : execution time
%
tic
%
pause(tpause);
%
if mode == 1,
    X = [];
elseif mode == -1,
    X = rand(X);
end
%
texe = toc;