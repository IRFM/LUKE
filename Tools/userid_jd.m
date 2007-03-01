function userid = userid_jd;
%
% This function determines and returns the user id
%
userid = '';
%
if strcmp(computer,'GLNXA64'),%unix system
    [flag,str] = unix('echo $user');
    is_blanck = find(str == ' ');
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
elseif strcmp(computer,'PCWIN'),%windows system
    [flag,str] = dos('hostname');
    is_blanck = find(str == ' ');
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
end