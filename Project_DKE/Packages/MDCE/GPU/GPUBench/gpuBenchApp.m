% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
classdef GPUBenchApp < handle
%
% Usage:
%     app.GPUBenchApp

  properties
      AppPath = {'/GPUBench'};
	  AppClass = 'GPUBenchApp';
	  AppHandle;
	  AppCount = 0;
      Increment = 1;
	  Decrement = 0;
      Output;
      CurrClass;
      Version = '13a';
  end  
  methods (Static)
      function count = refcount(increment)
          persistent AppCount;
          if(isempty(AppCount))              
              AppCount = 1;
          else
              if(increment)
                  AppCount = plus(AppCount,1);
              else
                  AppCount = minus(AppCount,1);
              end
          end
          count = AppCount;
       end
  end
  
  methods
    % Create the application object
    function obj = GPUBenchApp()      
      obj.CurrClass = metaclass(obj);
      startApp(obj)
    end

    function value = get.AppPath(obj)
       appview = com.mathworks.appmanagement.AppManagementViewSilent;
       appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);
           
       myAppsLocation = char(appAPI.getMyAppsLocation);
       
       value = cellfun(@(x) fullfile(myAppsLocation, x), obj.AppPath, 'UniformOutput', false);
    end

    % Start the application
    function startApp(obj)
        % Put the application directory on the path
        %allpaths = genpath(obj.AppPath{:});
        %addpath(strrep(allpaths, [obj.AppPath{:} filesep 'metadata;'], ''));      

        % Must load function (force by using function handle) or nargout lies.
        % Check if the app is a GUIDE app
        if nargout(@gpuBenchApp) == 0  
            eval('gpuBenchApp');
        else
			obj.AppHandle = eval('gpuBenchApp');   
        end 
        % Increment the reference count by one    
        GPUBenchApp.refcount(obj.Increment);
        if(ishandle(obj.AppHandle))
		% Setup cleanup code on figure handle using onCleanup object
            cleanupObj = onCleanup(@()appinstall.internal.stopapp([],[],obj));
	    appdata = getappdata(obj.AppHandle);
	    appfields = fields(appdata);
	    found = cellfun(@(x) strcmp(x,'AppCleanupCode'), appfields);
	    if(~any(found))
		setappdata(obj.AppHandle, 'AppCleanupCode', cleanupObj);     
	    end  
        end
    end
  end
end
