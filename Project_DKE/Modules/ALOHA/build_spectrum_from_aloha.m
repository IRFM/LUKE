function launch = build_spectrum_from_aloha(external,basestr,signs,opt_gui,select)
%
if nargin < 5,
	select = struct;
    %
    if ~isfield(select,'style'),
        select.style = struct;
    end
end
%
if nargin < 4,
	opt_gui = true;
end
%
spectrum = struct;
%
if ~isfield(select,'style'),
    select.style = struct;
end
%
if isfield(external.antenna,'id'),
    spectrum.id = external.antenna.id;
end
%
if iscell(external.antenna.aloha.results.dP_nz)
    spectrum.dP_nz = real(external.antenna.aloha.results.dP_nz{1});
    %
    if length(external.antenna.aloha.results.dP_nz) > 1
    for ii=2:length(external.antenna.aloha.results.dP_nz)
        spectrum.dP_nz = spectrum.dP_nz + real(external.antenna.aloha.results.dP_nz{ii});
    end
end
else
    spectrum.dP_nz = real(external.antenna.aloha.results.dP_nz);
end
%
spectrum.nz = external.antenna.aloha.results.nz;
spectrum.ny = external.antenna.aloha.results.ny;
%
disp('********************************************************************************************')
disp('WARNING: check that the ALOHA power spectrum generates a co-current or a counter current. ')
disp('Co-current:      Npar0(main peak) < 0 if sign(Ip)*sign(Bt) > 0');
disp('Counter-current: Npar0(main peak) > 0 if sign(Ip)*sign(Bt) < 0');
disp(['Ip sign: ',num2str(signs.ip),', Bt0 sign: ',num2str(signs.b0),' (see LUKE signe conventions in documentation)']);
disp('********************************************************************************************')
%
if signs.ip*signs.b0 > 0
    if spectrum.nz(find(spectrum.dP_nz==max(spectrum.dP_nz))) < 0
        opt_spectrum = input_dke_yp('Main lobe of the power spectrum generates co-current.  Would you like to change the power spectrum for generating counter-current (yes:1,no:0)',0,[0,1]) == 1;
    else 
        opt_spectrum = input_dke_yp('Main lobe of the power spectrum generates counter-current.  Would you like to change the power spectrum for generating co-current (yes:1,no:0)',0,[0,1]) == 1;
    end
else
    if spectrum.nz(find(spectrum.dP_nz==max(spectrum.dP_nz))) > 0
        opt_spectrum = input_dke_yp('Main lobe of the power spectrum generates co-current. Would you like to change the power spectrum for generating counter-current (yes:1,no:0)',0,[0,1]) == 1;
    else 
        opt_spectrum = input_dke_yp('Main lobe of the power spectrum generates counter-current. Would you like to change the power spectrum for generating co-current (yes:1,no:0)',0,[0,1]) == 1;
        
    end
end
%
if opt_spectrum == 1, 
    spectrum.dP_nz = fliplr(spectrum.dP_nz);%for co- or counter- current generation depending upon reltive signs of ip and bt0
end
%
while 1,
    opt_module = iselect_jd({'full antenna','upper module','lower module'},'This ALOHA spectrum corresponds to :',opt_gui,select.style,1);
    %
    if opt_module > 1,
        pfac = 1/2;
        pstr = ' (half antenna)';
    else
        pfac = 1;
        pstr = '';
    end                
    %
    val(1) = sum(spectrum.dP_nz*external.antenna.aloha.results.dnz);
    s{1} = ['Power from ALOHA spectrum',pstr,'        : PLH = ',num2str(val(1)/1e6),' MW'];
    %
    s{end+1} = 'Specify power manually';
    %   
    locstyle = select.style;
    locstyle.textwidth = 600;
    %
    opt_Plhtot = iselect_jd(s,['LH power associated with this spectrum',pstr,' :'],opt_gui,locstyle,length(s)-1);
    %
    if opt_Plhtot < length(s),
        spectrum.Plhtot = val(opt_Plhtot);
    else
        spectrum.Plhtot = 1e6*iselect_jd({},['Specify LH power',pstr,' (MW) :'],opt_gui,select.style,val(1)/1e6);
    end
    %
    data = struct;
    data.spectrum = spectrum;
    select.mode = 2;%display fitted ALOHA spectra
    %
    launch = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
    %
    if opt_module == 2,
        launch.rZ0 = launch.rZ0(launch.rZ0 >= 0);
    elseif opt_module == 3,
        launch.rZ0 = launch.rZ0(launch.rZ0 <= 0);
    end 
    %
    disp('------------------------------------------------');
    for ib = 1:length(launch.bNpar0),
        disp(['Npar0 = ',num2str(launch.bNpar0(ib)),' - Power = ',num2str(launch.bPlhtot(ib)/1e6),' (MW)']);
    end
    disp(' ');disp('------------------------------------------------');
    disp(['Total LH power in the launched spectrum (',int2str(length(launch.bNpar0)),' rays) : ',num2str(sum(launch.bPlhtot)/1e6),' (MW)']);
    disp('------------------------------------------------');disp(' ');
    %
    opt_OK = iselect_jd({'Yes','No'},'Confirm the LH power spectrum deduced from ALOHA:',opt_gui,select.style,1);
    %
    if opt_OK == 1,
        break
    else
        clear('s');
    end                       
end
%
launch.antenna = external.antenna;
launch.id = [launch.id,'_',make_aloha_simulid_yp(external.antenna.aloha)];
launch.bNpar0 = imag(launch.bNpar0);
%