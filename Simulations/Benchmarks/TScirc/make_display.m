%************************************** DISPLAY PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file DISPLAY_display_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
display_id = 'TScirc';%Set here the name (identifier) of the display parameters
%
display.dp_cyl = 0.1;%Cylindrical momentum step for contour plot (pth_ref)
display.nlevel = 30;%Number of level for contour plots
%
display.display_mode = 1;%Display mode: (0): no, (1): partial, (2): full
display.diary_mode = 0;%Write in a file the output of the code in the MatLab command window: (0) no save, (1) save
display.auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
%
eval(['save DISPLAY_',display_id,'.mat display']);