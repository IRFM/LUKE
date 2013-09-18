%************************************** DISPLAY PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file DISPLAY_display_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
dkedisplay.id = 'PARTIAL_VISUAL';%Set here the name (identifier) of the display parameters
%
dkedisplay.psin_display = NaN;%Approximate radial position in poloidal flux coordinate at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
dkedisplay.rho_display = 0.5;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
%
dkedisplay.dp_cyl = 0.1;%Cylindrical momentum step for contour plot (pth_ref)
dkedisplay.nlevel = 30;%Number of level for contour plots
%
dkedisplay.display_mode = 1;%Display mode: (0): no, (1): partial, (2): full
dkedisplay.time_pause = 1;%Pause delay for figure display (s)
dkedisplay.diary_mode = 0;%Write in a file the output of the code in the MatLab command window: (0) no save, (1) save
dkedisplay.auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
%
dkedisplay.mdce = 0;%Display warning when the Distributed Computing Environment is enabled (0 otherwise)
%
eval(['save DISPLAY_',dkedisplay.id,'.mat dkedisplay']);