%
% external_hxr
%
if isfield(external,'hxr'),% include data from external structure if available
    %
    external_hxr = external.hxr;
    %
else
    %
    external_hxr = [];% no external structure
    %
end 
%
if ~isempty(external_hxr),
    lukeobj.hxrcam.import.state = 'on';
    lukeobj.hxrexp.import.state = 'on';
    lukeobj.hxrparam.import.state = 'on';
else
    lukeobj.hxrcam.import.state = 'off';
    lukeobj.hxrexp.import.state = 'off';
    lukeobj.hxrparam.import.state = 'off';
end
%
nc = length(hxr.cam);
lukeobj.hxrcam.select.string = [lukeobj.hxrcam.select.string{1},cell(1,nc)];
for ic = 1:nc,
    lukeobj.hxrcam.select.string{ic+1} = hxr.cam{ic}.id;
end
%
ic = lukeobj.hxrcam.select.value - 1;% selected camera
%
if ic == 0,% all cameras
    lukeobj.hxrchord.select.state = 'off';
    lukeobj.hxrchord.select.value = 1;
else
    lukeobj.hxrchord.select.state = 'on';
    nchords = length(hxr.cam{ic}.chordsnum);
    lukeobj.hxrchord.select.string = [lukeobj.hxrchord.select.string{1},cell(1,nchords)];
    for ichord = 1:nchords,
        lukeobj.hxrchord.select.string{ichord+1} = ['# ',num2str(hxr.cam{ic}.chordsnum(ichord))];
    end
    lukeobj.hxrchord.select.value = hxr.cam{ic}.selectedchord + 1;
end    
%
if isempty(hxr.cam),
    %
    lukeobj.hxrcam.select.state = 'off';
    %
    lukeobj.hxrcam.save.state = 'off';
    lukeobj.hxrcam.clear.state = 'off';
    lukeobj.hxrcam.disp.state = 'off';
    %
    if ~isempty(external_hxr),
        lukeobj.hxrcam.import.highlight = true;
        lukeobj.hxrcam.load.highlight = false;
    else
        lukeobj.hxrcam.load.highlight = true;
        lukeobj.hxrcam.import.highlight = false;
    end
    %
else
    %
    lukeobj.hxrcam.select.state = 'on';
    %
    lukeobj.hxrcam.save.state = 'on';
    lukeobj.hxrcam.clear.state = 'on';
    %
    if curtime > 0,
        lukeobj.hxrcam.disp.state = 'on';
    else
        lukeobj.hxrcam.disp.state = 'off';
    end
    %
    lukeobj.hxrcam.import.highlight = false;
    lukeobj.hxrcam.load.highlight = false;
    %
end
%
if isempty(hxr.exp),
    %
    lukeobj.hxrexp.save.state = 'off';
    lukeobj.hxrexp.clear.state = 'off';
    %
    if ~isempty(external_hxr),
        lukeobj.hxrexp.import.highlight = true;
        lukeobj.hxrexp.load.highlight = false;
    else
        lukeobj.hxrexp.load.highlight = true;
        lukeobj.hxrexp.import.highlight = false;
    end
    %
else
    %
    lukeobj.hxrexp.save.state = 'on';
    lukeobj.hxrexp.clear.state = 'on';
    %
    lukeobj.hxrexp.import.highlight = false;
    lukeobj.hxrexp.load.highlight = false;
    %
    nbins = length(hxr.exp.energy);
    lukeobj.hxrbin.select.string = [lukeobj.hxrbin.select.string{1},cell(1,nbins)];
    for ibin = 1:nbins-1,
        lukeobj.hxrbin.select.string{ibin+1} = [num2str(hxr.exp.energy(ibin)),' < k (keV) < ',num2str(hxr.exp.energy(ibin + 1))];
    end    
    lukeobj.hxrbin.select.string{nbins+1} = ['k (keV) > ',num2str(hxr.exp.energy(nbins))];
    %
end
%
if ~isempty(hxr.exp) && ic > 0 && any(any(any(~isnan(hxr.exp.data(:,:,hxr.cam{ic}.chordsind))))),
    %
    lukeobj.hxrexp.disp.state = 'on';
    lukeobj.hxrbin.select.state = 'on';
    %
else
    %
    lukeobj.hxrexp.disp.state = 'off';
    lukeobj.hxrbin.select.state = 'off';
end
%
if isempty(hxr.param),
    %
    lukeobj.hxrparam.modify.state = 'off';
    lukeobj.hxrparam.save.state = 'off';
    lukeobj.hxrparam.clear.state = 'off';
    %
    if ~isempty(external_hxr),
        lukeobj.hxrparam.import.highlight = true;
        lukeobj.hxrparam.load.highlight = false;
    else
        lukeobj.hxrparam.load.highlight = true;
        lukeobj.hxrparam.import.highlight = false;
    end
    %
    lukeobj.hxrbrem.run.state = 'off';
    %
    lukeobj.hxrrange1.edit.state = 'off';
    lukeobj.hxrrange2.edit.state = 'off';
    %
else
    %
    lukeobj.hxrparam.modify.state = 'on';
    lukeobj.hxrparam.save.state = 'on';
    lukeobj.hxrparam.clear.state = 'on';
    %
    lukeobj.hxrparam.import.highlight = false;
    lukeobj.hxrparam.load.highlight = false;
    %
    lukeobj.hxrbrem.run.state = 'on';
    %
    lukeobj.hxrrange1.edit.state = 'on';
    lukeobj.hxrrange2.edit.state = 'on';
    %
    lukeobj.hxrrange1.edit.string = num2str(hxr.param.kmin);
    lukeobj.hxrrange2.edit.string = num2str(hxr.param.kmax);
    %
end
%
if any(status.sdiag(1,:) >= 1),
    lukeobj.hxrbrem.run.highlight = false;
    %
    lukeobj.hxrbrem.clear.state = 'on';
    lukeobj.hxrbrem.disp.state = 'on';
    %
    if ~isempty(hxr.cam),
        lukeobj.hxrdiag.run.state = 'on';
    else
        lukeobj.hxrdiag.run.state = 'off';
    end
else
    lukeobj.hxrbrem.run.highlight = true;
    %
    lukeobj.hxrbrem.clear.state = 'off';
    lukeobj.hxrbrem.disp.state = 'off';
    %
    lukeobj.hxrdiag.run.state = 'off';
    %
end    
%
if any(status.sdiag(1,:) >= 2),
    lukeobj.hxrdiag.run.highlight = false;
    %
    lukeobj.hxrdiag.clear.state = 'on';
    lukeobj.hxrdiag.disp.state = 'on';
else
    lukeobj.hxrdiag.run.highlight = true;
    %
    lukeobj.hxrdiag.clear.state = 'off';
    lukeobj.hxrdiag.disp.state = 'off';
end  
%
clear external_hxr ic nc
%
