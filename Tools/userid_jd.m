function userid = userid_jd
%
% This function determines and returns the user id
%
userid = '';
%
if strcmp(computer,'GLNXA64'),%unix system
    userid = getenv('USER');
elseif strcmp(computer,'PCWIN'),%windows system
    [flag,str] = dos('hostname');
    is_blanck = find(double(str(1:end-1)) == 10);
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
elseif strcmp(computer,'MAC'),%MAC system
    [flag,str] = dos('hostname');
    is_blanck = find(double(str(1:end-1)) == 10);
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
end
%
userid(userid == 10) = '';
%