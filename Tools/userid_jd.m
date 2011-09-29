function userid = userid_jd
%
% This function determines and returns the user id
%
str = '';
%
if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'), % Windows systems
    [flag,str] = dos('hostname');
	userid = strtrim(str);
else % UNIX based systems
    userid = getenv('USER');
end
