function test_make_struct_jd
%
% Test script for function make_struct_jd
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y.Peysson (CEA-IRFM) <yves.peysson@cea.fr>
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


