function iluke_print(opt,savename,savedir,h)
%
% prints or save handle h
%
newfig = figure;
%
for ich = length(h):-1:1,
    ax(ich) = copyobj(h(ich),newfig);
end
%
print_jd(opt,savename,savedir,newfig)
%
close(newfig)