function recset_jd(h,property,value,rec)
%
% This function recursively changes the value of the property of an object
% and all its children (ex : 'visible')
%
nh = length(h);
%
for ih = 1:nh,
    set(h(ih),property,value)
    %
    if nargin > 3 && rec,
        children = get(h(ih),'children');
        %
        recset_jd(children,property,value);
    end
    %
end