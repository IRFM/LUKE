function pathname = getpath_jd(filename);
%
fullpath = which([filename]);
%
ns = length(fullpath);
while ns > 0 & fullpath(ns) ~= '\'  & fullpath(ns) ~= '/' 
    ns = ns - 1;
end

pathname = fullpath(1:ns-1);
