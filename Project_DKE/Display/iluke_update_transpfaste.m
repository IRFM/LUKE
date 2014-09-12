% script iluke_update_transpfaste
%
for it = 1:ntimes,
    if isempty(transpfastes{it});
        transpfastes{it} = load_structures_yp('transpfaste','INIT','');% default dkeparam
    end
end
%
if curtime > 0,
    %
    lukeobj.transp.modify.state = 'on';
    lukeobj.transp.load.state = 'on';
    lukeobj.transp.save.state = 'on';
    lukeobj.transp.disp.state = 'on';
    %
    if isfield(transpfastes{curtime},'orig'),
        lukeobj.transp.reset.state = 'on';
    else
        lukeobj.transp.reset.state = 'off';
    end
    %
    lukeobj.transp.text.string = transpfastes{curtime}.id;
    %
else
    %
    comptest = true;
    %
    for it = 2:ntimes,
        comptest = comptest && comp_struct_jd(transpfastes{1},transpfastes{it},0);
    end
    %
    if ntimes > 0 && comptest,
        lukeobj.transp.modify.state = 'on';
        lukeobj.transp.load.state = 'on';
        lukeobj.transp.save.state = 'on';
        lukeobj.transp.disp.state = 'on';
        %
        if isfield(transpfastes{1},'orig'),
            lukeobj.transp.reset.state = 'on';
        else
            lukeobj.transp.reset.state = 'off';
        end
        %
        lukeobj.transp.text.string = transpfastes{1}.id;
    else
        lukeobj.transp.modify.state = 'off';
        lukeobj.transp.load.state = 'off';
        lukeobj.transp.save.state = 'off';
        lukeobj.transp.disp.state = 'off';
        lukeobj.transp.reset.state = 'off';
        if ntimes > 0,
            lukeobj.transp.text.string = '< time specific >';
        else
            lukeobj.transp.text.string = '< no shot times >';
        end
    end
    %
    clear it comptest
end
%
