function ripple = imake_ripple_yp(basestr,equil)
%
% This function interactively builds the ripple structure
%
ripple = '';
%
mode = input('Magnetic ripple calculation. Yes: 1, No: 0, [0] : ');
if isempty(mode),
    mode = 0;
end
if mode > 1,mode = 1;end
%
ripple.mode = mode;
%
id_ripple = input(['Please specify a name for the ''ripple'' structure : [',id_ripple_i,'] : '],'s');
if isempty(id_ripple),
    id_ripple = id_ripple_i;
end
ripple.id = id_ripple;
%





