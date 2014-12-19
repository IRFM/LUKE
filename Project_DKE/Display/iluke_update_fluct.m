% script iluke_update_fluct
%
mask_equil = find(status.fluct == 2);
%
for it = 1:length(mask_equil),
    if isempty(fluctparams{mask_equil(it)}) && isfield(equils{mask_equil(it)},'fluct'),
        equils{mask_equil(it)} = rmfield(equils{mask_equil(it)},'fluct');
    elseif ~isempty(fluctparams{mask_equil(it)}),
        equils{mask_equil(it)}.fluct = fluctstruct_yp(equils{mask_equil(it)},fluctparams{mask_equil(it)}.id,struct('naequilp',fluctparams{mask_equil(it)}));
        clear fluct
    end
end        
status.fluct(mask_equil) = 1;
%
if curtime > 0,
    %
    if status.fluct(curtime) < 0,
        lukeobj.fluct.load.state = 'off';
    else
        lukeobj.fluct.load.state = 'on';
    end
    %
    if status.fluct(curtime) <= 0,
        lukeobj.fluct.modify.state = 'off';
        lukeobj.fluct.save.state = 'off';
        lukeobj.fluct.reset.state = 'off';
        lukeobj.fluct.clear.state = 'off';
        %
        lukeobj.fluct.text.string = '< empty >';
    else
        lukeobj.fluct.modify.state = 'on';
        lukeobj.fluct.save.state = 'on';
        if isfield(fluctparams{curtime},'orig')
            lukeobj.fluct.reset.state = 'on';
        else
            lukeobj.fluct.reset.state = 'off';
        end
        lukeobj.fluct.clear.state = 'on';
        %
        lukeobj.fluct.text.string = fluctparams{curtime}.id;
    end
    %
else
    %
    if all(status.fluct < 0),% no equil, fluct params cannot be loaded
        lukeobj.fluct.load.state = 'off';
    else% some equil, fluct params can be loaded
        lukeobj.fluct.load.state = 'on';
    end
    %
    if all(status.fluct <= 0),% no existing fluct params
        lukeobj.fluct.modify.state = 'off';
        lukeobj.fluct.save.state = 'off';
        lukeobj.fluct.reset.state = 'off';
        lukeobj.fluct.clear.state = 'off';
        %
        lukeobj.fluct.text.string = '< empty >';
    else% some fluct params are loaded
        if any(status.fluct < 1),% fluct params missing for some times, cannot act collectively
            %
            comptest = false;
            %
        else% fluct params present for all times, can act collectively
            %
            comptest = true;
            %
            for it = 2:ntimes,
                comptest = comptest && comp_struct_jd(fluctparams{1},fluctparams{it},0);
            end
        end
        %
        if comptest,
            lukeobj.fluct.modify.state = 'on';
            lukeobj.fluct.save.state = 'on';
            lukeobj.fluct.clear.state = 'on';
            %
            if isfield(fluctparams{1},'orig'),
                lukeobj.fluct.reset.state = 'on';
            else
                lukeobj.fluct.reset.state = 'off';
            end
            %
            lukeobj.fluct.text.string = fluctparams{1}.id;
            %
        else
            lukeobj.fluct.modify.state = 'off';
            lukeobj.fluct.save.state = 'off';
            lukeobj.fluct.clear.state = 'off';
            lukeobj.fluct.reset.state = 'off';
            lukeobj.transp.text.string = '< time specific >';
        end
    end
    %
    clear mask_equil it comptest
end
%
