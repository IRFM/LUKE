function execute_jd(filename)
	
if strcmp(computer,'PCWIN')
	dos(filename);
elseif strcmp(computer,'MAC') 
	eval(['! ',filename]);
else
    if filename(1)~='.' && filename(1)~='/',
    	eval(['! ./',filename]);
    else
        eval(['! ',filename]);
    end
end
