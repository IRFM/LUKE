function userid = userid_jd
%
% This function determines and returns the user id
%
str = '';
%
if strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86'),%unix system
    [flag,str] = unix('echo $USER');
elseif strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'),%windows system
    [flag,str] = dos('hostname');
elseif strcmp(computer,'MAC') || strcmp(computer,'MACI') || strcmp(computer,'MACI64'),%MAC system
    [flag,str] = dos('hostname');
end
%
userid = strtrim(str);
%