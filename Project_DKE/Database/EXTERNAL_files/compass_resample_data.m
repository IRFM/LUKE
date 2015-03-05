function res = compass_resample_data(data, ww)

% fast resample data using a running average filter
%
% data: vector of data
% ww: window width

% enforce column vector
% TODO adjust automatically for row/column vectors
data = reshape(data, [], 1);
% cut the last data points
% TODO properly treat the last data points
n_mod = mod(length(data), ww);
data = data(1:end-n_mod);
% reshape the data and calculate the mean
data = reshape(data, ww, []);
res = mean(data, 1);

end
