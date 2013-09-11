function recset_jd(h,property,value)
%
% This function recursively changes the value of the property of an object
% and all its children (ex : 'visible')
%
set(h,property,value)
%
children = get(h,'children');
%
for ich = 1:length(children),
    recset_jd(children(ich),property,value);
end