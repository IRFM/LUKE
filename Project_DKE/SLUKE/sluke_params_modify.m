function sparams_out = sluke_params_modify(varargin)
%
% LUKE - Modify values in substructures from a simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : modified structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 1
    %
    sparams_in = varargin{1};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_modify function');
    %
end
%
[err,status] = sluke_params_consistency(sparams_in);
%
if err == 0
    %
    fns_in = fieldnamesr(sparams_in);
    ihelp = find(contains_yp(fns_in,'help'));
    if ~isempty(ihelp)
        fns = fns_in(1:ihelp(1)-1);
    else
        fns = fns_in;
    end
    %
    nf0 = length(sparams_in.machine);
    %
    if isfield(sparams_in,'help') && isfield(sparams_in,'format')
        %
        sparams_out = rmfield(sparams_in,{'help','format'});
        %
    else
        %
        sparams_out = sparams_in;
        %
    end
    %
    while 1
        %
        display_fields(sparams_in,sparams_out,fns,nf0);
        %
        iiref = input_dke_yp('Which field must be modified (-1:exit)',1,[-1:length(fns)]);
        %
        if iiref == -1
            %
            break
            %
        else
            %
            aa = eval(['sparams_out.',fns{iiref}]);
            %   
            if isfield(sparams_in,'help') && issubfield(sparams_in.help,fns{iiref})
                %
                bb = eval(['sparams_in.help.',fns{iiref}]);
                %
            else
                %
                bb = '';
                %
            end
            %
            if isfield(sparams_in,'format') && issubfield(sparams_in.format,fns{iiref})
                %
                cc = eval(['sparams_in.format.',fns{iiref}]);
                %
            else
                %
                cc = '';
                %
            end
            %
            %eval(['disp([''sparams_out.',fns{iiref},'''])']);
            %
            for jj = 1:nf0
                %
                if strlength(bb) > 0
                    %
                    if strlength(cc) > 0
                        %   
                        dd = input_dke_yp(['Change the value #',int2str(jj),' ',bb,' (',cc,')'],aa{jj});
                        %
                    else
                        %
                        dd = input_dke_yp(['Change the value #',int2str(jj),' ',bb],aa{jj});
                        %
                    end
                    %
                else
                    %
                    if iscell(aa{jj})
                        if length(aa{jj}) == 0
                             dd = input_dke_yp(['Change the cell value #',int2str(jj),'/',int2str(nf0),' (field #',int2str(iiref),')'],'');
                        else
                            for kk = 1:length(aa{jj})
                                dd{kk} = input_dke_yp(['Change the subcell value #',int2str(kk),'/',int2str(length(aa{jj})),' (cell #',int2str(jj),'/',int2str(nf0),' , field #',int2str(iiref),')'],aa{jj}{kk});
                            end
                        end
                    else
                        dd = input_dke_yp(['Change the cell value #',int2str(jj),'/',int2str(nf0),' (field #',int2str(iiref),')'],aa{jj});
                    end
                    %
                end
                %
                eval(['sparams_out.',fns{iiref},'{',int2str(jj),'} = dd;']);
                %
            end
        end
    end
end
%
if isfield(sparams_in,'help') && isfield(sparams_in,'format')
    sparams_out.help = sparams_in.help;
    sparams_out.format = sparams_in.format;
end
%
end
%
function display_fields(sparams_in,sparams_out,fns,nf0)
%
    disp('---------------------------------------------')
    disp('List of fields of the sparams structure.')
    disp('---------------------------------------------')
    %
    for ii = 1:length(fns)
        %
        aa = eval(['sparams_out.',fns{ii};]);
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
            elseif iscell(aa{jj})
                 if jj == nf0
                     %
                 	if length(aa{jj}) == 1
                        %
                        kk = 1;
                        %
                        if ischar(aa{jj}{kk})
                            bb = [bb,'{''',aa{jj}{kk},'''} '];
                        else
                            bb = [bb,'{[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']} '];
                        end 
                    else
                        for kk = 1:length(aa{jj})
                            %
                            if ischar(aa{jj}{kk})
                                if kk == 1
                                    bb = [bb,'{''',aa{jj}{kk},''' '];
                                elseif kk > 1 && kk < length(aa{jj})
                                    bb = [bb,'''',aa{jj}{kk},''''];
                                elseif kk == length(aa{jj})
                                    bb = [bb,'''',aa{jj}{kk},'''}'];
                                end
                            else
                                if kk == 1
                                    bb = [bb,'{[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),'] '];
                                elseif kk > 1 && kk < length(aa{jj})
                                    bb = [bb,'[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']'];
                                elseif kk == length(aa{jj})
                                    bb = [bb,'[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']}'];
                                end 
                            end 
                        end  
                        %
                    end
                    %
                 else
                    if length(aa{jj}) == 1
                        %
                        kk = 1;
                        %
                        if ischar(aa{jj}{kk})
                            bb = [bb,'{''',aa{jj}{kk},'''} '];
                        else
                            bb = [bb,'{[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']} '];
                        end 
                    else
                        for kk = 1:length(aa{jj})
                            %
                            if ischar(aa{jj}{kk})
                                if kk == 1
                                    bb = [bb,'{''',aa{jj}{kk},''' '];
                                elseif kk > 1 && kk < length(aa{jj})
                                    bb = [bb,'''',aa{jj}{kk},''''];
                                elseif kk == length(aa{jj})
                                    bb = [bb,'''',aa{jj}{kk},'''}'];
                                end
                            else
                                if kk == 1
                                    bb = [bb,'{[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),'] '];
                                elseif kk > 1 && kk < length(aa{jj})
                                    bb = [bb,'[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']'];
                                elseif kk == length(aa{jj})
                                    bb = [bb,'[',regexprep(num2str(aa{jj}{kk}), '\s+', ' '),']}'];
                                end 
                            end 
                        end  
                        %
                    end
                    
                    
                 end
                    
        
                %
            else
                if jj == nf0
                    bb = [bb,'[',regexprep(num2str(aa{jj}), '\s+', ' '),']'];
                else
                    bb = [bb,'[',regexprep(num2str(aa{jj}), '\s+', ' '),'] '];
                end
            end
        end
        %
        ss = ['{',bb,'}'];
        %
        disp(['(',int2str(ii),') ',fns{ii},' = ',ss])
        %
    end
    %
    disp('---------------------------------------------')
    disp(' ')
end
%
function tf = issubfield(s,field)
%
%ISSUBFIELD Determine if field is valid in struct S
%   Determine if the specified field or nested FIELD is present in the
%   given structure.
%
%   A.b.c.d = 1;
%   issubfield(A,"b.c.d")       % TRUE
%   issubfield(A,"b")           % TRUE
%   issubfield(A,"b.c.d.e")     % FALSE
%   issubfield(A,"f")           % FALSE
%arguments
%    s (1,1) struct
%    field (1,1) string
%end
subfield = strsplit(field,'.');
if numel(subfield) == 1
    tf = isfield(s,field);
    return;    
end
tf = true;
for i = 2:numel(subfield)    
    s = s.(subfield(i-1));
    if ~isfield(s,subfield(i))
        tf = false;
        break;
    end
end
end