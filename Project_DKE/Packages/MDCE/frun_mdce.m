function [X,texe] = frun_mdce(tpause,mode,X)
%
% function for run_mdce:
%
% INPUTS : 
%       - tpause : pause time (s)
%       - mode : data transert mode : 0 (back and forth); (1) forth; (-1) back
%       - X : input matrix
%
% OUTPUTS : 
%       - X : output matrix
%       - toc : execution time
%
tic
%
pause(tpause);
%
if mode == 1,
    X = [];
elseif mode == -1,
    X = rand(X);
end
%
texe = toc;