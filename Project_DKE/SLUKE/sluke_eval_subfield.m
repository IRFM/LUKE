function keepGoing = sluke_eval_subfield(sparams,ii,varargin)
% bool_val = sluke_eval_subfield(sparams,ii,field1,...,fieldN,func)
% 
% This function allows to apply a function on a subfield of a struct of type
% sparams, while checking the existance and fullness of such subfield. If
% the subfield path specified with filed1,...fieldN exists and is not empty
% it takes the value contained in the i-th position of the cell in
% sparams.field1.(...).fieldN, it uses it as function func's argument and
% returns the value returned by func. If otherwise the subfield does not 
% exist or is empty it returns false.   
% 
%
% E.g.
% >>sparams.simul.jprofileconsistency.nit = {0,4};
% >>sluke_eval_subfield(sparams,2,'simul','jprofileconsistency','nit',@(x)x>1))
% ans =
%      1
% The function check if it exist sparams.simul.jprofileconsistency.nit. It 
% then uses it as the argument of the inline function returning the result. 
%
% sparams                   --> Structure that contain the subfield to be 
%                               checked.
% ii                        --> Simulation number
% subfield1,...,subfieldN   --> Any number of nested field.
% func                      --> Function to apply to the value contained by  
%                               the specified subfield.
%
% PROTIP:
% Use double negation to have the right logical output from function and
% true if the field is not found or empty. 
% 
% e.g.
% f = @(x) logicalcheck(x);
% checkVal = ~sluke_eval_subfield(sparams,ii,'subfield',~f)
%
% In that way checkVal will be true if f returns true or if subfield is
% empty or non existent
% 
% by R.Saura  26.06.2024

%RS

jj = 1; 
keepGoing = true;
target = sparams;
    %check that the subfield sparams.subfield1(...).subfieldN exist
    while(jj<length(varargin) && keepGoing )
        keepGoing = isfield( target, varargin{jj} );
        if keepGoing
            target = target.(varargin{jj});
        end    
        jj = jj+1;
    end
    %if found check if the subfield is not empty
    if keepGoing,   keepGoing = ~isempty(target);           end
    if keepGoing,   target = target{ii};                    end
    %if still valid apply the function
    if keepGoing
       if iscell(target),   keepGoing = cellfun(varargin{jj},target); 
       else,                keepGoing = varargin{jj}(target);    end
    else %%% is it broken???? %% TO DO %%
    end
end