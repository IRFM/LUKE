function output = sluke_params_replace(data_in,val0,val1)
%
output = data_in;
%
for ii = 1:length(data_in)
    %
    if ischar(data_in{ii})
        output{ii} = strrep(data_in{ii},val0,val1);
    else
        if data_in{ii} == val0
            output{ii} = val1;
        end
    end
    %
end

    

