function LUKE_list = get_all_lukeversions_jd
%
% find all LUKE installations on the machine
%
disp(' ');
disp('List all LUKE installations on the machine');
disp(' ');
%
LUKE_search_default = getenv('HOME');
LUKE_list = [];
%
while 1,
    %
    LUKE_search_path = input(['Enter a path to search for LUKE installations (Enter "0" when done) ? [',LUKE_search_default,'] '],'s');
    %
    if isempty(LUKE_search_path),
        LUKE_search_path = LUKE_search_default;
    end
    %
    if strcmp(LUKE_search_path,'0'),
        break
    end
    %
    if exist(LUKE_search_path,'dir'),
        [~,LUKEversion_char] = unix(['find ',getenv('HOME'),' -name LUKEversion_jd.m']);
        %
        while ~isempty(LUKEversion_char),
            nexteof = find(double(LUKEversion_char) == 10,1,'first');
            LUKEversion_path = LUKEversion_char(1:nexteof-1);% full LUKEversion_jd.m path
            %
            LUKE_root = LUKEversion_path(1:strfind(LUKEversion_path,'/Project_DKE/DKE/LUKEversion_jd.m'));
            %
            % get corresponding LUKE version
            %
            wd = pwd;
            cd(fileparts(LUKEversion_path));
            LUKEversion = LUKEversion_jd;
            cd(wd);
            %
            LUKE_list(end+1).root = LUKE_root;
            LUKE_list(end).version = LUKEversion;
            %
            disp([LUKEversion,' : ',LUKE_root])
            %
            LUKEversion_char = LUKEversion_char(nexteof+1:end);
            %
        end
        %
    else
        disp('Warning : This path does not exist.')
    end
    %
    LUKE_search_default = '0';
    %
end
%
