function matstruct = cfg2mat(cfgfile,matstruct)
%
% this function returns matlab structures from a AMR config file
%
fin = fopen(cfgfile,'r');
tline = fgetl(fin);
while isempty(tline) || tline(1) ~= -1
    if ~isempty(tline) && tline(1) == '['% new substructure
        sub = tline(2:end-1);
    elseif ~isempty(tline) && tline(1) ~= ';' && tline(1) ~= '#',% exclude comments lines
        k = findstr('=', tline);
        it = ['matstruct.',sub,'.',tline(1:k),'''',tline(k+1:end),''';'];
        eval(it);
        eval(['val = str2double(matstruct.',sub,'.',tline(1:k-1),');']);
        if ~isnan(val),% converts str to doubles if applicable
            eval(['matstruct.',sub,'.',tline(1:k-1),' = val;'])
        else% removes white spaces
            eval(['matstruct.',sub,'.',tline(1:k-1),' = strtrim(matstruct.',sub,'.',tline(1:k-1),');'])
        end
    end
    tline = fgetl(fin);
end
fclose(fin);
