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
function test_make_struct_jd
%
% Test script for function make_struct_jd
%
display_mode = 1;
c = 2;
d = 1;
%
disp('test of the function make_struct_jd');
disp(' ');
%
[a,b] = testfun(c,d);
%
disp(['Direct calculation : a = ',num2str(a),'; b = ',num2str(b)]);
disp(' ');
%
loadstruct = '';
[a,b] = make_struct_jd(loadstruct,display_mode,'testfun',c,d);
disp(['Empty loadstruct : a = ',num2str(a),'; b = ',num2str(b)]);
%
loadstruct.testfun = '';
[a,b] = make_struct_jd(loadstruct,display_mode,'testfun',c,d);
disp(['Empty loadstruct.testfun : a = ',num2str(a),'; b = ',num2str(b)]);
%
loadstruct.testfun.a = a;
loadstruct.testfun.b = b;
[a,b] = make_struct_jd(loadstruct,display_mode,'testfun',c,d);
disp(['Filled loadstruct.testfun : a = ',num2str(a),'; b = ',num2str(b)]);
%
end
%


