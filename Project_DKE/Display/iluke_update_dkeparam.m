% script iluke_update_dkeparam
%
for it = 1:ntimes,
    if isempty(dkeparams{it});
        dkeparams{it} = load_structures_yp('dkeparam','RT','');% default dkeparam
    end
end
%
if curtime > 0,
    %
    lukeobj.param.modify.state = 'on';
    lukeobj.param.load.state = 'on';
    lukeobj.param.save.state = 'on';
    %
    if isfield(dkeparams{curtime},'orig'),
        lukeobj.param.reset.state = 'on';
    else
        lukeobj.param.reset.state = 'off';
    end
    %
    lukeobj.param.text.string = dkeparams{curtime}.id;
    %
else
    %
    comptest = true;
    %
    for it = 2:ntimes,
        comptest = comptest && comp_struct_jd(dkeparams{1},dkeparams{it},0);
    end
    %
    if ntimes > 0 && comptest,
        lukeobj.param.modify.state = 'on';
        lukeobj.param.load.state = 'on';
        lukeobj.param.save.state = 'on';
        %
        if isfield(dkeparams{1},'orig'),
            lukeobj.param.reset.state = 'on';
        else
            lukeobj.param.reset.state = 'off';
        end
        %
        lukeobj.param.text.string = dkeparams{1}.id;
    else
        lukeobj.param.modify.state = 'off';
        lukeobj.param.load.state = 'off';
        lukeobj.param.save.state = 'off';
        lukeobj.param.reset.state = 'off';
        lukeobj.param.text.string = '< time specific >';
    end
    %
    clear it comptest
end
%
