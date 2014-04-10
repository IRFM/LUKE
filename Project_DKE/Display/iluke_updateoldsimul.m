% script iluke_updateoldsimul
%
% This script updates older simulations
%
if isfield(lukeobj,'r5x2'),% before sdiag
    lukeobj = rmfield(lukeobj,'r5x2');
    %
    status = rmfield(status,'hxr');
    %
    status.sdiag = zeros(2,size(status.output,2));
    status.sdiag(:,status.output == 1) = 1;% synthetic diagnostics need distribution
    %
    sdiags = cell(2,size(outputs,2));
    sdiags(:) = {{}};
    %
end
    