function save_id = timeid_jd(time_id)
%
% creates a string containing the date and time information in order to
% identify a process
%
%
year = num2str(time_id(1) - 2000);
month = num2str(time_id(2));
day = num2str(time_id(3));
hour = num2str(time_id(4));
minute = num2str(time_id(5));
second = num2str(round(time_id(6)));
%
if length(year) == 1,
    year = ['0',year];
end
if length(month) == 1,
    month = ['0',month];
end
if length(day) == 1,
    day = ['0',day];
end
if length(hour) == 1,
    hour = ['0',hour];
end
if length(minute) == 1,
    minute = ['0',minute];
end
if length(second) == 1,
    second = ['0',second];
end
%
save_id = [year,month,day,hour,minute,second];