function userid = userid_jd
%
% This function determines and returns the user id
%
if strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86'),%unix system
    [flag,str] = unix('echo $USER');
elseif strcmp(computer,'PCWIN'),%windows system
    [flag,str] = dos('hostname');
elseif strcmp(computer,'MAC'),%MAC system
    [flag,str] = dos('hostname');
end
userid = strtrim(str);
%