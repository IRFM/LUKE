function [s,w] = execute_jd(filename)
	
if strcmp(computer,'PCWIN')
	[s,w] = dos(filename);
elseif strcmp(computer,'MAC2')
	eval(['! ',filename]);
end
