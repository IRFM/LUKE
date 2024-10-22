function [script_name] = sluke_params_script(varargin)
%
% LUKE - Generate a *.m script from a simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structure for modifications
%
% OUTPUT :
%
%   - script_name : name of the .m script [string]
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams_out = {};
%
if nargin == 1
    %
    sparams_in = varargin{1};
    %
    filename = input_dke_yp('File name','');
    %
elseif nargin == 2
    %
    sparams_in = varargin{1};
    %
    filename = varargin{2};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_script function');
    %
end
%
if isstruct(sparams_in)
    %
    [err,status] = sluke_params_consistency(sparams_in);
    %
    if err == 0
        %
        timeid = timeid_jd(clock);
        %
        if isempty(filename)
            %
            filename = timeid;
            %
        end
        %
        script_name = ['make_sparams_',filename,'.m'];
        %
        fid = fopen(script_name,'w');
        %
        fprintf(fid,'%s\n','%');
        fprintf(fid,'%s\n','%------------------------------------------------------------------------');
        fprintf(fid,'%s\n','%Self-generated script from a sluke simulation parameters structure.');
        fprintf(fid,'%s\n','%The script may be modified but all fields must have the same length.');
        fprintf(fid,'%s\n','%Use sluke_params_consistency.m to check the consistency of the structure');
        fprintf(fid,'%s\n','%Use sluke_params_generator.m to start with a new parameters structure.');
        fprintf(fid,'%s\n','%To recreate the parameters structure, run the self-generated script.');
        fprintf(fid,'%s\n','%------------------------------------------------------------------------');
        fprintf(fid,'%s\n','%');
        %
        fns_in = fieldnamesr(sparams_in);
        ihelp = find(contains_yp(fns_in,'help'));
        iformat = find(contains_yp(fns_in,'format'));
        %
        if ~isempty(ihelp)
            fns = fns_in(1:ihelp(1)-1);
        else
            fns = fns_in;
        end
        %
        nf0 = length(sparams_in.machine);
        %
        for ii = 1:length(fns)
            %
            aa = eval(['sparams_in.',fns{ii};]);
            bb = '';
            %
            for jj = 1:nf0
                %
                if ischar(aa{jj})
                    if jj == nf0
                        bb = [bb,'''',aa{jj},''''];
                    else
                        bb = [bb,'''',aa{jj},''' '];
                    end
                elseif isnumeric(aa{jj})
                    if jj == nf0
                        bb = [bb,'[',num2str(aa{jj}),']'];
                    else
                        bb = [bb,'[',num2str(aa{jj}),'] '];
                    end
                elseif iscell(aa{jj})
                    %
                    cc = '';
                    %
                    for kk = 1:length(aa{jj})
                        %
                        if ischar(aa{jj}{kk})
                            if kk == length(aa{jj})
                                cc = [cc,'''',aa{jj}{kk},''''];
                            else
                                cc = [cc,'''',aa{jj}{kk},''' '];
                            end
                        elseif isnumeric(aa{jj}{kk})
                            if kk == length(aa{jj})
                                cc = [cc,'[',num2str(aa{jj}{kk}),']'];
                            else
                                cc = [cc,'[',num2str(aa{jj}{kk}),'] '];
                            end
                        end
                    end
                    %
                    if jj == nf0
                        bb = ['{',cc,'}'];
                    else
                        bb = ['{',cc,'} '];
                    end
                    %
                end
            end
            %
            ss = ['{',bb,'}'];
            %
            if ii > 1 && strcmp(fns{ii}(1:strfind(fns{ii},'.')-1),fns{ii-1}(1:strfind(fns{ii-1},'.')-1))
                %
                fprintf(fid,'%s\n',['sparams.',fns{ii},' = ',ss,';%',sluke_params_comment(fns{ii})]);
                %
            else
                %
                fprintf(fid,'%s\n',['%']);
                fprintf(fid,'%s\n',['sparams.',fns{ii},' = ',ss,';%',sluke_params_comment(fns{ii})]);
                %
            end
            %
        end
        %
        if ~isempty(ihelp)
            %
            fprintf(fid,'%s\n','%');
            fprintf(fid,'%s\n','%------------------------------------------------------------------------');
            fprintf(fid,'%s\n','%');
            %
            for ii = 1:length(ihelp)
                %
                aa = eval(['sparams_in.',fns_in{ihelp(ii)};]);
                fprintf(fid,'%s\n',['sparams.',fns_in{ihelp(ii)},' = ''',aa,''';']);
                %
            end
            %
        end
        %
        if ~isempty(iformat)
            %
            fprintf(fid,'%s\n','%');
            fprintf(fid,'%s\n','%------------------------------------------------------------------------');
            fprintf(fid,'%s\n','%');
            %
            for ii = 1:length(iformat)
                %
                aa = eval(['sparams_in.',fns_in{iformat(ii)};]);
                fprintf(fid,'%s\n',['sparams.',fns_in{iformat(ii)},' = ''',aa,''';']);
                %
            end
            %
        end
        %
        fprintf(fid,'%s\n','%');
        fprintf(fid,'%s\n','%------------------------------------------------------------------------');
        fprintf(fid,'%s\n','%------------------------------------------------------------------------');
        fclose(fid);
        %
        disp(['The file make_sparams_',filename,'.m has been successfully created.'])
        %
    end
    %
else
    %
    fid = fopen([sparams_in,'.m']);
    %
    ii = 1;
    tline = fgetl(fid);
    script(ii) = {tline};
    %
    while ischar(tline)
        %
        ii = ii + 1;
        tline = fgetl(fid);
        script(ii) = {tline};
        %
    end
    %
    fclose(fid)
    %
    script = script(1:end-1);%remove last input
    %
    fid = fopen(['make_sparams_',filename,'_test.m'],'w');
    %
    for ii = 1:length(script)
        %
        if strcmp(script{ii}(strfind(script{ii},'%')),'%')
            %
            fprintf(fid,'%s\n',script{ii});
            %
        else
            %
            disp(ii)
            %
            if strcmp(script{ii}(strfind(script{ii},';')),';')
            
                
            else
                
            end
            
            
            %
        end
        %
    end
    %
    fclose(fid)
    %
end