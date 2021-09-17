function sluke_params_help

%
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------- HELP SPARAMS_GENERATOR -----------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            disp('The function ''sluke_sparams_generator'' helps the user to build a structure ''sparams'' for ')
            disp('running the ''sluke'' code. This structure contains all parameters for full or partial sluke')
            disp('simulations. It is recommended to read the script ''sluke_sparams_generator.m'' before ')
            disp('using it.')
            disp(' ')
            disp('Various calls :')
            disp(' ')
            disp('sparams = sluke_params_generator; --> interactive mode to build a new sparams structure.')
            disp(' ')
            disp('sparams = sluke_params_generator(''h''); or sparams = sluke_params_generator(''help'') --> ')
            disp('help mode only. The sparams structure is empty.')
            disp(' ')
            disp('sparams = sluke_params_generator(''PRESET''); --> default preset sparams where ''PRESET'' may')
            disp('be : ')
            disp(' - ''ALOHA_TEST'' : test case to build LAUNCH structures using ALOHA coupling code. ')
            disp(' ')
            disp('sparams = sluke_params_generator(sparams); --> interactive mode to build a modified sparams');
            disp('structure.');
            disp(' ')
            disp('NOTE : The sparams structures may be build by a dedicated and customized script.')
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            
            
            
            
            %
fns = fieldnamesr(sparams);
%
if ~isempty(find(contains(fns,'machine')))
    %
    sparams.help.machine = 'Name of tokamaks';
    sparams.format.machine = 'string';
    %
end
%
if ~isempty(find(contains(fns,'discharge')))
    %
    sparams.help.discharge.shot = 'Discharge index';
    sparams.help.discharge.tmin = 'Minimum of the considered time interval (s)';
    sparams.help.discharge.tmax = 'Maximum of the considered time interval (s)';
    sparams.help.discharge.nt = 'Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure.';
    %
    sparams.help.simul.id = 'Customized identification of the parameters';
    sparams.help.simul.enable = 'Enable (1) or not (0) the simulations';
    %
    sparams.help.equil.id = '';
    %
    sparams.help.launch.id = '';
    %
    sparams.help.transp.id = '';
    %
    sparams.help.ripple.id = '';
    %
    sparams.format.discharge.shot = 'string';
    sparams.format.discharge.tmin = 'float';
    sparams.format.discharge.tmax = 'float';
    sparams.format.discharge.nt = 'integer';
    %
    sparams.format.simul.id = 'string';
    sparams.format.simul.enable = 'boolean';
    %
    sparams.format.equil.id = 'string';
    %
    sparams.format.launch.id = 'string';
    %
    sparams.format.transp.id = 'string';
    %
    sparams.format.ripple.id = 'string';

    %
end
        
