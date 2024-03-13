function [tooltip] = slukeGUITooltip(address,field)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if isempty(address)
    key = {field};
else
    key = [address field];
end

tooltip = F_help_sparams(key);

end

