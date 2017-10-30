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
disp('********************************************************************************************')
disp('WARNING: check that the ALOHA power spectrum generates a co-current or a counter current. ')
disp('Do a flipud(antenna.dP_nz) and fliplr(antenna.dP) accordingly in the ALOHA file before ');
disp('using ALOHA data in irunluke_jd. Co-current: Npar0(main peak) < 0 if sign(Ip)*sign(Bt) > 0');
disp(' and Npar0(main peak) > 0 if sign(Ip)*sign(Bt) < 0');
disp('********************************************************************************************')
%
spectrum.dP_nz = real(external.antenna.aloha.results.dP_nz);
spectrum.nz = external.antenna.aloha.results.nz;
spectrum.ny = external.antenna.aloha.results.ny;
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
    val(1) = sum(external.antenna.aloha.results.dP_nz*external.antenna.aloha.results.dnz);
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