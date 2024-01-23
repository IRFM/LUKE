classdef slukeGUI < handle
    %% DINAMIC PROPERTIES
    properties (Access = public)
        sparams
    end
    properties %(Access = private) %%%%%%%%%%%%%%%%%%%%
        fig             %figure handle
        panel           % central panel handle
        tree            % tree handle
        tabGroup        % tab handle
        line            % array of struct of handles
        rushMode        % bool, if true suppress action checks
        changedSparams  % bool, if true last uploaded sparams has been change
        permission     % bool, if true it has writing permission in current folder
    end
    %% CONSTANT PROPERTIES
    properties (Constant,Access = private)
        
        lineWidth = 20;     % Width of lines in tabs in pixel    LINE SPACING = LINEPERIOD - LINEWIDTH
        linePeriod = 25;    % Line period in tabs in pixel
        lineIndent = 10;    % Indentation of lines in tabs in pixel
        imgButtonDim = 19;  % Both dimentions' size of BOL button in pixel
        labelWidth = 120;   % Width of label
        
        removeImg = 'Icon/remove.png';   %Image for remove button
        addImg    = 'Icon/add.png';      %Image for add butotn
        modifyImg = 'Icon/pencil.png';   %Image for modify button
        copyImg   = 'Icon/copy.png';     %Image for copy button
        helpImg   = 'Icon/technical.png' %Image for icon in help uiallert
        bugImg    = 'Icon/scan.png'%Image for icon in help>reportBug uiallert
    end
    %% PUBLIC METHODS
    methods (Access = public)
        function obj = slukeGUI(sparams)
            % obj = slueGUI()
            % obj = slukeGUI(sparams)
            % Contstructor of slukeGUI class. As an input (optional): the
            % struct whanted to display. If any is specified it is created
            % through the function sluke_params_default
            
            if exist('sparams','var')
                if isa(sparams,'struct')
                    obj.sparams = sparams;
                elseif ischar(sparams) || isstring(sparams)
                    try
                        obj.sparams = obj.runMakeSparams(sparams);
                    catch ME
                        warning(['Not able to load ' sparams '.' ME.message,...
                            '. Default sparams is used.']);
                        obj.sparams = sluke_params_defaults();
                    end
                end
            else
                obj.sparams = sluke_params_defaults();
            end
            
            obj.createGUI();
            
            obj.rushMode = false;
            obj.changedSparams = false;
            obj.permission = test_permissions_yp();
        end
        %Sluke
        function sluke(obj,source,~)
            % obj.sluke()
            % launch sluke routine in user selected folder
            if obj.permission
                slukeGo = obj.check4Action({'Launch sluke?','Please, be sure that inputs, if needed, are accessible in or from selected folder'},...
                    'Icon','question','Options',{'Cancel','Select folder','Launch in current folder'},'DefaultOption',3,'CancelOption',1);
            else
                slukeGo = obj.check4Action({'Launch sluke?','Please, be sure that inputs, if needed, are accessible in or from selected folder'},...
                    'Icon','question','Options',{'Cancel','Select folder'},'DefaultOption',2,'CancelOption',1);
            end
            switch slukeGo
                case 0 %canels
                    return
                case 1 %select folder
                    currentPath = pwd;
                    simPath = obj.changePath();
                    comeback = true;
                case 2 %launch in current folder
                    simPath = pwd;
                    comeback = false;
            end
            
            if isa(simPath,'double')
                return
            end
            
            if ~obj.permission
                uialert(obj.fig,{['You do not have writing permission in the folder',simPath],'SLUKE wont be launched'},'No writing permission');
                return
            end
            
            try
                obj.sendAlert({'Sluke is launched. Check command window to follow its output.'});
                if isa(source,'struct')
                    sluke(source,mfilename);
                else
                    sluke(obj.sparams,mfilename);
                end
            catch ME
                uialert(obj.fig,{'sluke encoutered the following error:' ME.message},'sluke error');
            end
            if comeback
                cd(currentPath)
            end
        end
        
        function slukePreambule(obj,~,~)
            try
                %obj.slukePreambule()
                % launch sluke routine in user selected folder. Before of that
                % it runs user selected script. The fuction contains sluke
                % struct as sparams.
                filter = {'*.m';'*.*'};
                [file,path] = uigetfile(filter,'File selection...');
                
                iPoint = find(file == '.',1);
                if ~isempty(iPoint),    extention = file(iPoint:end);
                else,                   extention = '.?';
                end
                sparams = obj.sparams;  %#ok<*PROPLC>
                if ~strcmp(extention,'.m')
                    error('SlukeGUI:getFile:wrongExtention',"Selected file %s in path has not the right extention.\n Please, select only .m files .",file,path);
                end
                obj.checkScript(path,file);
                try
                    run([path file])
                catch ME
                    ME.Identifier = ['SlukeGUI:getFile:Script:' ME.Identifier];
                    rethrow(ME);
                end
                obj.checkConsistent(sparams)
                obj.sluke(sparams)
            catch ME
                uialert(obj.fig,ME.message,'Error Message');
            end
        end
    end
    %% PRIVATE METHODS
    methods (Access = private)
        function createGUI(obj)
            %figure
            screensize = obj.screensize();
            position = [screensize/4,screensize/2];
            obj.fig = uifigure('Name','Sluke_launcher','ToolBar','none','Tag','Figure',...
                'Position',position,'Visible','off','CloseRequestFcn', @obj.closingFigure,...
                'Resize','off');
            
            %menu
            obj.makeMenu();
            
            %tree
            obj.tree = uitree(obj.fig, 'Position', [0,0,position(3)/3,position(4)],...
                'SelectionChangedFcn',@obj.changeSubstruct);
            obj.makeNodes();
            expand(obj.tree);
            
            %tab
            obj.tabGroup = uitabgroup(obj.fig,...
                'Position',[position(3)/3,0,2/3*position(3),position(4)],...
                'SelectionChangedFcn',@obj.refillTab);
            uitab(obj.tabGroup,'Title','Sim1','Scrollable','on','Tag','1');
            obj.fillTab();
            for i=2:obj.nSim
                obj.addTab()
            end
            
            obj.fig.Visible = 'on';
        end
        %Menu
        function makeMenu(obj)
            %tab
            tabMenu = uimenu(obj.fig,'Text','tab');
            uimenu(tabMenu,'Text','Clone current tab','MenuSelectedFcn',@obj.addNewTab);
            uimenu(tabMenu,'Text','Remove current tab','MenuSelectedFcn',@obj.removeTab);
            
            %sparams
            sparamsMenu = uimenu(obj.fig,'Text','sparams');
            uimenu(sparamsMenu,'Text','load sparams','MenuSelectedFcn',@obj.loadSparams);
            uimenu(sparamsMenu,'Text','load default sparams','MenuSelectedFcn',@obj.defaultSparams);
            uimenu(sparamsMenu,'Text','duplicate current substruct','MenuSelectedFcn',@obj.duplicateSubstruct);
            %uimenu(sparamsMenu,'Text','compare sparams','MenuSelectedFcn',@obj.holdplace);
            
            %sluke
            slukeMenu = uimenu(obj.fig,'Text','SLUKE');
            uimenu(slukeMenu,'Text','launch SLUKE', 'MenuSelectedFcn', @obj.sluke);
            uimenu(slukeMenu,'Text','launch SLUKE with preambule...','MenuSelectedFcn',@obj.slukePreambule);
            
            saveMenu = uimenu(obj.fig,'Text','save');
            uimenu(saveMenu,'Text','save as script', 'MenuSelectedFcn', @obj.saveSparams,'Tag','ScriptSaveMenu');
            uimenu(saveMenu,'Text','save as variable', 'MenuSelectedFcn', @obj.saveSparams,'Tag','VariableSaveMenu');
            
            rushMenu = uimenu(obj.fig,'Text','r&ush');
            uimenu(rushMenu,'Text','&rush Mode','Checked','off','MenuSelectedFcn',@obj.changeRushMode,'Accelerator','R');
            
            pathMenu = uimenu(obj.fig,'Text','path');
            uimenu(pathMenu,'Text','change path','MenuSelectedFcn',@obj.changePath);
            
            helpMenu = uimenu(obj.fig,'Text','help');
            faqMenu = uimenu(helpMenu,'Text','F.A.Q.');
            %
            tabMenu = uimenu(faqMenu,'Text','tab');
            uimenu(tabMenu,'Text','What are tabs for?','MenuSelectedFcn',{@obj.help,'tab.tab'});
            %
            sparamsMenu = uimenu(faqMenu, 'Text', 'sparams' );
            uimenu(sparamsMenu,'Text','What will load sparams?','MenuSelectedFcn',{@obj.help,'sparams.load'});
            uimenu(sparamsMenu,'Text','What format must the script be to load sparams?','MenuSelectedFcn',{@obj.help,'sparams.script'});
            uimenu(sparamsMenu,'Text','What format must the variable be to load sparams?','MenuSelectedFcn',{@obj.help,'sparams.variable'});
            uimenu(sparamsMenu,'Text','What is default sparams?','MenuSelectedFcn',{@obj.help,'sparams.default'});
            %
            slukeMenu = uimenu(faqMenu,'Text','SLUKE');
            %uimenu(slukeMenu,'Text','What is SLUKE?','MenuSelectedFcn',{@obj.help,'sluke.sluke'});
            uimenu(slukeMenu,'Text','launch SLUKE with preambule?','MenuSelectedFcn',{@obj.help,'sluke.preambule'});
            %
            saveMenu = uimenu(faqMenu,'Text','save');
            uimenu(saveMenu,'Text','How it is saved as a script?','MenuSelectedFcn',{@obj.help,'save.script'});
            uimenu(saveMenu,'Text','How it is saved as a variable?','MenuSelectedFcn',{@obj.help,'save.variable'});
            %
            rushMenu = uimenu(faqMenu,'Text','rush mode');
            uimenu(rushMenu,'Text','What is rush mode?','MenuSelectedFcn',{@obj.help,'rush'});
            %
            controlMenu = uimenu(faqMenu,'Text','controls');
            uimenu(controlMenu,'Text','Is there any control on my input in sparams?','MenuSelectedFcn',{@obj.help,'control'});
            %
            uimenu(helpMenu,'Text','I am desperate','MenuSelectedFcn',{@obj.help,'desperate'});
            %
            uimenu(helpMenu,'Text','Report a bug','MenuSelectedFcn',{@obj.help,'reportbug'})
            %
            uimenu(helpMenu,'Text','Credits','MenuSelectedFcn',{@obj.help,'credits'})
        end
        %Nodes
        function makeNodes(obj,startpoint)
            % Can be probably written better
            if ~exist('startpoint','var') || isempty(startpoint)
                node = uitreenode(obj.tree,'Text','params','NodeData',{});
                obj.tree.SelectedNodes = node;
            else
                node = startpoint;
            end
            
            struct = obj.sparams;
            
            oldLayer = {node};
            while 1
                nNewLayer = 0;
                for iOL = 1:length(oldLayer)
                    address = oldLayer{iOL}.NodeData;
                    if isempty(address), subfields = fieldnames(struct);
                    else,                subfields = fieldnames(getfield(struct,address{:}));
                    end
                    for iNL = 1:length(subfields)
                        newAddress = [address, subfields(iNL)];
                        if isstruct(getfield(struct,newAddress{:}))
                            nNewLayer = nNewLayer + 1;
                        end
                    end
                end
                
                if nNewLayer == 0
                    break
                end
                
                newLayer = cell(nNewLayer,1);
                iNL = 1;
                for iOL = 1:length(oldLayer)
                    address = oldLayer{iOL}.NodeData; % I am sure that is a node of a substruct, otherwise would have been skipped
                    if isempty(address), subfields = fieldnames(struct);
                    else,                subfields = fieldnames(getfield(struct,address{:})); end
                    for j = 1:length(subfields)
                        newAddress = [address, subfields(j)];
                        if isstruct(getfield(struct,newAddress{:}))
                            newLayer{iNL} = uitreenode(oldLayer{iOL},'Text', subfields{j}, ...
                                'NodeData',newAddress);
                            iNL = iNL + 1;
                        end
                        
                    end
                end
                oldLayer = newLayer;
            end
        end
        
        function changeSubstruct(obj,source,~)
            if isa(source,'matlab.ui.control.Button')
                childrenNodes = obj.tree.SelectedNodes.Children;
                
                for i = 1:length(childrenNodes)
                    if strcmp(childrenNodes(i).Text,source.Text)
                        obj.tree.SelectedNodes = childrenNodes(i);
                        break
                    end
                end
            elseif isa(source,'matlab.ui.container.Menu')
                collapse(obj.tree.SelectedNodes)
                obj.tree.SelectedNodes = obj.tree.SelectedNodes.Parent;
            end
            expand(obj.tree.SelectedNodes);
            obj.refillTab();
        end
        
        function correctStruct(obj,source,event)
            if isstrprop(source.Tag(1), 'digit')
                tag = source.Tag(2:end);
                type = str2double(source.Tag(1));
            else
                tag = source.Tag;
                type = NaN;
            end
            address = [obj.tree.SelectedNodes.NodeData, tag];
            sim = str2double(obj.tabGroup.SelectedTab.Tag);
            
            oldValue = getfield(obj.sparams,address{:});
            oldValue = oldValue{sim};
            if type == 2
                check = oldValue{type};
            else
                check = oldValue;
            end
            try
                if type == 0 %cames from general line
                    newValue = eval([source.Value ';']);
                elseif isa(check,'double')||isa(check,'logical')
                    newValue = str2num(source.Value);
                else
                    newValue = source.Value;
                end
                if type == 2
                    oldValue{type} = newValue;
                    newValue = oldValue;
                end
                obj.sparams = setfield(obj.sparams,address{:},{sim},{newValue});
                obj.changedSparams = true;
            catch ME
                uialert(obj.fig,ME.message,'Error occurred')
                source.Value = event.PreviousValue;
            end
            
        end
        
        function struct = currentStruct(obj)
            if isempty(obj.currentAddress())
                struct = obj.sparams;
            else
                struct = getfield(obj.sparams,obj.tree.SelectedNodes.NodeData{:});
            end
        end
        
        function duplicateSubstruct(obj,source,~)
            address = obj.currentAddress();
            if isempty(address)
                uialert(obj.fig,{'It is not possible to duplicate the whole params structure.','Please, select one substructure through the tree.','To create a second simulation create a new tab from tab menu'},'Error')
            else
                if length(address) == 1
                    parentStruct = obj.sparams;
                else
                    parentStruct = getfield(obj.sparams,address{1:end-1});
                end
                
                newAddress = address;
                i = 2;
                while isfield(parentStruct,newAddress{end})
                    newAddress{end} = [address{end} num2str(i)];
                    i = i + 1;
                end
                obj.sparams = setfield(obj.sparams, newAddress{:}, getfield(obj.sparams,address{:}));
                branch = obj.tree.SelectedNodes.Parent;
                newNode = uitreenode(branch,'Text',newAddress{end},'NodeData',newAddress);
                obj.makeNodes(newNode);
                obj.changeSubstruct(source);
                obj.modifyLine(source,'',newAddress{end});
                obj.changedSparams = true;
            end
        end
        
        function out = currentAddress(obj)
            out = obj.tree.SelectedNodes.NodeData;
        end
        
        function d = currentDeepness(obj)
            d = length(obj.tree.SelectedNodes.NodeData);
        end
        
        function n = findTreeIndex(obj,field)
            %returns 0 if it does not find anything.
            keepOn = 1;
            n = length(obj.tree.SelectedNodes.Children);
            while keepOn && n > 0
                keepOn = ~strcmp(obj.tree.SelectedNodes.Children(n).Text,field);
                n = n-1;
            end
            n = n + ~keepOn;
        end
        
        function changeNodeDataR(obj,node,newName,iNN)
            node.NodeData{iNN} = newName;
            children = node.Children;
            for i = 1:length(children)
                obj.changeNodeDataR(children(i),newName,iNN);
            end
        end
        %Tab
        function fillTab(obj,~,~)
            
            address = obj.currentAddress();
            if isempty(address),	currentStruct = obj.sparams;
            else,                   currentStruct = getfield(obj.sparams,address{:});
            end
            
            fields = fieldnames(currentStruct);
            nFields = length(fields);
            emptyLine = struct('name',[],'type',[],'button1',[],'button2',[],'label',[],'editfield',[],'editfield2',[],'editfield3',[],'button3',[]);
            obj.line = repmat(emptyLine,1,nFields);
            
            for i = 1:nFields
                if isstruct(currentStruct.(fields{i}))
                    type = 'Struct';
                elseif isa(currentStruct.(fields{i}){1},'cell')
                    if size(currentStruct.(fields{i}){1},2) == 2
                        type = 'Antenna';
                    else
                        type = 'General';
                    end
                else
                    type = 'Field';
                end
                obj.line(i) = obj.makeLine(type,currentStruct,fields{i},nFields+1,nFields-i+1); %there are nFields +1 entries (the add one)
            end
            obj.line(nFields+1) = obj.makeLine('NewField',currentStruct,' ',nFields+1,0);
        end
        
        function refillTab(obj,~,~)
            delete(obj.tabGroup.SelectedTab.Children)
            obj.fillTab()
        end
        
        function addNewTab(obj,~,~)
            sim = str2double(obj.tabGroup.SelectedTab.Tag);
            obj.sparams = sluke_params_clone(obj.sparams,sim,1);
            obj.addTab()
            obj.changedSparams = true;
        end
        
        function addTab(obj,~,~)
            nTab = length(obj.tabGroup.Children)+1;
            nSim = obj.nSim;
            if nTab > nSim
                error('SlukeGUI:addTab:emptyTab','Sparams has only %i entry and it has been attempted the creation of tab n° %i.',nSim,nTab)
            end
            newTab = uitab(obj.tabGroup,'Title',['Sim',num2str(nTab)],...
                'Scrollable','on','Tag',num2str(nTab));
            obj.tabGroup.SelectedTab = newTab;
            obj.fillTab();
        end
        
        function removeTab(obj,~,~)
            nTab = length(obj.tabGroup.Children);
            if nTab > 1
                currentTab = str2double(obj.tabGroup.SelectedTab.Tag);
                delete(obj.tabGroup.SelectedTab);
                obj.sparams = sluke_params_delete(obj.sparams,currentTab);
                for iTab = currentTab:nTab-1
                    obj.tabGroup.Children(iTab).Title = ['Sim',num2str(iTab)];
                    obj.tabGroup.Children(iTab).Tag = num2str(iTab);
                end
                newTab = max(currentTab-1,1);
                obj.tabGroup.SelectedTab = obj.tabGroup.Children(newTab);
                obj.refillTab();
            end
        end
        
        function resetTabGroup(obj,~,~)
            obj.tabGroup.SelectedTab = obj.tabGroup.Children(1);
            for i = length(obj.tabGroup.Children):-1:2
                delete(obj.tabGroup.Children(i))
            end
            obj.refillTab();
        end
        %Line
        function line = makeLine(obj,type,struct,field,Nfield,n)
            % n
            tab = obj.tabGroup.SelectedTab;
            %Position calculation
            totalWidth = (Nfield + 1) * obj.linePeriod - obj.lineWidth; %Nfield * lineperiod + (linespacing) + title (=2*lineperiod)
            if totalWidth > tab.InnerPosition(4)-10 % to take into account bar
                bottom = obj.linePeriod * n - obj.lineWidth;  %(n-1) * lineperiod + (linespacing)
            else
                bottom = tab.InnerPosition(4)-10 - totalWidth + obj.linePeriod * n  - obj.lineWidth;
            end
            
            line.name = field;
            line.type = type;
            
            switch type
                
                case 'Field'
                    %Delete Button
                    left = obj.lineIndent;
                    line.button1 = uibutton(tab,'Text','','Tooltip','Delete this field','Icon',obj.removeImg,...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.removeLine,field});
                    
                    %Modify Button
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    line.button2 = uibutton(tab,'Text','','Tooltip',"Change subfield name",'Icon',obj.modifyImg,...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.modifyLine,field});
                    
                    %Name field label
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    tooltip = slukeGUITooltip(obj.currentAddress(),field);
                    line.label = uilabel(tab,'Text',field, 'Position',[left,bottom,obj.labelWidth,obj.lineWidth]);
                    if ~isempty(tooltip)
                        line.label.Tooltip = tooltip;
                    end
                    line.editfield3 = uieditfield(tab,'Value',field, 'Position', [left,bottom,obj.labelWidth,obj.lineWidth],'Visible','off');
                    
                    
                    %Edit field
                    left = left + obj.lineIndent + obj.labelWidth;
                    width = tab.InnerPosition(3) - left - 4*obj.lineIndent -obj.imgButtonDim;
                    cell = struct.(field){str2double(tab.Tag)};
                    if isa(cell,'double')||isa(cell,'logical')
                        cell = mat2str(cell);
                    end
                    line.editfield = uieditfield(tab,'Value',cell,'HorizontalAlignment','left',...
                        'Position',[left,bottom,width,obj.lineWidth], ...
                        'Tag', field, 'ValueChangedFcn',@obj.correctStruct); %
                    line.editfield2 = [];
                    
                    %Copy Button
                    left = left + width + obj.lineIndent;
                    line.button3 = uibutton(tab,'Text','','Tooltip','Copy value into other Sim',...
                        'Icon',obj.copyImg,'ButtonPushedFcn',{@obj.copyLine,field},...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim]);
                    
                case 'Antenna'
                    %Remove Button
                    left = obj.lineIndent;
                    line.button1 = uibutton(tab,'Text','','Icon',obj.removeImg, 'Tooltip','Delete this field',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.removeLine,field});
                    
                    %Modify Button
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    line.button2 = uibutton(tab,'Text','','Icon',obj.modifyImg, 'Tooltip','Change subfield name',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.modifyLine,field});
                    
                    %Label
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    tooltip = slukeGUITooltip(obj.currentAddress(),field);
                    line.label = uilabel(tab,'Text',field, 'Position',[left,bottom,obj.labelWidth,obj.lineWidth]);
                    if ~isempty(tooltip)
                        line.label.Tooltip = tooltip;
                    end
                    line.editfield3 = uieditfield(tab,'Value',field, 'Position', [left,bottom,obj.labelWidth,obj.lineWidth],'Visible','off');
                    
                    %Edit Field 1
                    left = left + obj.lineIndent + obj.labelWidth;
                    width = (tab.InnerPosition(3) - left - 4*obj.lineIndent-obj.imgButtonDim)/2;
                    cell = struct.(field){str2double(tab.Tag)};
                    value = cell{1};
                    if isa(value,'double'), value = mat2str(value);	end
                    line.editfield = uieditfield(tab,'Value',value,'HorizontalAlignment','left',...
                        'Position',[left,bottom,width,obj.lineWidth], ...
                        'Tag', ['1' field ], 'ValueChangedFcn',@obj.correctStruct); %
                    
                    %Edit Field 2
                    left = left +  width + obj.lineIndent ;
                    value = cell{2};
                    if isa(value,'double'), value = mat2str(value);	end
                    line.editfield2 = uieditfield(tab,'Value',value,'HorizontalAlignment','left',...
                        'Position',[left,bottom,width,obj.lineWidth], ...
                        'Tag', ['2' field ], 'ValueChangedFcn',@obj.correctStruct);
                    
                    %Copy Button
                    left = left + width + obj.lineIndent;
                    line.button3 = uibutton(tab,'Text','','Tooltip','Copy value into other Sim',...
                        'Icon',obj.copyImg,'ButtonPushedFcn',{@obj.copyLine,field},...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim]);
                    
                case 'Struct'
                    %Remove Button
                    left = obj.lineIndent;
                    line.button1 = uibutton(tab,'Text','','Icon',obj.removeImg,'Tooltip','Delete this voice',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.removeLine,field});
                    
                    %Modify Button
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    line.button2 = uibutton(tab,'Text','','Icon',obj.modifyImg,'Tooltip','Change substruct name',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFc',{@obj.modifyLine,field});
                    
                    %Field Button
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    tooltip = slukeGUITooltip(obj.currentAddress(),field);
                    line.label = uibutton(tab,'Text',field,'ButtonPushedFcn',@obj.changeSubstruct,...
                        'Position',[left,bottom,obj.labelWidth,obj.lineWidth]);
                    if ~isempty(tooltip)
                        line.label.Tooltip = tooltip;
                    end
                    line.editfield3 = uieditfield(tab,'Value',field, 'Position', [left,bottom,obj.labelWidth,obj.lineWidth],'Visible','off');
                    
                    
                    line.editfield = [] ;
                    line.editfield2  =[];
                    line.button3 = [];
                    
                case 'NewField'
                    %Add Button
                    left = obj.lineIndent;
                    line.button1 = uibutton(tab,'Text','','Icon',obj.addImg,'Tooltip','Add new field',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',@obj.newLine);
                    
                    %Cancel Button
                    left = left + obj.lineIndent+obj.imgButtonDim;
                    line.button2 = uibutton(tab,'Text','','Icon',obj.removeImg,...
                        'Tooltip','Cancel new field','Visible','off',...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',@obj.closeNewField);
                    
                    left = left + obj.lineIndent+obj.imgButtonDim;
                    line.editfield3 = uieditfield(tab,'Value','New field','Visible','off',...
                        'Position',[left,bottom,obj.labelWidth,obj.lineWidth]); %todo value changed / changing check if it is ok%
                    
                    left = left + obj.lineIndent + obj.labelWidth;
                    width = (tab.InnerPosition(3) - left - 3*obj.lineIndent)/2;
                    line.editfield = uieditfield(tab,'Value','Make empty for substructure','HorizontalAlignment','left', ...
                        'Position',[left,bottom,width,obj.lineWidth], 'Visible', 'off');
                    
                    left = left +  width + obj.lineIndent ;
                    width = (tab.InnerPosition(3) - left - 2*obj.lineIndent);
                    line.editfield2 = uieditfield(tab,'Value','Use for antenna field, erase otherwise','HorizontalAlignment','left', ...
                        'Position',[left,bottom,width,obj.lineWidth], 'Visible', 'off');
                    
                    line.label.Text = nan;
                    line.label.Position = [nan nan nan nan];
                    line.button3 = [];
                    
                case 'General'
                    %Delete Button
                    left = obj.lineIndent;
                    line.button1 = uibutton(tab,'Text','','Tooltip','Delete this field','Icon',obj.removeImg,...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.removeLine,field});
                    
                    %Modify Button
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    line.button2 = uibutton(tab,'Text','','Tooltip',"Change subfield name",'Icon',obj.modifyImg,...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim],...
                        'ButtonPushedFcn',{@obj.modifyLine,field});
                    
                    %Name field label
                    left = left + obj.imgButtonDim + obj.lineIndent;
                    tooltip = slukeGUITooltip(obj.currentAddress(),field);
                    line.label = uilabel(tab,'Text',field, 'Position',[left,bottom,obj.labelWidth,obj.lineWidth]);
                    if ~isempty(tooltip)
                        line.label.Tooltip = tooltip;
                    end
                    line.editfield3 = uieditfield(tab,'Value',field, 'Position', [left,bottom,obj.labelWidth,obj.lineWidth],'Visible','off');
                    
                    
                    %Edit field
                    left = left + obj.lineIndent + obj.labelWidth;
                    width = tab.InnerPosition(3) - left - 4*obj.lineIndent -obj.imgButtonDim;
                    cell = struct.(field){str2double(tab.Tag)};
                    text = "{ ";
                    for i = 1:length(cell)
                        if isa(cell{i},'double')||isa(cell{i},'logical')
                            text = text + mat2str(cell{i});
                        else
                            text = text + "'" + cell{i} + "'";
                        end
                        if i ~= length(cell)
                            text = text + " , ";
                        end
                    end
                    text = strcat(text , " }");
                    line.editfield = uieditfield(tab,'Value',text,'HorizontalAlignment','left',...
                        'Position',[left,bottom,width,obj.lineWidth], ...
                        'Tag', ['0' field], 'ValueChangedFcn',@obj.correctStruct); %
                    line.editfield2 = [];
                    
                    %Copy Button
                    left = left + width + obj.lineIndent;
                    line.button3 = uibutton(tab,'Text','','Tooltip','Copy value into other Sim',...
                        'Icon',obj.copyImg,'ButtonPushedFcn',{@obj.copyLine,field},...
                        'Position',[left,bottom,obj.imgButtonDim,obj.imgButtonDim]);
            end
        end
        
        function removeLine(obj,~,~,field)
            n = obj.findLineIndex(field);
            isStruct =  strcmp(obj.line(n).type,'Struct');
            
            message = {['Delete "' field '" field?' ]};
            if isStruct
                message{2} = 'All its subfields will be deleted.';
            end
            
            if ~obj.check4Action(message,'Icon','warning')
                return
            end
            if isempty(obj.currentAddress)
                obj.sparams = rmfield(obj.currentStruct,field);
            else
                newCurrentStruct = rmfield(obj.currentStruct,field);
                obj.sparams = setfield(obj.sparams,obj.currentAddress{:},newCurrentStruct);
            end
            obj.deleteLine(n);
            for i = n:length(obj.line)
                obj.moveLine(i,0,obj.linePeriod)
            end
            if isStruct
                nTree = obj.findTreeIndex(field);
                delete(obj.tree.SelectedNodes.Children(nTree))
            end
        end
        
        function moveLine(obj,n,left,bottom)
            if strcmp('end',n), n = length(obj.line); end
            fnames = fieldnames(obj.line(n));
            for i = 1:length(fnames)
                if isprop(obj.line(n).(fnames{i}),'Position')
                    obj.line(n).(fnames{i}).Position = obj.line(n).(fnames{i}).Position + [left, bottom, 0, 0];
                end
            end
        end
        
        function modifyLine(obj,~,~,field)
            n = obj.findLineIndex(field);
            if strcmp(obj.line(n).editfield3.Visible,'on')
                newName = obj.line(n).editfield3.Value;
                
                if ~obj.checkName(newName,field,n)
                    return
                end
                obj.modifyLineMode(n,'off');
                if strcmp(newName,field)
                    return
                end
                if strcmp(obj.line(n).type,'Struct')
                    nTree = obj.findTreeIndex(field);
                    obj.tree.SelectedNodes.Children(nTree); %for%%%%
                end
                obj.line(n).label.Text = newName;
                obj.line(n).name = newName;
                obj.line(n).button1.ButtonPushedFcn = {@obj.removeLine,newName};
                obj.line(n).button2.ButtonPushedFcn = {@obj.modifyLine,newName};
                substruct = obj.currentStruct;
                substruct.(newName) = substruct.(field);
                substruct = rmfield(substruct,field);
                obj = obj.setfieldAtAddress(substruct);
                nChild = obj.findTreeIndex(field);
                obj.tree.SelectedNodes.Children(nChild).Text = newName;
                obj.changeNodeDataR(obj.tree.SelectedNodes.Children(nChild),newName,obj.currentDeepness+1);
                obj.changedSparams = true;
            else
                obj.modifyLineMode(n,'on');
            end
        end
        
        function modifyLineMode(obj,n,mode)
            if strcmp(mode,'on')
                obj.line(n).editfield3.Visible = 'on';
                obj.line(n).label.Visible = 'off';
                obj.line(n).button1.Enable = 'off';
                obj.line(n).button2.Icon = 'add.png';
                obj.line(n).button2.Tooltip = 'Confirm new name';
                if ~isempty(obj.line(n).editfield)
                    obj.line(n).editfield.Editable = 'off'; %for %%% %%%%%%% PER QUALCHE RQGIONE SI COMPORTQ STRQNO, C'é LABEL QUI DENTRO
                    obj.line(n).editfield.Enable = 'off';
                end
                if ~isempty(obj.line(n).editfield2)
                    obj.line(n).editfield2.Editable = 'off';
                    obj.line(n).editfield2.Enable = 'off';
                end
                
            else
                obj.line(n).editfield3.Visible = 'off';
                obj.line(n).label.Visible = 'on';
                obj.line(n).button1.Enable = 'on';
                obj.line(n).button2.Icon = 'pencil.png';
                obj.line(n).button2.Tooltip = 'Change subfield name';
                if ~isempty(obj.line(n).editfield)
                    obj.line(n).editfield.Editable = 'on';
                    obj.line(n).editfield.Enable = 'on';
                end
                if ~isempty(obj.line(n).editfield2)
                    obj.line(n).editfield2.Editable = 'on';
                    obj.line(n).editfield2.Enable = 'on';
                end
            end
        end
        
        function copyLine(obj,~,~,field)
            nTab = str2double(obj.tabGroup.SelectedTab.Tag);
            address = [obj.currentAddress, field];
            value2Copy = getfield(obj.sparams,address{:},{nTab});
            value2Copy = repmat(value2Copy,1,obj.nSim);
            obj.sparams = setfield(obj.sparams,address{:},value2Copy);
            obj.changedSparams = true;
        end
        
        function deleteLine(obj,Nline)
            %Remove the Nline-th line
            if strcmp(Nline,'end'), Nline = lenght(obj.line); end
            lineTmp = obj.line(Nline);
            if ~isempty(lineTmp.button1),    delete(lineTmp.button1);    end
            if ~isempty(lineTmp.button2),    delete(lineTmp.button2);    end
            if ~isempty(lineTmp.label),      delete(lineTmp.label);      end
            if ~isempty(lineTmp.editfield),  delete(lineTmp.editfield);  end
            if ~isempty(lineTmp.editfield2), delete(lineTmp.editfield2); end
            if ~isempty(lineTmp.editfield3), delete(lineTmp.editfield3); end
            
            obj.line(Nline) = [];
        end
        
        function newLine(obj,~,~)
            if strcmp(obj.line(end).button2.Visible, 'off') %Open new field creation
                obj.line(end).button2.Visible = 'on';
                obj.line(end).editfield3.Visible = 'on';
                obj.line(end).editfield.Visible = 'on';
                obj.line(end).editfield2.Visible = 'on';
            else %Create new field
                newField = obj.line(end).editfield3.Value;
                if ~obj.checkName(newField,'','end')
                    return
                end
                newValue = cell(1,length(obj.tabGroup.Children));
                nTab = str2double(obj.tabGroup.SelectedTab.Tag);
                if isempty(obj.line(end).editfield.Value) %It is a substructure
                    newValue = struct([]);
                    newFieldType = 'Struct';
                    uitreenode(obj.tree.SelectedNodes,'Text',newField,'NodeData',[obj.currentAddress, newField]);
                    
                elseif isempty(obj.line(end).editfield2.Value) %It is a subfield
                    newValue{nTab} = obj.tryStr2Num(obj.line(end).editfield.Value);
                    newFieldType = 'Field';
                    
                else %It is an antenna
                    newValue{nTab} = {obj.tryStr2Num(obj.line(end).editfield.Value),...
                        obj.tryStr2Num(obj.line(end).editfield2.Value)};
                    newFieldType = 'Antenna';
                end
                obj.sparams = setfield(obj.sparams,obj.currentAddress{:},newField,newValue);
                obj.deleteLine(Nfields);
                obj.line(Nfields) = obj.makeLine(newFieldType,currentStruct,newField,Nfields+1,1);
                obj.line(Nfields+1) = obj.makeLine('NewField',currentStruct,newField,Nfields+1,0);
                obj.changedSparams = true;
            end
        end
        
        function n = findLineIndex(obj,field)
            %returns 0 if it does not find anything.
            keepOn = 1;
            n = length(obj.line);
            while keepOn && n > 0
                keepOn = ~strcmp(obj.line(n).name,field);
                n = n-1;
            end
            n = n + ~keepOn;
        end
        
        function closeNewField(obj,~,~)
            obj.line(end).button2.Visible = 'off';
            obj.line(end).editfield3.Visible = 'off';
            obj.line(end).editfield3.Value = 'New field';
            obj.line(end).editfield3.FontColor = [0 0 0];
            obj.line(end).editfield.Visible = 'off';
            obj.line(end).editfield.Value = 'Make empty for subsructure';
            obj.line(end).editfield2.Visible = 'off';
            obj.line(end).editfield2.Value = 'Use for antenna field, erase otherwise';
        end
        
        function bool = checkName(obj,newName,field,n)
            
            if strcmp(n,'end'), n = length(obj.line); end
            currentStruct = obj.currentStruct();
            Nfields = length(obj.line);                 %%%
            if ~isvarname(newName)  %Check if it has a valid name
                obj.line(n).editfield3.Value = [obj.line(end).editfield3.Value ' - NOT VALID FIELD NAME' ];
                obj.line(n).editfield3.FontColor = [1 0 0];
                bool = false;
                return
            end
            if isfield(currentStruct,newName) && ~strcmp(newName,field)
                obj.line(n).editfield3.Value = [obj.line(end).editfield3.Value ' - FIELD NAME ALREADY PRESENT' ];
                obj.line(n).editfield3.FontColor = [1 0 0];
                for i =1:Nfields
                    if strcmp(obj.line(i).label.Text,newName)
                        obj.blink(obj.line(i).label,'FontColor',[1 0 0],2);
                        break
                    end
                end
                bool = false;
                return
            end
            bool = true;
        end
        %Loading
        function loadSparams(obj,~,~)
            try
                newSparams = obj.getSparams();
                if isempty(newSparams)
                    return
                end
                obj.sparams = newSparams;
                obj.changedSparams = false;
                delete(obj.tree.Children)
                obj.makeNodes();
                expand(obj.tree)
                obj.resetTabGroup();
                for i=2:obj.nSim
                    obj.addTab()
                end
            catch ME
                uialert(obj.fig,ME.message,'Error Message');
            end
        end
        
        function sparams = getSparams(obj)
            filter = {'*.m';'*.mat';'*.*'};
            
            [file,path] = uigetfile(filter,'File selection...');
            
            if isa(file,'double') && file==0
                sparams = '';
                return
            end
            
            iPoint = find(file == '.',1);
            if ~isempty(iPoint), extention = file(iPoint:end);
            else,   extention = '.?';
            end
            
            switch extention
                case '.m'
                    obj.checkScript(path,file);
                    try
                        sparams = obj.runMakeSparams([path file]);
                    catch ME
                        if ~strcmp(ME.Identifier,'SlukeGUI:getFile:Script:noSparams')
                            ME.Identifier = ['SlukeGUI:getFile:Script:' ME.Identifier];
                        end
                        rethrow(ME);
                    end
                case '.mat'
                    load([path '/' file],'sparams')
                    if ~exist('sparams','var')
                        error('SlukeGUI:getFile:Workplace:noSparams','Matlab workspace %s in path %s do not contains any sparams variable.',file,path);
                    end
                otherwise
                    error('SlukeGUI:getFile:wrongExtention',"Selected file %s in path has not the right extention.\n Please, select only .mat or .m files .",file,path);
            end
            
            if ~isa(sparams, 'struct')
                error('SlukeGUI:getFile:noStruct',"The loaded sparams must be a struct. It is a %s instead", class(sparams));
            end
            obj.checkConsistent(sparams)
        end
        
        function defaultSparams(obj,~,~)
            obj.sparams = sluke_params_defaults;
            obj.changedSparams = false;
            obj.resetTabGroup();
        end
        %Saving
        function saveSparams(obj,event,~)
            
            switch event.Tag
                case 'VariableSaveMenu'
                    filter = {'*.mat'};
                    file = 'sparams.mat';
                case 'ScriptSaveMenu'
                    filter = {'*.m'};
                    file = 'make_sparams.m';
                otherwise
                    filter = {'*.m';'*.mat'};
                    file = 'make_sparams.m';
            end
            [file,path,index] = uiputfile(filter,'File selection...',file);
            
            filter = ['0' filter '*.*'];
            switch filter{index+1}
                case '*.m'
                    obj.saveScript(file,path);
                case '*.mat'
                    obj.saveVariable(file,path);
                case '*.*'
                    % I DUNNO
                    
            end
        end
        
        function saveScript(obj,file,path)
            iPoint = find(file == '.');
            if ~isempty(iPoint)
                file = file(1:iPoint-1);
            end
            
            sluke_params_scriptPath(obj.sparams,file,path);
        end
        
        function saveVariable(obj,file,path)
            sparams = obj.sparams;
            save([path '/' file],'sparams');
        end
        %RushMode
        function answer = check4Action(obj,message,varargin)
            if ~obj.rushMode
                message = [message, ' ', '(Please, enter Rush Mode to skip this).'];
                
                if nargin == 2
                    answer = uiconfirm(obj.fig,message,'Requested action');
                else
                    answer = uiconfirm(obj.fig,message,'Requested action',varargin{:});
                end
                isOptions = strcmp(varargin,'Options');
                if any(isOptions)
                    i = find(isOptions);
                    Options = varargin{i+1};
                    answer = find(strcmp(Options,answer))-1;
                else
                    if strcmp(answer,'OK')
                        answer = 1;
                    else
                        answer = 0;
                    end
                end
            else
                answer = 1;
            end
        end
        
        function sendAlert(obj,message,icon,wait)
            if ~obj.rushMode
                if ~exist('icon','var')
                    icon = 'warning';
                end
                if ~exist('wait','var')
                    wait = '';
                end
                message = [message, ' ', '(Please, enter Rush Mode to skip this).'];
                if strcmp(wait,'wait')
                    uiallert(obj.fig,message,'Request action','Icon',icon);
                else
                    waitfor(uiconfirm(obj.fig,message,'Request action','Icon',icon,'Options',{'Ok'}))
                end
            end
        end
        
        function changeRushMode(obj,source,~)
            switch source.Checked
                case 'on'
                    obj.rushMode = false;
                    source.Checked = 'off';
                case 'off'
                    obj.rushMode = true;
                    source.Checked = 'on';
            end
        end
        %Figure
        function closingFigure(obj,event,~)
            if obj.changedSparams
                answer = uiconfirm(obj.fig,"Do you want to save changes to sparams?","Closing Request",...
                    'Options',{'Save and exit','Exit without saving','Cancel'},'DefaultOption',2);
                
                switch answer
                    case "Save and exit"
                        obj.saveSparams(event)
                        delete(obj.fig)
                    case "Exit without saving"
                        delete(obj.fig)
                    case "Cancel"
                end
            else
                delete(obj.fig)
            end
        end
        %Path
        function varargout = changePath(obj,~,~)
            %varargout = simPath
            simPath = uigetdir('','Select  directory');
            varargout{1} = simPath;
            if isa(simPath,'double')
                return
            end
            
            obj.permission = test_permissions_yp(simPath);
            if ~obj.permission
                keepOn = obj.chek4Action(obj.fig,['You do not have writing permission in the folder',simPath],'No writing permission');
            else
                keepOn = 1;
            end
            
            if keepOn
                cd(simPath)
            end
        end
        %sparams
        function n = nSim(obj)
            fields = fieldnamesr(obj.sparams);
            address = split(fields{1});
            n = length(getfield(obj.sparams,address{:}));
        end
        
        function obj = setfieldAtAddress(obj,newField)
            if isempty(obj.currentAddress)
                obj.sparams = newField;
            else
                obj.sparams = setfield(obj.sparams,obj.currentAddress{:},newField);
            end
        end
        %help
        function help(obj,~,~,type)
            icon = obj.helpImg;
            switch type
                case 'tab.tab'
                    message = {'Each tab corresponds to a simulation to be launched thorugh sparams.',...
                        'You can create new simulations through the menu tab > clone current tab',...
                        'If you want to run more time slices you can adjust the parameter discharge.nt instead of create more simulations'};
                case 'sparams.load'
                    message = {'sparams will be loaded through a matlab script or a variable saved in a matlab workspace'};
                case 'sparams.script'
                    message = {'To load sparams through a script this last must define it by assigning each field.', ...
                        'The uploaded sparams will be the one obtained at the end of the script.',...
                        'Please, be aware that the struct can have any field but it must be named sparams.',....
                        'An exemple of such a script can be created throug the function sluke_params_script().' };
                case 'sparams.variable'
                    message = {['To load sparams as an already existing structure it must be saved in a MATLAB workspace' ...
                        'and named sparams.'],...
                        'All other variables named in a different way will be ignored.'};
                case 'sparams.default'
                    message = {'A default SLUKE params is generated through the function sluke_parms_default'};
                case 'sluke.preambule'
                    message = {'It allows to lauch SLUKE with the params you have selected. Before, you will be able to select a script to be runned ahead of SLUKE calling.'...
                        'If any changement to a variable called sparams are done in this script they will be taken into account',...
                        'Please be awear that any allocation of a variable called sparams in the script will override sparams',...
                        'It can be used to create programmatically copies of the simulation with slight changes, as a shift in the LH injection spectrum'};
                case 'save.script'
                    message = {'A script is saved where all field are listed and defined.'};
                case 'save.variable'
                    message = {'A MATLAB workspace is saved with a struct named sparams in it.'};
                case 'rush'
                    message = {'Rush modality will inhibit the creation of dialog boxes to check action and dispatch not essential messages',...
                        'Its use is recommended only if you have a good comprehension of SLUKE behaviour and requirements'};
                case 'control'
                    message = {'No. Please be aware that there is no control over the correctness of each input.'};
                    
                case 'desperate'
                    message = {'Please, contact me at riccardo.saura@cea.fr',...
                        'I will try to help you'};
                case 'reportbug'
                    message = {'Plese contact me at riccardo.saura@cea.fr',...
                        'I will try to fix the issue.'};
                    icon = obj.bugImg;
                case 'credits'
                    message = {'Sluke code has been developed by J.Decker and Y.Peysson (yves.savoye-peysson@cea.fr) at CEA/DRF//IRFM', ...
                        'This GUI has been developed by R.Saura (riccardo.saura@cea.fr) at CEA/DRF//IRFM.',...
                        'Icon has been taken from the open online database www.flaticon.com'};
                otherwise
                    obj.placeholder();
                    return
            end
            uialert(obj.fig,message,'help box','Icon',icon);
        end
        %PlaceHolder
        function placeholder(obj,~,~)
            uialert(obj.fig,'This function it has not been implemented yet',...
                "I'm sorry...",'Icon','settings.png');
        end
    end
    %% STATIC METHODS
    methods (Static, Access = private)
        function position = screensize()
            set(0,'units','pixels')
            position = get(0,'screensize');
            position = position(3:4);
        end
        function num = tryStr2Num(str)
            try
                num = str2num(str);
            catch
                num = str;
            end
        end
        function blink(handle,field2blink,color,nBlink,time)
            %To obj must be possible to attribute a color
            if ~exist('time','var') || isempty(time)
                time = 0.25;
            end
            oldColor = handle.(field2blink);
            for i = 1:nBlink
                handle.(field2blink) = color;
                pause(time);
                handle.(field2blink) = oldColor;
                pause(time);
            end
        end
        function checkScript(path,file)
            try
                currentPath = pwd;
                cd(path(1:end-1));
                nargin(file)
                
                isScript = false;
            catch ME
                isScript = strcmp(ME.identifier,'MATLAB:nargin:isScript');
            end
            cd(currentPath)  % It passes always from here
            if  ~isScript
                error('SlukeGUI:checkScript:isNotScript','File %s in path %s is not a script.',file,path);
            end
        end
        function checkConsistent(params)
            fields = fieldnamesr(params);
            if isempty(fields)
                error('SlukeGUI:checkConsistent:void','Loaded sparams do not contain any field.');
            end
            address = split(fields{1});
            n = length(getfield(params,address{:}));
            if n == 0
                error('SlukeGUI:checkConsistent:empty','Loaded sparams is empty.');
            end
            [err,status] = sluke_params_consistency(params);  % output: err --> err = 0 sparams is consistent
            if err
                error('SlukeGUI:checkConsistent:notConsintent',['Loaded sparams is not consistent. ',status{:}]);
            end
        end
        function sparams = runMakeSparams(file) %#ok<STOUT>
            run(file)
            if ~exist('sparams','var')
                error('SlukeGUI:getFile:Script:noSparams','Script %s in path %s do not define any sparams variable.',file,pwd);
            end
        end
    end
end