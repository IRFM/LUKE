function execute_jd(filename)
	
if strcmp(computer,'PCWIN')
	dos(filename);
elseif strcmp(computer,'MAC') 
	eval(['! ',filename]);
else 
	eval(['! ./',filename]);
end
