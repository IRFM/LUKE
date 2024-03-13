function varargout = F_help_param_tor(key)
%   F_help_param_tor()
%   help = F_help_param_tor(key)
%
%plot help for param_tor substruct or find help for specific field of
%the substruct defined in key

tp.dir    = "(0) P + preserve repartition and total power, (1) P/N^2 + preserve directivity and repartition, (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case), (3) P/N^2 + preserve repartition and total power ";
tp.mode   = "(0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin), (1) assemble peaks fixing Pmax and N, allowing dN to change, (2) assemble peaks allowing Pmax, N and dN to change";
tp.nlobes = "number of lobes selected in the power spectrum";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end