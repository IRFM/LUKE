function userid = userid_jd
%
% This function determines and returns the user id
%
userid = '';
%
if strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86'),%unix system
    [dummy,str] = unix('echo $user');
    is_blanck = find(double(str(1:end-1)) == 10);
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
elseif strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'),%windows system
    [dummy,str] = dos('hostname');
    is_blanck = find(double(str(1:end-1)) == 10);
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
elseif strcmp(computer,'MAC') || strcmp(computer,'MACI') || strcmp(computer,'MACI64'),%MAC system
    [dummy,str] = dos('hostname');
    is_blanck = find(double(str(1:end-1)) == 10);
    ismin = max([1,is_blanck + 1]);
    userid = str(ismin:end);
end
%
userid(userid == 10) = '';