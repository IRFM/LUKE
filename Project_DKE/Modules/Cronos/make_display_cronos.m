function [launch] = make_display_cronos(config)
%
% Create the structure display for CRONOS
% 
if strcmp(config,'NO_DISPLAY');%For the Lower Hybrid wave simulations
   display_id = 'NO_DISPLAY';%Set here the name (identifier) of the display parameters
%
   display.psin_display = NaN;%Approximate radial position in poloidal flux coordinate at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
   display.rho_display = 0.5;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
%
   display.dp_cyl = 0.1;%Cylindrical momentum step for contour plot (pth_ref)
   display.nlevel = 30;%Number of level for contour plots
%
   display.display_mode = 0;%Display mode: (0): no, (1): partial, (2): full
   display.time_pause = 1;%Pause delay for figure display (s)
   display.diary_mode = 0;%Write in a file the output of the code in the MatLab command window: (0) no save, (1) save
   display.auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
elseif strcmp(config,'PARTIAL_VISUAL');%For the Lower Hybrid wave simulations
   display_id = 'PARTIAL_VISUAL';%Set here the name (identifier) of the display parameters
%
   display.psin_display = NaN;%Approximate radial position in poloidal flux coordinate at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
   display.rho_display = 0.5;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
%
   display.dp_cyl = 0.1;%Cylindrical momentum step for contour plot (pth_ref)
   display.nlevel = 30;%Number of level for contour plots
%
   display.display_mode = 1;%Display mode: (0): no, (1): partial, (2): full
   display.time_pause = 1;%Pause delay for figure display (s)
   display.diary_mode = 0;%Write in a file the output of the code in the MatLab command window: (0) no save, (1) save
   display.auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
elseif strcmp(config,'VISUAL');%For the Lower Hybrid wave simulations
   display_id = 'VISUAL';%Set here the name (identifier) of the display parameters
%
   display.psin_display = NaN;%Approximate radial position in poloidal flux coordinate at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
   display.rho_display = 0.1;%Approximate radial position at which results are displayed if display.display_mode >= 1 [1,1]. Not used if NaN
%
   display.dp_cyl = 0.1;%Cylindrical momentum step for contour plot (pth_ref)
   display.nlevel = 30;%Number of level for contour plots
%
   display.display_mode = 2;%Display mode: (0): no, (1): partial, (2): full
   display.time_pause = 1;%Pause delay for figure display (s)
   display.diary_mode = 0;%Write in a file the output of the code in the MatLab command window: (0) no save, (1) save
   display.auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
else
   error('The display configuration name does not exists')  	
end