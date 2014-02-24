function shotdata = iget_datainput_TCV(diagnames,workdir,opt_gui,style)
%
% GUI or command line inputs for TCV database query
%
if nargin < 3,
    style = struct;
end
if nargin < 2,
    opt_gui = true;
end
if nargin < 1,
    workdir = pwd;
end
%
if ~isfield(style,'fontname'),
    style.fontname = 'Liberation Mono';%get(0,'FixedWidthFontName');%'fixedwidth';% font type
end
if ~isfield(style,'fontsize'),
    style.fontsize = 14;% font size
end
%
opt_full = false;
shotdata = struct;
%
ndiag = length(diagnames);
%
% strings
%
timestxt = 'LUKE Simulation time vector. Leave empty to select TS points with Ip > Ipmax/2.';
dtmaxtxt = 'Maximum time range for data averaging. Leave empty to select TS time interval';
iseltxt = 'ECRH launchers : Leave empty to select all launchers (1 -> 9).';
%
if ~opt_full,% simplified interface
    %
    shotdata.shotnum = 0;
    shotdata.times = [];
    shotdata.dtmax = [];
    shotdata.outputdir = '';
    shotdata.isel = [];
    %
    shotdata.expert.shotnum = 0;
    shotdata.expert.times = 0;
    shotdata.expert.dtmax = 0;
    shotdata.expert.outputdir = 0;
    shotdata.expert.isel = 0;
    %
    shotdata.values.shotnum = [0;Inf];
    shotdata.values.times = [0;Inf];
    shotdata.values.dtmax = [0;Inf];
    shotdata.values.outputdir = '';
    shotdata.values.isel = [0;6];%[0;9];%
    %
    shotdata.info.shotnum = 'Shot number';
    shotdata.info.times = timestxt;
    shotdata.info.dtmax = dtmaxtxt;
    shotdata.info.outputdir = 'Output Directory. Leave empty to use default tmp folder';
    shotdata.info.isel = iseltxt;
    %
    shotdata = imod_struct_jd(shotdata,'shotdata',0,opt_gui,shotdata,style);
    %
else% full interface
    %
    % strings
    %
    cgui.string = 'TCV database query';
    timetxt.string = timetxt_string;
    timeedit.string = '';
    outputdirtxt = 'Output Dir.';
    outputdirtxt.string = workdir;
    iseledit.string = '';
    diagtxt.string = 'Time vector & Output Dir. for each diag. Leave empty to select default values above';
    diagtimetxt = 'time vector';
    defaultdiagtime = '';
    ok.string = 'OK';
    reset.string = 'RESET';
    %
    for idiag = ndiag,
        %
        diagoutputdirtxt(idiag).string = '';
        %
    end
    %
    % callbacks
    %
    outputdirsel.callback = 'outputdirtxt.string == uigetdir(outputdirtxt.string,''Please select output directory'');';
    ok.callback = 'uiresume;';
    reset.callback = 'uiresume;';
    %
    % positions
    %
    cgui.position
    timetxt.position
    timeedit.position
    outputdirsel.position
    outputdirtxt.position
    iseltxt.position
    iseledit.position
    diagtxt.position
    ok.position
    reset.position
    %
    for idiag = ndiag,
        %
        diagtitle(idiag).position
        diagtimetxt(idiag).position
        diagtimeedit(idiag).position
        diagoutputdirsel(idiag).position
        diagoutputdirtxt(idiag).position
        %
    end
    %
    if opt_gui,% GUI
        %
        cgui.handle = figure('name',cgui.string,'visible','on','menubar','none','numbertitle','off','resize','off','Position',cgui.position,'toolbar','none','units','pixels');
        %
        timetxt.handle = uicontrol(cgui,'Style','text','String',timetxt.string,'Position',timetxt.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
        timeedit.handle = uicontrol(cgui,'Style','edit','String',timeedit.string,'Position',timeedit.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        outputdirsel.handle = uicontrol(cgui,'Style','pushbutton','String',outputdirtxt,'Position',outputdirsel.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',outputdirsel.callback);
        outputdirtxt.handle = uicontrol(cgui,'Style','text','String',outputdirtxt.string,'Position',outputdirtxt.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
        %
        iseltxt.handle = uicontrol(cgui,'Style','text','String',iseltxt.string,'Position',iseltxt.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
        iseledit.handle = uicontrol(cgui,'Style','edit','String',iseledit.string,'Position',iseledit.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        diagtxt.handle = uicontrol(cgui,'Style','text','String',diagtxt.string,'Position',diagtxt.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
        %
        for idiag = ndiag,
            diagtitle(idiag).handle = uicontrol(cgui,'Style','text','String',diagnames{idiag},'Position',diagtitle(idiag).position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            %
            diagtimetxt(idiag).handle = uicontrol(cgui,'Style','text','String',diagtimetxt,'Position',diagtimetxt(idiag).position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            diagtimeedit(idiag).handle = uicontrol(cgui,'Style','edit','String',defaultdiagtime,'Position',diagtimeedit(idiag).position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            %
            diagoutputdirsel(idiag).handle = uicontrol(cgui,'Style','pushbutton','String',outputdirtxt,'Position',diagoutputdirsel(idiag).position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',outputdirsel.callback);
            diagoutputdirtxt(idiag).handle = uicontrol(cgui,'Style','text','String',diagoutputdirtxt(idiag).string,'Position',diagoutputdirtxt(idiag).position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
        end
        %
        ok.handle = uicontrol(p,'Style','pushbutton','String',ok.string,'Position',ok.position,'FontName',style.fontname,'FontSize',style.fontsize,'Callback',ok.callback);            
        reset.handle = uicontrol(p,'Style','pushbutton','String',reset.string,'Position',reset.position,'FontName',style.fontname,'FontSize',style.fontsize,'Callback',reset.callback);            
        %
    else
        %
        % TODO
        %
    end
end

