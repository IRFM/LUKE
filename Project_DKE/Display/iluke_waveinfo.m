function infostr = iluke_waveinfo(waves)
%
nw = length(waves);
infostr = cell(1,nw);
for iw = 1:nw,
    infostr{iw} = ['Wave # ',num2str(iw),'   Type : ',waves{iw}.rayinit.type,'   Id : ',waves{iw}.id];
end
