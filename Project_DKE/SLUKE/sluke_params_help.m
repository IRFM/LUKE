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