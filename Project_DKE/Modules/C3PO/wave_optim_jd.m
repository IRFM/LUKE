function [wavestruct_out,flag_Zp] = wave_optim_jd(dkepath,wavestruct,select)
    %
    % optimizes angles or launch parameters, Zp & Bt towards target ECRH
    %
    % Adjustable parameters
    %
    %
    wavestruct_out = wavestruct;
    %
    ninputs(1) = abs(wavestruct.equil.ptBPHI(1,1));% magnetic field on axis
    ninputs(2) = wavestruct.equil.Zp;%vertical position
    %
    if isfield(wavestruct.launch,'angles'),
        opt_angles = true;
        %
        ninputs(3) = wavestruct.launch.angles.theta;% tilt angle
        ninputs(4) = wavestruct.launch.angles.phi;% rotation angle
    else
        opt_angles = false;
        %
        ninputs(3) = pi/2 - wavestruct.launch.ybeta_L;% poloidal angle    
        if wavestruct.launch.yalpha_L > 0,
            ninputs(4) = wavestruct.launch.yalpha_L - pi;% toroidal angle
        else
            ninputs(4) = wavestruct.launch.yalpha_L + pi;% toroidal angle
        end
    end        
    %
    ntargets(1) = NaN;
    ntargets(2) = NaN;
    ntargets(3) = NaN;
    %
    wavestruct.waveparam.nd = 1;% central ray only
    wavestruct.waveparam.nchi = 1;
    %
    set(select.busyhandle,'Visible','on');drawnow;
    %
    wavestruct.equil_fit = fitequil_yp(wavestruct.equil,wavestruct.fitparam.mode_equil,wavestruct.fitparam.method,wavestruct.fitparam.ngridresample,wavestruct.fitparam.nharm);
    %
    set(select.busyhandle,'Visible','off');drawnow;
    %
    if isfield(select,'style'),
        style = select.style;
    else
        style = struct;
    end
    %
    if isfield(select,'opt_gui'),
        %
        if ishandle(select.opt_gui),
            %
            panelposition = get(select.opt_gui,'Position');
            %
            columnwidth = (panelposition(3) - 4*style.panelsep - 2*style.buthsep - style.longbutwidth)/2;
            columnheight = 6*style.butvsep + 4*style.butheight;
            %
            info.position = [style.panelsep,2*style.panelsep + columnheight,panelposition(3) - 2*style.panelsep,panelposition(4) - columnheight - 3*style.panelsep];
            %
            inputs.position = [style.panelsep,style.panelsep,columnwidth,columnheight];
            targets.position = [2*style.panelsep + columnwidth,style.panelsep,columnwidth,columnheight];
            controls.position = [3*style.panelsep + 2*columnwidth,style.panelsep,2*style.buthsep + style.longbutwidth,columnheight];
            %
            infostr = {...
        '    --------------------------------------------------------',...
        '                  ECRH optimization with C3PO               ',...
        '    --------------------------------------------------------',...
        '  The magnetic field prescription is simulated by changing the wave frequency.',...
        '  Only the central ray is used for optimization. Do not pay attention to deposition width.',...
        '  Warning : if Zp is modified, all other wavestructs and waves will be deleted.',...      
        '    - When all inputs are specified, you can press ''Run'' to calculate the deposition',...  
        '    - Otherwise, press ''Optimize'' to calculate the missing parameters',...           
        '    - The total number of specified (not empty) input and target parameters must always be 4',...
        '    - Press ''Return'' to return optimized parameters to C3PO console',...           
        ' '};
            %
            infostr2 = {...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        '    - The total number of specified (not empty) input and target parameters must always be 4'};
            %
            infostr3 = {...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        ' ',...
        '    - The wave did not enter the plasma. Modify input parameters'};
            %
            inputs.string = 'Input parameters';
            targets.string = 'Deposition target';
            controls.string = 'Controls';
            %
            inputs.bt.title.string = 'Bt [T] (on axis)';
            inputs.zp.title.string = 'Zp [m]';
            if opt_angles,
                inputs.theta.title.string = 'theta_L [deg]';
                inputs.phi.title.string = 'phi_L [deg]';
            else
                inputs.theta.title.string = 'pol. angle [deg]';
                inputs.phi.title.string = 'tor. angle [deg]';
            end
            %
            inputs.bt.clear.string = 'Clear';
            inputs.zp.clear.string = 'Clear';
            inputs.theta.clear.string = 'Clear';
            inputs.phi.clear.string ='Clear';
            %
            inputs.bt.reset.string = 'Reset';
            inputs.zp.reset.string = 'Reset';
            inputs.theta.reset.string = 'Reset';
            inputs.phi.reset.string ='Reset';
            %
%             targets..title.string = '';
            targets.rho.title.string = 'r/a (psiP)';% [sqrt(psi/psia)]
            targets.theta.title.string = 'theta [deg]';
            targets.npar.title.string = 'n//';
            %
%             targets..val.string = '';
            targets.rho.val.string = '';
            targets.theta.val.string = '';
            targets.npar.val.string = '';            
            %
%             targets..clear.string = 'Clear';
            targets.rho.clear.string = 'Clear';
            targets.theta.clear.string = 'Clear';
            targets.npar.clear.string ='Clear';
            %
%             targets..reset.string = 'Reset';
            targets.rho.reset.string = 'Reset';
            targets.theta.reset.string = 'Reset';
            targets.npar.reset.string ='Reset';
            %
            run.string = 'Run';
%             guess.string = 'Guess';
            optim.string = 'Optimize';
            finish.string = 'Return';
            %
            inputs.bt.title.position = [style.buthsep,4*style.butvsep + 3*style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            inputs.bt.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
            inputs.bt.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
            inputs.bt.reset.position = [columnwidth - style.buthsep - style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
            %
            inputs.zp.title.position = [style.buthsep,3*style.butvsep + 2*style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            inputs.zp.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            inputs.zp.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            inputs.zp.reset.position = [columnwidth - style.buthsep - style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            %
            inputs.theta.title.position = [style.buthsep,2*style.butvsep + style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            inputs.theta.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            inputs.theta.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            inputs.theta.reset.position = [columnwidth - style.buthsep - style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            %
            inputs.phi.title.position = [style.buthsep,style.butvsep + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            inputs.phi.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,style.butvsep,style.butwidth,style.butheight];
            inputs.phi.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,style.butvsep,style.butwidth,style.butheight];
            inputs.phi.reset.position = [columnwidth - style.buthsep - style.butwidth,style.butvsep,style.butwidth,style.butheight];
            %
            %
%             targets..title.position = [style.buthsep,4*style.butvsep + 3*style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
%             targets..val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
%             targets..clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
%             targets..reset.position = [columnwidth - style.buthsep - style.butwidth,4*style.butvsep + 3*style.butheight,style.butwidth,style.butheight];
            %
            targets.rho.title.position = [style.buthsep,3*style.butvsep + 2*style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            targets.rho.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            targets.rho.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            targets.rho.reset.position = [columnwidth - style.buthsep - style.butwidth,3*style.butvsep + 2*style.butheight,style.butwidth,style.butheight];
            %
            targets.theta.title.position = [style.buthsep,2*style.butvsep + style.butheight + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            targets.theta.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            targets.theta.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            targets.theta.reset.position = [columnwidth - style.buthsep - style.butwidth,2*style.butvsep + style.butheight,style.butwidth,style.butheight];
            %
            targets.npar.title.position = [style.buthsep,style.butvsep + style.textheightcorr,columnwidth - 5*style.buthsep - 2*style.butwidth - style.butwidth,style.butheight];
            targets.npar.val.position = [columnwidth - 3*style.buthsep - 2*style.butwidth - style.butwidth,style.butvsep,style.butwidth,style.butheight];
            targets.npar.clear.position = [columnwidth - 2*style.buthsep - 2*style.butwidth,style.butvsep,style.butwidth,style.butheight];
            targets.npar.reset.position = [columnwidth - style.buthsep - style.butwidth,style.butvsep,style.butwidth,style.butheight];
            % 
            %
            run.position = [style.buthsep,4*style.butvsep + 3*style.butheight,style.longbutwidth,style.butheight];
%             guess.position = [style.buthsep,3*style.butvsep + 2*style.butheight,style.longbutwidth,style.butheight];
%             optim.position = [style.buthsep,2*style.butvsep + style.butheight,style.longbutwidth,style.butheight];
            optim.position = [style.buthsep,3*style.butvsep + 2*style.butheight,style.longbutwidth,style.butheight];
            finish.position = [style.buthsep,style.butvsep,style.longbutwidth,style.butheight];
            %   
            %
            %
            inputs.handle = uipanel('Parent',select.opt_gui,'Title',inputs.string,'units','pixels','Position',inputs.position);
            targets.handle = uipanel('Parent',select.opt_gui,'Title',targets.string,'units','pixels','Position',targets.position);
            controls.handle = uipanel('Parent',select.opt_gui,'Title',controls.string,'units','pixels','Position',controls.position);
            info.handle = uicontrol(select.opt_gui,'Style','text','String',infostr,'Position',info.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            %
            inputs.bt.title.handle = uicontrol(inputs.handle,'Style','text','String',inputs.bt.title.string,'Position',inputs.bt.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            inputs.zp.title.handle = uicontrol(inputs.handle,'Style','text','String',inputs.zp.title.string,'Position',inputs.zp.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            inputs.theta.title.handle = uicontrol(inputs.handle,'Style','text','String',inputs.theta.title.string,'Position',inputs.theta.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            inputs.phi.title.handle = uicontrol(inputs.handle,'Style','text','String',inputs.phi.title.string,'Position',inputs.phi.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            %
            inputs.bt.val.handle = uicontrol(inputs.handle,'Style','edit','Position',inputs.bt.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            inputs.zp.val.handle = uicontrol(inputs.handle,'Style','edit','Position',inputs.zp.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            inputs.theta.val.handle = uicontrol(inputs.handle,'Style','edit','Position',inputs.theta.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            inputs.phi.val.handle = uicontrol(inputs.handle,'Style','edit','Position',inputs.phi.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            %
            inputs.bt.clear.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.bt.clear.string,'Position',inputs.bt.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.zp.clear.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.zp.clear.string,'Position',inputs.zp.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.theta.clear.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.theta.clear.string,'Position',inputs.theta.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.phi.clear.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.phi.clear.string,'Position',inputs.phi.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            %
            inputs.bt.reset.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.bt.reset.string,'Position',inputs.bt.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.zp.reset.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.zp.reset.string,'Position',inputs.zp.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.theta.reset.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.theta.reset.string,'Position',inputs.theta.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            inputs.phi.reset.handle  = uicontrol(inputs.handle,'Style','pushbutton','String',inputs.phi.reset.string,'Position',inputs.phi.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            %
%             targets..title.handle = uicontrol(targets.handle,'Style','text','String',targets..title.string,'Position',targets..title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            targets.rho.title.handle = uicontrol(targets.handle,'Style','text','String',targets.rho.title.string,'Position',targets.rho.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            targets.theta.title.handle = uicontrol(targets.handle,'Style','text','String',targets.theta.title.string,'Position',targets.theta.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            targets.npar.title.handle = uicontrol(targets.handle,'Style','text','String',targets.npar.title.string,'Position',targets.npar.title.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            %
%             targets..val.handle = uicontrol(targets.handle,'Style','edit','Position',targets..val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            targets.rho.val.handle = uicontrol(targets.handle,'Style','edit','Position',targets.rho.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            targets.theta.val.handle = uicontrol(targets.handle,'Style','edit','Position',targets.theta.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            targets.npar.val.handle = uicontrol(targets.handle,'Style','edit','Position',targets.npar.val.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',@setval_cbf);
            %
%             targets..clear.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets..clear.string,'Position',targets..clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.rho.clear.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.rho.clear.string,'Position',targets.rho.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.theta.clear.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.theta.clear.string,'Position',targets.theta.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.npar.clear.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.npar.clear.string,'Position',targets.npar.clear.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            %
%             targets..reset.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets..reset.string,'Position',targets..reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.rho.reset.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.rho.reset.string,'Position',targets.rho.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.theta.reset.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.theta.reset.string,'Position',targets.theta.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            targets.npar.reset.handle  = uicontrol(targets.handle,'Style','pushbutton','String',targets.npar.reset.string,'Position',targets.npar.reset.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@setval_cbf);
            %
            run.handle  = uicontrol(controls.handle,'Style','pushbutton','String',run.string,'Position',run.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@pushbutton_cbf);
%             guess.handle  = uicontrol(controls.handle,'Style','pushbutton','String',guess.string,'Position',guess.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@pushbutton_cbf);
            optim.handle  = uicontrol(controls.handle,'Style','pushbutton','String',optim.string,'Position',optim.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@pushbutton_cbf);
            finish.handle  = uicontrol(controls.handle,'Style','pushbutton','String',finish.string,'Position',finish.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',@pushbutton_cbf);
            %
            inputs.handles = [inputs.bt.val.handle,inputs.zp.val.handle,inputs.theta.val.handle,inputs.phi.val.handle];
            targets.handles = [targets.rho.val.handle,targets.theta.val.handle,targets.npar.val.handle];
            %
            inputs.clearhandles = [inputs.bt.clear.handle,inputs.zp.clear.handle,inputs.theta.clear.handle,inputs.phi.clear.handle];
            inputs.resethandles = [inputs.bt.reset.handle,inputs.zp.reset.handle,inputs.theta.reset.handle,inputs.phi.reset.handle];
            targets.clearhandles = [targets.rho.clear.handle,targets.theta.clear.handle,targets.npar.clear.handle];
            targets.resethandles = [targets.rho.reset.handle,targets.theta.reset.handle,targets.npar.reset.handle];            
            %
            opt_info = true;
            %
        else
            opt_gui = true;
            opt_info = false;
        end
    else
        opt_gui = false;
        opt_info = false;
    end
    %
    exit_loop = 0;    
    optim_done = 0;
    %
    optim.tolfun = 1e-3;% tolerance on targets (in m)
    optim.tolx = 1e-3;% tolerance on inputs (in m)
    optim.nitmax = 20;%
    %
    inputs.resetval = cell(1,length(inputs.resethandles));
    targets.resetval = cell(1,length(targets.resethandles));
    %
    while exit_loop == 0,
        %
        if ~any(isnan(ninputs)),% all inputs defined or calculated
            %
            ninputs_init = ninputs;
            %
            set(finish.handle,'Enable','on');
            set(run.handle,'Enable','on');
            if optim_done == 1,
                set(finish.handle,'BackgroundColor',[0 0.75 0]);
                set(run.handle,'BackgroundColor',[0.701961 0.701961 0.701961]);
            else
                set(finish.handle,'BackgroundColor',[0.701961 0.701961 0.701961]);
                set(run.handle,'BackgroundColor',[0 0.75 0]);
            end
            set(optim.handle,'Enable','off','BackgroundColor',[0.701961 0.701961 0.701961]);
        else
            set(finish.handle,'Enable','off','BackgroundColor',[0.701961 0.701961 0.701961]);
            set(run.handle,'Enable','off','BackgroundColor',[0.701961 0.701961 0.701961]);
            %
            if sum(isnan(ninputs)) + sum(isnan(ntargets)) == 3,
                set(optim.handle,'Enable','on','BackgroundColor',[0 0.75 0]);
                %
                set(info.handle,'String',infostr,'Fontweight','normal');
            else
                set(optim.handle,'Enable','off','BackgroundColor',[0.701961 0.701961 0.701961]);
                %
                set(info.handle,'String',infostr2,'Fontweight','bold');
            end
            %
        end
        %
        for ihandle = 1:length(inputs.handles),
            if isnan(ninputs(ihandle)),
                set(inputs.clearhandles(ihandle),'Enable','off');
                if ~isempty(inputs.resetval{ihandle}),
                    set(inputs.resethandles(ihandle),'Enable','on');
                else
                    set(inputs.resethandles(ihandle),'Enable','off');
                end
            else
                set(inputs.clearhandles(ihandle),'Enable','on');
                set(inputs.resethandles(ihandle),'Enable','off');
            end
        end
        %
        for ihandle = 1:length(targets.handles),
            if isnan(ntargets(ihandle)),
                set(targets.clearhandles(ihandle),'Enable','off');
                if ~isempty(targets.resetval{ihandle}),
                    set(targets.resethandles(ihandle),'Enable','on');
                else
                    set(targets.resethandles(ihandle),'Enable','off');
                end
            else
                set(targets.clearhandles(ihandle),'Enable','on');
                set(targets.resethandles(ihandle),'Enable','off');
            end
        end
        %
        set(inputs.bt.val.handle,'String',num2str(ninputs(1*find(~isnan(ninputs(1))))));
        set(inputs.zp.val.handle,'String',num2str(ninputs(2*find(~isnan(ninputs(2))))));
        set(inputs.theta.val.handle,'String',num2str(180/pi*ninputs(3*find(~isnan(ninputs(3))))));
        set(inputs.phi.val.handle,'String',num2str(180/pi*ninputs(4*find(~isnan(ninputs(4))))));
        %
        set(targets.rho.val.handle,'String',num2str(ntargets(1*find(~isnan(ntargets(1))))));
        set(targets.theta.val.handle,'String',num2str(180/pi*ntargets(2*find(~isnan(ntargets(2))))));
        set(targets.npar.val.handle,'String',num2str(ntargets(3*find(~isnan(ntargets(3))))));
        %
        uiwait;
        %
    end
    %
    if wavestruct_out.equil.Zp ~= ninputs(2),
        wavestruct_out.equil.Zp = ninputs(2);
        flag_Zp = true;
    else
        flag_Zp = false;
    end
    %
    if opt_angles,
        wavestruct_out.launch.angles.freq = wavestruct_out.launch.angles.freq*abs(wavestruct_out.equil.ptBPHI(1,1))/ninputs(1);
        wavestruct_out.launch.angles.theta = ninputs(3);
        wavestruct_out.launch.angles.phi = ninputs(4);
        %
        wavestruct_out.launch = imake_launch_angles_TCV_jd(wavestruct_out.launch.angles);
    else
        wavestruct_out.launch.omega_rf = wavestruct_out.launch.omega_rf*abs(wavestruct_out.equil.ptBPHI(1,1))/ninputs(1);
        wavestruct_out.launch.ybeta_L = pi/2 - ninputs(3);
        if ninputs(4) > 0,
        	wavestruct_out.launch.yalpha_L = ninputs(4) - pi;
        else
        	wavestruct_out.launch.yalpha_L = ninputs(4) + pi;
        end            
    end        
    %
    if opt_info,
        delete(inputs.handle);
        delete(targets.handle);
        delete(controls.handle);
        delete(info.handle);
        %
        delete(select.opt.axs(1))
        delete(select.opt.axs(2))
        delete(select.opt.axs(3))
    end
    %
    function setval_cbf(hObject,eventdata)
        %
        optim_done = 0;
        %
        if any(hObject == inputs.clearhandles),
            hObject = inputs.handles(hObject == inputs.clearhandles);
            inputs.resetval{hObject == inputs.handles} = get(hObject,'String');
            set(hObject,'String','');
        elseif any(hObject == targets.clearhandles),
            hObject = targets.handles(hObject == targets.clearhandles);
            targets.resetval{hObject == targets.handles} = get(hObject,'String');
            set(hObject,'String','');
        elseif any(hObject == inputs.resethandles),
            hObject = inputs.handles(hObject == inputs.resethandles);
            set(hObject,'String',inputs.resetval{hObject == inputs.handles});
        elseif any(hObject == targets.resethandles),
            hObject = targets.handles(hObject == targets.resethandles);
            set(hObject,'String',targets.resetval{hObject == targets.handles});
        end
        %
        if any(hObject == inputs.handles),
            if any(hObject == inputs.handles(3:4)),%angle
                ninputs(hObject == inputs.handles) = pi/180*str2double(get(hObject,'String'));
            else
                ninputs(hObject == inputs.handles) = str2double(get(hObject,'String'));
            end
        elseif any(hObject == targets.handles),
            if hObject == targets.handles(2),%angle
                ntargets(hObject == targets.handles) = pi/180*str2double(get(hObject,'String'));
            else
                ntargets(hObject == targets.handles) = str2double(get(hObject,'String'));
            end
        end
        %
        uiresume;
        %
    end
    %
    function pushbutton_cbf(hObject,eventdata)
        %
        set(info.handle,'String',infostr,'Fontweight','normal');
        %
        cla(select.opt.axs(1));
        cla(select.opt.axs(2));
        cla(select.opt.axs(3));
        %
        wave = [];
        %
        optim_done = 0;
        %
        if hObject == finish.handle,
            %
            exit_loop = 1;
            %
        elseif hObject == run.handle,
            %
            set(select.busyhandle,'Visible','on');drawnow;
            %
            [~,wave] = calc_delta_jd([],ninputs,[],dkepath,wavestruct,opt_angles);
            %
            set(select.busyhandle,'Visible','off');drawnow;
            %
            if isempty(wave),
                set(info.handle,'String',infostr3,'Fontweight','bold');
            end
            %
        elseif hObject == optim.handle,
            %
            ninputs_mask = isnan(ninputs);
            %
            set(select.busyhandle,'Visible','on');drawnow;
            %
            [Xopt,delta] = fminsearch(@(X) calc_delta_jd(X,ninputs,ntargets,dkepath,wavestruct,opt_angles),ninputs_init(ninputs_mask),...
                optimset('TolFun',optim.tolfun,'TolX',optim.tolx,'MaxIter',optim.nitmax));
            %
            set(select.busyhandle,'Visible','off');drawnow;
            %
            ninputs(ninputs_mask) = Xopt;
            %
            [~,wave] = calc_delta_jd([],ninputs,[],dkepath,wavestruct,opt_angles);
            %
            optim_done = 1;
            %
        end
        %
        if ~isempty(wave),
            %
            % The location of ray damping is defined where the absorbed power
            % is half the total absorbed power (which can be less than 1)
            %
            [~,ntargets] = delta_wave_optim_jd(wave,wavestruct.equil_fit,[]);
            %
            graph_wave_jd(wavestruct.equil,{wave},select.opt.nr_dep,select.opt,select.opt.rho_disp,select.opt.ymask,select.opt.xvar);
            %
        end
        %
        uiresume;
        %
    end
    %
end
%    
function [delta,wave] = calc_delta_jd(X,ninputs,ntargets,dkepath,wavestruct,opt_angles)
    %
    ninputs_mask = isnan(ninputs);
    %
    ninputs(ninputs_mask) = X;
    %
    wavestruct.equil.Zp = ninputs(2);
    wavestruct.equil_fit.Zp = ninputs(2);
    %
    if opt_angles,
        wavestruct.launch.angles.freq = wavestruct.launch.angles.freq*abs(wavestruct.equil.ptBPHI(1,1))/ninputs(1);
        wavestruct.launch.angles.theta = ninputs(3);
        wavestruct.launch.angles.phi = ninputs(4);
        %
        wavestruct.launch = imake_launch_angles_TCV_jd(wavestruct.launch.angles);
    else
        wavestruct.launch.omega_rf = wavestruct.launch.omega_rf*abs(wavestruct.equil.ptBPHI(1,1))/ninputs(1);
        wavestruct.launch.ybeta_L = pi/2 - ninputs(3);
        if ninputs(4) > 0,
        	wavestruct.launch.yalpha_L = ninputs(4) - pi;
        else
        	wavestruct.launch.yalpha_L = ninputs(4) + pi;
        end            
    end
    %
    wave = wave_solver_yp(dkepath,wavestruct,[]);
    %
    if isempty(wave.rays),
        wave = [];
        delta = 1;
    else        
        %
        if ~isempty(ntargets),
            delta = delta_wave_optim_jd(wave,wavestruct.equil_fit,ntargets);
            %
            disp(' ');
            disp(['---> delta : ',num2str(delta),' ; norm(X) : ',num2str(norm(X))]);
            %
        else
            delta = [];
        end
    end
    %
end

