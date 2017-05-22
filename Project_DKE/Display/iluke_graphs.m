function graph = iluke_graphs(h,n,str,tag,curtime)
%
if nargin < 5,
    curtime = 0;% case with all times considered
end
if ~iscell(n),
    if isscalar(n),
        n=1:n;
    end
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
%
flag = false(1,nch); 
lflag = false(1,nch); 
%
for ich = 1:nch,
    flag(ich) = strcmp(get(children(ich),'Type'),'axes') && strcmp(get(children(ich),'Visible'),'on');
    lflag(ich) = strcmp(get(children(ich),'Type'),'legend') && strcmp(get(children(ich),'Visible'),'on');
end
flag = find(flag);
lflag = find(lflag);
nf = length(flag);
nlf = length(lflag);
%
if nlf > 0 % no legend or more recent matver
    if length(flag) < nn,
        error('Problem identifying graphs');
    else
        for in = 1:nn,
            graph(in).handles(1) = children(flag(n{in}(1)));
            for ilf = 1:nlf
                if get(children(lflag(ilf)),'axes') == graph(in).handles(1),
                    graph(in).handles(end+1) = children(lflag(ilf));
                end
            end
            graph(in).info = str{in};
            graph(in).tag = tag{in};
            graph(in).curtime = curtime;
        end
    end
else % older matevr
    if nf < max(nlist)
        error('Problem identifying graphs');
    else
        for in = 1:nn,
            graph(in).handles = children(flag(n{in}));
            graph(in).info = str{in};
            graph(in).tag = tag{in};
            graph(in).curtime = curtime;
        end
    end
end
%
