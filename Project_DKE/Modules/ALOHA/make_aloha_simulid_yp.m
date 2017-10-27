function locid_simul = make_aloha_simulid_yp(aloha)
%
% This function creates a standard id string from aloha LH coupling parameters
%
if isstruct(aloha)
    %
    ne0 = aloha.plasma.ne0/1e17;
    %
    ne0_str = strrep(num2str(ne0),'.','p');
    %
    locid_simul = ['ALOHA_nlh_',ne0_str];
    %
else
    locid_simul = '';
end
