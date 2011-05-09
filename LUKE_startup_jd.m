function flag = LUKE_startup_jd(spath,pathforstartup)
%
% This function creates or mofifies a startup file to include LUKE paths
%
%By Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
flag = 0;%existing startup file
%
disp(' ');
%
if isempty(pathforstartup);
    pathforstartup = which('startup.m');%The default directory for startup.m is the same as the always existing startup.m file
    if isempty(pathforstartup),
        matlabpath = path;
        pathforstartup = [matlabpath(1:find(matlabpath == ':',1,'first') - 1),filesep];%first path location selected.
        disp('No startup file found in matlab path.')
        disp(['Default location for startup file : ',pathforstartup])
        flag = 1;%new startup file
    else
        pathforstartup = pathforstartup(1:end-length('startup.m'));
        disp(['File startup.m found at this location : ',pathforstartup])
    end
else
    disp(['Location selected for startup file : ',pathforstartup])
end
%
if strcmp(pathforstartup(end),filesep);
    startupfile = [pathforstartup,'startup.m'];
else
    startupfile = [pathforstartup,filesep,'startup.m'];
end
%
if exist(startupfile,'file'),%startup.m file already exist
    %
    % test that file can be written
    %
    fid = fopen(startupfile,'r+');  
    if fid == -1,
        %
        disp('Warning : Cannot write to startup.m, permission denied. Please setup startup file manually.');
        %
        flag = 2;
        %
    else
        %
        % look for existing LUKE path in file
        %
        sfile = fread(fid);
        cfile = char(sfile.');
        %
        sf1 = strfind(cfile,'%%%%%%%%%%%%%%%%%%%BEGIN-LUKE-PATH%%%%%%%%%%%%%%%%%%%');
        sf2 = strfind(cfile,'%%%%%%%%%%%%%%%%%%%%END-LUKE-PATH%%%%%%%%%%%%%%%%%%%%');
        %
        if length(sf1) ~= length(sf2),
            disp('Warning : Problem in old startup.m file. Please setup startup.m file manually.');
            flag = 2;
        else
            %
            mask = zeros(3,0);
            %
            for isf = 1:length(sf1),
                %
                % test for LUKE path at the present location, ignore others
                %
                if any(strfind(cfile(sf1(isf):sf2(isf)),[pwd,'/'])),
                    tabl = find(sfile(sf1(isf) + 54:sf2(isf)) ~= 32,1,'first') - 1;% length of tabulation
                    mask = [mask,[sf1(isf);sf2(isf)+53;tabl]];% indices to be replaced
                end
            end
            %
            if isempty(mask),% no existing LUKE path at present location
                %
                if isempty(sf1),% no existing LUKE path anywhere
                    flag = -1;% write LUKE path at end of file
                else
                    disp('Warning : Too complex startup.m file. Please setup startup.m file manually.');
                    flag = 2;
                end
                %    
            else% found older LUKE path at present location in startup file. Replaced.                    
                %
                cfile_new = cfile(1:mask(1,1)-1);
                for imk = 1:size(mask,2),
                    if imk < size(mask,2),
                        inext = mask(1,imk+1)-1;
                    else
                        inext = length(cfile);
                    end
                    %
                    tabstr = repmat(' ',[1,mask(3,imk)]);
                    cfile_new = [cfile_new,spath{1},tabstr,spath{2},tabstr,spath{3},...
                        tabstr,spath{4},tabstr,spath{5},cfile(mask(2,imk)+1:inext)];
                    %
                end
                %
                fclose(fid);
                %
                fid = fopen(startupfile,'w');  
                fwrite(fid,double(cfile_new).'); 
                disp('LUKE path updated in startup.m file.')
                %
            end
        end
        %
        fclose(fid); 
        %
    end
    %
else %startup.m file does not exist. It will be created
    %
    if flag == 0,
        disp(['No startup.m file found at selected location : ',pathforstartup,'.'])
        disp('It will be created there.')
        flag = 1;
    end
    %
end
%
if abs(flag) == 1,%path added in new startup file or at end of existing file
    %
    cfile = [spath{1},spath{2},spath{3},spath{4},spath{5}];
    %                
    fid = fopen(startupfile,'a+');%Create or open startup.m file and append LUKE path at the end of the existing startup file
    %
    if fid == -1,
        %
        disp('Warning : Cannot write to startup.m, permission denied. Please setup startup file manually.');
        %
        flag = 2;
        %
    else
        %
        if flag == 1,
            disp(['startup.m file created in folder ',pathforstartup])
        end
        %
        fwrite(fid,double(cfile).');  
        disp('LUKE path added to startup.m file.')
        fclose(fid);
        %
    end
end
%