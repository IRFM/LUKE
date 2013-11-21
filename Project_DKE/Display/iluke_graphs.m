function graph = iluke_graphs(h,n,str,tag)
%
children = get(h,'children');% list of children for plot1
nch = length(children);
flag = false(1,nch); 
%
for ich = 1:nch,
    flag(ich) = strcmp(get(children(ich),'Type'),'axes') && strcmp(get(children(ich),'Visible'),'on');
end
%
if all(sum(flag) ~= n),
    error('Problem identifying graphs');
else
    graph.handles = children(flag);
    graph.info = str;
    graph.tag = tag;
end
%
