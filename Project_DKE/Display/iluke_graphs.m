function graph = iluke_graphs(h,n,str,tag)
%
if isscalar(n),
    n=1:n;
end
if ~iscell(n),
    n={n};
end
nn = length(n);
if ~iscell(str),
    str = repmat({str},[1,nn]);
end
if ~iscell(tag),
    tag = repmat({tag},[1,nn]);
end
%
nlist = [];
for in=1:nn,
    nlist = [nlist,n{in}];
end
%
children = get(h,'children');% list of children for plot1
nch = length(children);
flag = false(1,nch); 
%
for ich = 1:nch,
    flag(ich) = strcmp(get(children(ich),'Type'),'axes') && strcmp(get(children(ich),'Visible'),'on');
end
flag = find(flag);
%
if length(flag) < max(nlist)
    error('Problem identifying graphs');
else
    for in = 1:nn,
        graph(in).handles = children(flag(n{in}));
        graph(in).info = str{in};
        graph(in).tag = tag{in};
    end
end
%
