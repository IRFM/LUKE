function [yN,ydN,yP,param_out,Pin,zyfac] = proc_aloha_spec_jd(zN_in,zdN_in,zdP_in,Pin_in,param_in,opt_optim,sdisplay)
	%
    % function for coupling ALOHA outputs and C3PO inputs. 
    %   parametrization can be performed interactively
    %
    % INPUTS : 
    %       - zN_in : initial ntor grid [1,nz]
    %       - zdN_in : initial ntor grid steps [1,nz] or [1,1] or NaN 
    %       - zdP_in : initial spectrum dP/dntor [1,nz]
    %       - Pin_in : corrected initial total power (NaN to read Pin from aloha, 1 for normalized output)
    %           imaginary part : see param.dir below (used only if param is a scalar)
    %       - param_in : parametrization of aloha spectrum treatment.
    %           Note : not all options are available through cases 1 & 2.
    %
    %         1) Case where param is a structure : fields ->   
    %           o nlobes : number of lobes selected
    %
    %           o dir : sort peaks according to : 
    %                    (0) P     + preserve repartition and total power 
    %                    (1) P/N^2 + preserve directivity and repartition 
    %                    (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case)
    %                    (3) P/N^2 + preserve repartition and total power 
    %
    %           o mode : (0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin)
    %                    (1) assemble peaks fixing Pmax and N, allowing dN to change
    %                    (2) assemble peaks allowing Pmax, N and dN to change
    %
    %         2) Case where param is empty : to be determined interactively
    %
    %         3) Case where param is a scalar : param = x + i*y. (default : 2i)
    %                 The lobes are selected in the order of decreasing power.
    %                 
    %           o case x = 0 : lobes calculated by keeping N and Pmax of
    %               each initial selected lobe. dN increased to account for
    %               power of neighboring lobes. 
    %                   - If 0 < y < 1, y is mimimum respective fraction of max power
    %                   - If y > 1 (integer), y is number of lobes selected
    %                   - If y < -1 (integer), the power cannot be transfered across N=0
    %
    %           o case x > 0 : lobes calculated by varying N, Pmax and dN to account for
    %               neighboring lobes (weighted averages). 
    %                   - If x < 1, x is mimimum respective fraction of max power
    %                   - If x > 1 (integer), x is number of lobes selected
    %                   - y (integer >= 0) is the number of completely protected lobes
    %
    %           o case x < 0 : identical to x = 0, but at the end only |x| (integer) 
    %               lobes are truly returned. The lobes are picked alternatively in each direction
    %             WARNING : in this case the total power is less than Pin
    %                   
    %       - opt_optim : use of function lsqnonlin for gaussian lobe fit (default : 0)
    %       - sdisplay : display structure, with the following field
    %           o inter : interactive mode for selecting parameters
    %           o mode : display (0) none (1) text only (2) text and figures (default : 0)
    %           o style (optional) : style properties (font...) for interactive windows and figures
    %           o opt_gui (optional) : use gui for interactive windows, use as handle if opt_gui is handle
    %           o axs (optional) : use axs to plot spectrum (iluke only)
    %           
    %
    % OUTPUTS : 
    %       - yN : values for output lobes
    %       - ydN : respective gaussian width
    %       - yP : respective power
    %       - param_out : processing parameter used to generate spectrum
    %       - Pin : initial power used to generate spectrum
    %       - zyfac : distribution matrix
    %
    % by J. Decker and Y. Peysson
    %
	if nargin < 7,
    	sdisplay = struct;
	end
	%
	if nargin < 6,
    	opt_optim = 0;
    end
    %
	if nargin < 5,
    	param_in = NaN;
    end
    %
	if nargin < 4,
    	Pin_in = NaN;
    end
    %
    % PARAMETERS
    %
    if opt_optim == 1 && exist('lsqnonlin') ~= 2,
        opt_optim = 0;
    end
    %
    if ~isstruct(param_in) && isnan(param_in),% default values
        param_in.dir = 1;
        param_in.mode = 0;
        param_in.nlobes = 2;
    end
    %
    if isstruct(param_in) && ~isfield(param_in,'dir'),
        param_in.dir = 1;
    end
    %
    if isstruct(param_in) && ~isfield(param_in,'mode'),
        param_in.mode = 0;
    end
    %
    if isstruct(param_in) && ~isfield(param_in,'nlobes'),
        param_in.nlobes = 2;
    end
    %
    % DISPLAY
    %
    if ~isstruct(sdisplay),
        display_mode = sdisplay;
        sdisplay = struct;
    elseif isfield(sdisplay,'mode'),
        display_mode = sdisplay.mode;
    else
        display_mode = 0;
    end
    %
    if isfield(sdisplay,'inter'),
        %
        inter_mode = sdisplay.inter;% interactive mode
        %
    else
        %
        inter_mode = 1;
        %
    end     
    %
    if isfield(sdisplay,'style'),
        style = sdisplay.style;
    else
        style = struct;
    end
    %
    if isfield(sdisplay,'opt_gui'),
        %
        if ishandle(sdisplay.opt_gui),
            selectheight = 175;
            panelposition = get(sdisplay.opt_gui,'Position');
            %
            select.position = [style.panelsep,style.panelsep,panelposition(3) - 2*style.panelsep,selectheight];
            info.position = [style.panelsep,2*style.panelsep + selectheight,panelposition(3) - 2*style.panelsep,panelposition(4) - selectheight - 3*style.panelsep];
            info1.position = [style.panelsep,2*style.panelsep + selectheight,panelposition(3)/2 - 2*style.panelsep,panelposition(4) - selectheight - 3*style.panelsep];
            info2.position = [panelposition(3)/2 + style.panelsep,2*style.panelsep + selectheight,panelposition(3)/2 - 2*style.panelsep,panelposition(4) - selectheight - 3*style.panelsep];
            %
            select.handle = uipanel('Parent',sdisplay.opt_gui,'Title','','units','pixels','Position',select.position);
            info.handle = uicontrol(sdisplay.opt_gui,'Style','text','Position',info.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            info1.handle = uicontrol(sdisplay.opt_gui,'Style','text','Position',info1.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
            info2.handle = uicontrol(sdisplay.opt_gui,'Style','text','Position',info2.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','center');
            %
            opt_gui = select.handle;
            opt_info = true;
            %
            style.textwidth = panelposition(3) - 2*style.panelsep - style.butwidth - 5*style.buthsep;
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
    if display_mode >= 1 && inter_mode == 1,
        %
        infostr = {...
        '--------------------------------------------------------',...
        '          ALOHA  ->  C3PO parametrization               ',...
        '--------------------------------------------------------',...
        ' ',...
        'Recommended parametrization for aloha -> C3PO :',...
        ' ',...      
        '  - Multi-lobe model (strong absorption case,... : param.dir = 1, param.mode = 0, param.nlobes >= 2',...
        '        Note : adjust param.nlobes to approximately conserve absolute directivity and repartition',...
        ' ',...      
        '  - Tail-lobes model (weak absorption case,...   : param.dir = 2, param.mode = 1, param.nlobes = 2',...
        '        Note : absolute directivity and repartition should be fairly well conserved',...
        ' ',...      
        '  - Simple model (ideal spectrum, one lobe,...   : param.dir = 1, param.mode = 1, param.nlobes = 1',...           
        ' '};     
        %
        if opt_info,
            set(info1.handle,'Visible','off');
            set(info2.handle,'Visible','off');
            set(info.handle,'String',infostr([5:13]));
        else
            for iinfo = 1:length(infostr),
                disp(infostr{iinfo});
            end
        end        
        %
    end
    %
    exit_loop = 0;
    figs = 0;
    %
    while exit_loop == 0,
        %       
        zN = zN_in;
        zdN = zdN_in;
        zdP = zdP_in;
        Pin = Pin_in;
        param = param_in;
        %
        if figs == 1,
            close(fig1),close(fig2),close(fig3),close(fig4)
        end
        %
        if inter_mode == 1,
            param.dir = iselect_jd({'P     + preserve repartition and total power',...
                                    'P/N^2 + preserve directivity and repartition',...
                                    'P/N^2 + preserve directivity and total power',...
                                    'P/N^2 + preserve repartition and total power'},'Sort peaks according to :',opt_gui,style,param.dir + 1) - 1;
            %            
            disp(' ')      
        end
        %
        if isstruct(param),
            if param.dir == 0,
                Pin = real(Pin);
            elseif param.dir == 1,
                Pin = real(Pin) + 1i;
            elseif param.dir == 2,
                Pin = real(Pin) + 2i;
            else
                Pin = real(Pin) + 3i;            
            end
        end
        %
        zdP = zdP(:).';
        zdN = zdN(:).';
        zN = zN(:).';
        %
        if min(zdP) < 0,% correct case of negative power from aloha
            disp('warning: min(zdP) < 0, correcting')
            disp(' ')      
            zdP = zdP - min(zdP);
        end
        %
        global zx zf
        %
        if length(zdN) == 1 && isnan(zdN), % calculate grid steps if needed
            zN_S = [zN(1) - (zN(2)-zN(1))/2, (zN(1:end-1) + zN(2:end))/2, zN(end) + (zN(end)-zN(end-1))/2];
            zdN = diff(zN_S);
        end
        %
        % remove edge points with zdP = 0
        %
        mask = find(zdP > 0,1,'first'):find(zdP > 0,1,'last');
        zdP = zdP(mask);
        zdN = zdN(mask);
        zN = zN(mask);
        %
        % manages case of successive points with equal power density
        %
        zptrend = sign(diff(zdP));
        %
        while any(zptrend == 0),
            %
            disp('Fixing the case of successive points with equal power density')
            %
            iflat = find(zptrend == 0);% zppdP(iflat) = zppdP(iflat+1)
            %
            while ~isempty(iflat),
                if length(iflat) > 1,% could be more than two successive equal values
                    imask = find(diff(iflat) > 1,1,'first');% number of successive equal values
                    if isempty(imask),% remaining cases are all successive equal values
                        imask = length(iflat);
                    end
                else
                    imask = 1;
                end
                %
                mask = iflat(1):iflat(imask)+1;% indices successive points with equal values
                zN = [zN(1:mask(1)-1),mean(zN(mask)),zN(mask(end)+1:end)];
                zdP = [zdP(1:mask(1)-1),zdP(mask(1)),zdP(mask(end)+1:end)];
                zdN = [zdN(1:mask(1)-1),sum(zdN(mask)),zdN(mask(end)+1:end)];
                %
                iflat(1:imask) = [];
                iflat = iflat - imask;% shift indices 
                %
            end              
            %
            zptrend = sign(diff(zdP));
            %
        end
        %
        %
        %
        Ptot = sum(zdP.*zdN);
        nz = length(zdP);
        %
        if ~isnan(real(Pin)),% externally imposed power
            zdP = zdP*real(Pin)/Ptot;%set correct total input power (aloha total power calculation may give erratic results)
            Ptot = real(Pin);
        end
        %
        if imag(Pin) >= 1,% sort power as P/N^2 instead of P to conserve directivity
            zdP = zdP./zN.^2;
            Ptot = sum(zdP.*zdN);
        end
        %
        %  display limits
        %
        Pmindisp = 10^(floor(mean(log10(zdP(find(zdP > 0))))) - 2); 
        Pmaxdisp = 10^(ceil(log10(max(zdP))) + 1); 
        %
        % identify initial lobes
        %
        zppdP = [0,zdP,0];
        %
        zptrend = sign(diff(zppdP));
        %
        if any(zptrend == 0),
            error('case of successive points with equal power density not yet treated.')
        end
        %
        zvar = diff(zptrend);
        %
        ilim = [1,find(zvar == 2),nz]; %indices of lobes separation
        %
        ny = length(ilim) - 1;% number of initial lobes
        %
        enforcedir = 0;
        %
        if isstruct(param),
            %
            if inter_mode == 1,
                param.mode = iselect_jd({'select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin)',...
                                         'assemble peaks fixing Pmax and N, allowing dN to change',...
                                         'assemble peaks allowing Pmax, N and dN to change'},'Mode for peak processing :',opt_gui,style,param.mode + 1) - 1;
                disp(' ')      
                %
                param.nlobes = iselect_jd(num2cell(num2str((1:ny).'),2).','Number of lobes to be selected :',opt_gui,style,param.nlobes,'popupmenu');
                disp(' ')      
            end
            %
            if param.mode == 0,
                param = - param.nlobes - Inf*1i;
            elseif param.mode == 1,
                %
                if param.nlobes == 1,
                    param = - 1 - 2i;
                else
                    param = - param.nlobes*1i;
                end
                %
            else
                if param.nlobes > 1,
                    enforcedir = 1;
                end
                param = param.nlobes;
            end
        end
        %
        if imag(param) <= -2,% do not allow power to be transfered through N=0, usual mode
            enforcedir = 1;
            param = real(param) - 1i*imag(param);
        end
        %
        if real(param) <= 0,% Peak position and height are maintained, dNpar is adjusted
            if imag(param) < 1,
                Pfacmin = imag(param);
                nlobesmax = ny;
            else
                Pfacmin = 0;
                nlobesmax = imag(param);
            end        
            %
            nlobespro = 0;
            opt_peak = 0;
            %
        else % Peak position and height are varied for non-protected peaks
            if real(param) < 1,
                Pfacmin = real(param);
                nlobesmax = ny;
            else
                Pfacmin = 0;
                nlobesmax = real(param);
            end
            %
            % a number of (main) peaks can be protected (they keep the original N, P and dN)
            %
            % they are not accounted for in nlobesmax (nlobes = nlobesmax + nlobespro). 
            % if Pfacmin is used, the fraction is calculated on the remaining power
            %
            nlobespro = fix(imag(param));
            opt_peak = 1;
            %
        end
        %
        zydP = repmat(zdP.',[1,ny]);
        zydN = repmat(zdN.',[1,ny]);
        zyN = repmat(zN.',[1,ny]);
        %
        zyind = (1:nz).'*ones(1,ny);
        zyilimm = repmat(ilim(1:end-1),[nz,1]);
        zyilimp = repmat(ilim(2:end),[nz,1]);
        %
        zyfac = zeros(nz,ny);% distribution matrix
        zyfac(zyind > zyilimm & zyind < zyilimp) = 1;
        zyfac(zyind == zyilimm | zyind == zyilimp) = 1/2;%half power belongs to lobe at separation points
        zyfac(zyind == 1 | zyind == nz) = 2*zyfac(zyind == 1 | zyind == nz);%full power belongs to lobe at end points
        %
        yP = sum(zydP.*zydN.*zyfac);
        %
        % initial lobes
        %
        if opt_peak == 1,% recalculate N//
            %
            yN = sum(zydP.*zydN.*zyfac.*zyN)./yP;
            ydN = sqrt(2*sum(zydP.*zydN.*zyfac.*(zyN - repmat(yN,[nz,1])).^2)./yP);
            if opt_optim,
                for iy = 1:ny,
                    zx = zN - yN(iy);
                    zf = zdP.*zyfac(:,iy).'/yP(iy);
                    ydN(iy) = lsqnonlin(@gauss_squares_jd,ydN(iy));
                end
            end
            %
        else% keep N//, 
            %
            ipeak = find(zvar == -2);
            yN = zN(ipeak);
            ydN = yP/sqrt(pi)./zdP(ipeak);% adjust dN to account for peak assembly        
            %
        end
        %
        if abs(sum(yP) - Ptot)/Ptot > eps('double')*nz,
            error('Power was not conserved')
        end
        %
        if nlobespro > 0 && ny > nlobespro,% keep a number of protected peaks
            %
            [yPsort,iysort] = sort(yP);
            %
            iypro = iysort(ny + 1 - nlobespro:ny);
            %
            yNpro = yN(iypro);
            ydNpro = ydN(iypro);
            yPpro = yP(iypro);
            zyfacpro = zyfac(:,iypro);
            %
            yN(iypro) = [];
            ydN(iypro) = [];
            yP(iypro) = [];
            zyfac(:,iypro) = [];
            %
            Ptot = Ptot - sum(yPpro);
            %
            ny = ny - nlobespro;
            %
        else
            %
            yNpro = yN([]);
            ydNpro = ydN([]);
            yPpro = yP([]);
            zyfacpro = zyfac(:,[]);
            %
        end
        %
        yP0 = yP;
        %
        % loop to agregate the power of minor peaks
        %
        while ny > nlobesmax || min(yP)/Ptot < Pfacmin,
            %
            iy = find(yP == min(yP),1,'first');
            %
            if iy == 1,
                %
                iyp = 2;
                %
                if enforcedir == 1 && yN(iyp)*yN(iy) < 0,% forbid changes in directivity
                    %
                    yNpro = [yNpro,yN(iy)];
                    ydNpro = [ydNpro,ydN(iy)];
                    yPpro = [yPpro,yP(iy)];
                    zyfacpro = [zyfacpro,zyfac(:,iy)];
                    %
                    if opt_peak == 0,% recalculate dN// to keep Pmax.
                        %
                        ydNpro(end) = ydN(iy).*yP(iy)./yP0(iy);
                        %
                    end
                    %
                    Ptot = Ptot - yP(iy);
                    %
                    yN(iy) = [];
                    ydN(iy) = [];
                    yP(iy) = [];
                    yP0(iy) = [];
                    zyfac(:,iy) = [];
                    %
                    ny = ny - 1;
                    %
                    nlobesmax = nlobesmax - 1;
                    nlobespro = nlobespro + 1;
                    %
                    continue
                    %
                end
                %
                zyfac(:,iyp) = zyfac(:,iyp) + zyfac(:,iy);
                yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
                %
                if opt_peak == 1,% recalculate N//
                    yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
                    ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
                    if opt_optim,
                        zx = zN - yN(iyp);
                        zf = zdP.*zyfac(:,iyp).'/yP(iyp);
                        ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
                    end
                end
                %
            elseif iy == ny,
                %
                iym = ny - 1;
                %
                if enforcedir == 1 && yN(iym)*yN(iy) < 0,% forbid changes in directivity
                    %
                    yNpro = [yNpro,yN(iy)];
                    ydNpro = [ydNpro,ydN(iy)];
                    yPpro = [yPpro,yP(iy)];
                    zyfacpro = [zyfacpro,zyfac(:,iy)];
                    %
                    if opt_peak == 0,% recalculate dN// to keep Pmax.
                        %
                        ydNpro(end) = ydN(iy).*yP(iy)./yP0(iy);
                        %
                    end
                    %
                    Ptot = Ptot - yP(iy);
                    %
                    yN(iy) = [];
                    ydN(iy) = [];
                    yP(iy) = [];
                    yP0(iy) = [];
                    zyfac(:,iy) = [];
                    %
                    ny = ny - 1;
                    %
                    nlobesmax = nlobesmax - 1;
                    nlobespro = nlobespro + 1;
                    %
                    continue
                    %
                end
                %
                zyfac(:,iym) = zyfac(:,iym) + zyfac(:,iy);
                yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
                %
                if opt_peak == 1,% recalculate N//
                    yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
                    ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
                    if opt_optim,
                        zx = zN - yN(iym);
                        zf = zdP.*zyfac(:,iym).'/yP(iym);
                        ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
                    end
                end
                %
            else
                %
                iym = iy - 1;
                iyp = iy + 1;
                %
                if enforcedir == 1 && yN(iym)*yN(iyp) < 0,% forbid changes in directivity
                    %
                    Nlim = 0;
                    %
                else
                    %
                    Nlim = (yN(iym) + yN(iyp))/2;
                    %
                end
                %
                izlimm = find(zN_S < Nlim,1,'last');
                %
                zyfac(1:izlimm-1,iym) = zyfac(1:izlimm-1,iym) + zyfac(1:izlimm-1,iy);
                zyfac(izlimm+1:end,iyp) = zyfac(izlimm+1:end,iyp) + zyfac(izlimm+1:end,iy);
                %
                zyfac(izlimm,iym) = zyfac(izlimm,iym) + zyfac(izlimm,iy)*(Nlim - zN_S(izlimm))/zdN(izlimm);
                zyfac(izlimm,iyp) = zyfac(izlimm,iyp) + zyfac(izlimm,iy)*(zN_S(izlimm + 1) - Nlim)/zdN(izlimm);
                %
                yP(iym) = sum(zdP.*zdN.*zyfac(:,iym).');
                yP(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).');
                %
                if opt_peak == 1,% recalculate N//
                    yN(iym) = sum(zdP.*zdN.*zyfac(:,iym).'.*zN)./yP(iym);
                    ydN(iym) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iym).'.*(zN - yN(iym)).^2)/yP(iym));
                    if opt_optim,
                        zx = zN - yN(iym);
                        zf = zdP.*zyfac(:,iym).'/yP(iym);
                        ydN(iym) = lsqnonlin(@gauss_squares_jd,ydN(iym));
                    end
                    %
                    yN(iyp) = sum(zdP.*zdN.*zyfac(:,iyp).'.*zN)./yP(iyp);
                    ydN(iyp) = sqrt(2*sum(zdP.*zdN.*zyfac(:,iyp).'.*(zN - yN(iyp)).^2)/yP(iyp));
                    if opt_optim,
                        zx = zN - yN(iyp);
                        zf = zdP.*zyfac(:,iyp).'/yP(iyp);
                        ydN(iyp) = lsqnonlin(@gauss_squares_jd,ydN(iyp));
                    end
                end
                %
            end
            %
            yP0(iy) = [];
            yP(iy) = [];
            yN(iy) = [];
            ydN(iy) = [];
            zyfac(:,iy) = [];
            %
            ny = ny - 1;    
            %
        end
        %
        if opt_peak == 0,% recalculate dN// to keep Pmax.
            %
            ydN = ydN.*yP./yP0;
            %
        end
        %
        % add protected peaks
        %
        yN = [yNpro,yN];
        ydN = [ydNpro,ydN];
        yP = [yPpro,yP];
        zyfac = [zyfacpro,zyfac];
        %
        ny = ny + nlobespro;
        %
        % select number of peaks if real(param) < 0
        %
        if real(param) < 0,
            %
            ny = min([ny,-real(param)]);
            %
            [dummy,iy] = sort(yP.^2,2,'descend');% keep this to choose with Pin whether to work with directivity
            %
            iys = iy(1);
            iy(1) = [];
            %
            for iiy = 2:ny,
                j = 1;
                while j <= length(iy),
                    if yN(iy(j))*yN(iys(end)) < 0,% pick alternatively in each direction
                        iys(iiy) = iy(j);
                        iy(j) = [];
                        break
                    else
                        j = j + 1;
                    end
                end
                %
                if j > length(iy),% one direction is exhausted
                    iys(iiy) = iy(1);
                    iy(1) = [];
                end
            end
            %
            yP = yP(iys);
            yN = yN(iys);
            ydN = ydN(iys);
            zyfac = zyfac(:,iys);
            %
        end
        %
        % sort output by N//
        %
        [yN,iy] = sort(yN);
        ydN = ydN(iy);
        yP = yP(iy);
        zyfac = zyfac(:,iy);
        %
        if imag(Pin) >= 1,% readjust power
            yP = yP.*yN.^2;
            zdP = zdP.*zN.^2;
            Ptot = sum(zdP.*zdN);
        end    
        %
        if imag(Pin) == 2,% readjust power keeping directivity and total power
            %
            maskp = yN > 0;
            maskm = yN < 0;
            %
            Ptotp = sum(yP(maskp));
            Ptotm = sum(yP(maskm));
            %
            Pdirp = sum(yP(maskp)./yN(maskp).^2);
            Pdirm = sum(yP(maskm)./yN(maskm).^2);
            %
            facp = (Ptot*Pdirm + Ptotm*(Pdirp - Pdirm))/(Pdirm*Ptotp + Pdirp*Ptotm);
            facm = (Ptot*Pdirp + Ptotp*(Pdirm - Pdirp))/(Pdirm*Ptotp + Pdirp*Ptotm);
            %
            yP(maskp) = yP(maskp)*facp;
            yP(maskm) = yP(maskm)*facm; 
            %
    %         Ptotp*facp + Ptotm*facm = Ptot
    %         Pdirp*facp - Pdirm*facm = (Pdirp*Ptot*Pdirm + Pdirp*Ptotm*(Pdirp - Pdirm) - Pdirm*Ptot*Pdirp - Pdirm*Ptotp*(Pdirm - Pdirp))/(Pdirm*Ptotp + Pdirp*Ptotm)
    %                                 = Pdirp - Pdirm
            %
            if opt_peak == 0 && real(param) == 0,% recalculate dN// to keep Pmax.
                %
                ydN(maskp) = ydN(maskp)*facp;
                ydN(maskm) = ydN(maskm)*facm;
                %
            end
        end
        %
        if imag(Pin) == 3,% readjust power keeping total power
            %
            fac = Ptot/sum(yP);
            yP = yP*fac;
            %
            if opt_peak == 0 && real(param) == 0,% recalculate dN// to keep Pmax.
                %
                ydN = ydN*fac;
                %
            end
            %
        end
        %
        % display results
        %
        if display_mode >= 1,
            %
            Npeak = zN(find(zdP == max(zdP),1,'first'));
            %
            zmaskp = zN > 0;
            zmaskm = zN < 0;
            %
            ymaskp = yN > 0;
            ymaskm = yN < 0;
            %
            di = Npeak^2*(sum(zdP(zmaskp)./zN(zmaskp).^2.*zdN(zmaskp)) - sum(zdP(zmaskm)./zN(zmaskm).^2.*zdN(zmaskm)))/Ptot;
            df = Npeak^2*(sum(yP(ymaskp)./yN(ymaskp).^2) - sum(yP(ymaskm)./yN(ymaskm).^2))/Ptot;
            %
            pti = Ptot;
            ptf = sum(yP);
            %
            dri = di;
            drf = df*pti/ptf;
            %
            ri = sum(zdP(zmaskp).*zdN(zmaskp))/pti;
            rf = sum(yP(ymaskp))/ptf; 
            %
            infostr = {...
            ['Initial   directivity : ',num2str(di)],...
            ['Processed directivity : ',num2str(df)],...        
            ' ',...
            ['Initial   power : ',num2str(pti)],...
            ['Processed power : ',num2str(ptf)],...        
            ' ',...
            ['Initial   rel. directivity : ',num2str(dri)],...
            ['Processed rel. directivity : ',num2str(drf)],...        
            ' ',...
            ['Initial   repartition : ',num2str(ri)],...
            ['Processed repartition : ',num2str(rf)],...        
            ' ',...
            '   yN     ydN     yP   ',...
            '-----------------------',...
            num2str([yN.',ydN.',yP.'],3),...
            ' '};
            %
            if opt_info,
                set(info.handle,'Visible','off');
                set(info1.handle,'Visible','on');
                set(info2.handle,'Visible','on');
                set(info1.handle,'String',infostr([1,2,4,5,7,8,10,11]));
                set(info2.handle,'String',infostr(13:end-1));
            else
                for iinfo = 1:length(infostr),
                    disp(infostr{iinfo});
                end
            end        
            %
        end
        %
        if display_mode >= 2,
            %
            dx = min(ydN)/10;
            x = (min(yN) - 4*max(ydN)):dx:(max(yN) + 4*max(ydN));
            nx = length(x);
            %
            xyN = repmat(yN,[nx,1]);
            xyP = repmat(yP,[nx,1]);
            xydN = repmat(ydN,[nx,1]);
            xy = repmat(x.',[1,ny]);
            %
            xyf = xyP.*exp(-(xy - xyN).^2./xydN.^2)./sqrt(pi)./xydN;
            xf = sum(xyf,2);
            %
            ylim = [Pmindisp,Pmaxdisp];
            %
            if real(Pin) == 1,
                fac = 1;
                ylab = 'dP/dn_z (norm.)';
            else
                fac = 1e6;
                ylab = 'dP/dn_z (MW)';
            end            
            %
            if isfield(sdisplay,'axs'),
                ax = sdisplay.axs(1);
                set(ax,'Visible','on');
                red = 1;
                lspace = NaN;
                bspace = NaN;
            else
                fig1 = figure('Name','Gaussian fit vs. ALOHA');
                ax = gca;
                red = 0.9;
                lspace = 0.7;
                bspace = 0.5;
            end
            %
            leg = {'ALOHA','Gaussian fit','Location','NorthWest'};
            graph1D_jd(zN,zdP/fac,0,0,'n_z',ylab,'',NaN,'',NaN,'-','none','b',2,style,ax,red,lspace,bspace);
            graph1D_jd(x,xf/fac,0,0,'','','',leg,'',NaN,'--','none','r',2,style,ax);
            %
            if ~isfield(sdisplay,'axs'),
                fig2 = figure('Name','Gaussian fit vs. ALOHA');
                graph1D_jd(zN,zdP/fac,0,1,'n_z',ylab,'',NaN,'',ylim/fac,'-','none','b',2,style,gca,red,lspace,bspace);
                graph1D_jd(x,xf/fac,0,1,'','','',leg,'',ylim/fac,'--','none','r',2);
                %
                fig3 = figure('Name','Gaussian fit calculation');
                leg = {'Gaussian','Fit'};
                graph1D_jd(xy(:),xyf(:)/fac,0,0,'n_z',ylab,'',NaN,'',NaN,'-','none','b',2,style,gca,red,lspace,bspace);
                graph1D_jd(x,xf/fac,0,0,'','','',leg,'',NaN,'--','none','r',2);
                %    
                fig4 = figure('Name','Gaussian fit calculation');
                graph1D_jd(xy(:),xyf(:)/fac,0,1,'n_z',ylab,'',NaN,'',ylim/fac,'-','none','b',2,style,gca,red,lspace,bspace);
                graph1D_jd(x,xf/fac,0,1,'','','',leg,'',ylim/fac,'--','none','r',2);
                %
                figs = 1;
                %
            end
            %
        end
        %
        if inter_mode == 0,
            exit_loop = 1;
        else
            exit_loop = 2 - iselect_jd({'Accept this process','Start again'},'Do you want to :',opt_gui,style,1);
            disp(' ')      
        end
        %
        if exit_loop == 0 && isfield(sdisplay,'axs'),% start again - clear new plot
            cla;% clear graph of lines
            chs = get(get(ax,'parent'),'children');% list of panel elements
            delete(chs(1));% delete legend
        end
        %
        if exit_loop == 0 && opt_info,% start again - clear disp
            set(info.handle,'Visible','on');
            set(info1.handle,'Visible','off');
            set(info2.handle,'Visible','off');
        end
    end
    %
    if opt_info,
        delete(select.handle);
        delete(info.handle);
        delete(info1.handle);
        delete(info2.handle);
    end
    %
    if imag(param) >= 2 && enforcedir == 1;
        param = real(param) - 1i*imag(param);
    end 
    %
    param_out.calc = param;
    param_out.dir = imag(Pin);
    %
    if imag(param) == -Inf && real(param) <= -1,
        param_out.mode = 0;
        param_out.nlobes = -real(param);
    elseif param == - 1 - 2i;
        param_out.mode = 1;
        param_out.nlobes = 1;
    elseif imag(param) < -1 && real(param) == 0,
        param_out.mode = 1;
        param_out.nlobes = -imag(param);
    elseif imag(param) == 0 && real(param) >= 1,
        param_out.mode = 2;
        param_out.nlobes = real(param);
    else
        param_out.mode = NaN;
        param_out.nlobes = NaN;
    end
    %
end       
%
function [zdf] = gauss_squares_jd(dN)
	% 
	global zx zf
	%
	zdf = zf - exp(-zx.^2/dN^2)/sqrt(pi)/dN;
	%
end






    