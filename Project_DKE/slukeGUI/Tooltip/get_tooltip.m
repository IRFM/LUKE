% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function tooltip = get_tooltip(tp,key)
% tooltip = get_tooltip(tp,key)
% tooltip = get_tooltip(tp)
%
% tp --> struct working as dictionary. Fields name is the key, their value
%           a string with their help. If the field describled is a substruc
%           its value must be a cell, the first element being a string with
%           ist help inside, the second the reference to a function calling
%           its tooltip list
% key --> cell with the sequence of keys to look for (in depth). If absent
%           will print all possible fields in tp. The function will return
%           an empty string
%

if exist("key","var") && ~isempty(key)
    % case in which I look for a single key
    if isfield(tp,key{1})
        %check that the key is actually in the list;
        tooltip = tp.(key{1});
        if length(tooltip) > 1 
            %Case in which is a substruct
            if length(key) == 1
                tooltip = tooltip{1};
            else 
                tooltip = tooltip{2}(key(2:end));
            end
        end
    else
        % case in which the key is not found in tp
        tooltip = "";
    end
else
    % plot all data in tp;
    fn = fieldnames(tp);
    % pretty data 
    c = 0;
    for i = 1:length(fn)
        c = max(c,length(fn{i}));
    end
      
    Imsorry = false;
    
    for i = 1:length(fn)
        tooltip = tp.(fn{i});
        s = "-%s : \t %s\n";
        if length(tooltip) > 1
            tooltip = tooltip{1};
            s = insertAfter(s, "\t %s", " (struct)");
        end
        if isa(tooltip,'char')
            tooltip = convertCharsToStrings(tooltip);
        end
        
        field = [fn{i} repmat(' ',1,(c-length(fn{i}))) ];
        fprintf(s,field, tooltip);
        if ~Imsorry && tooltip == ""
            Imsorry = true;
        end
    end
    if Imsorry
        fprintf("\nSome helps are not defined yet.\n");
    end
    tooltip = "";
end
