function data = compass2luke(shotnum)

    cdb = cdb_client();
    disp('Start of reading signals from CDB')
    
    data.I_plasma = cdb.get_signal(['I_plasma:',num2str(shotnum)]);
    data.U_loop = cdb.get_signal(['U_loop_02:',num2str(shotnum)]);

    % EFIT DATA
    data.triangularity = cdb.get_signal(['triangularity_lower_lcfs:',num2str(shotnum)]);  % many of them
    data.int_inductance = cdb.get_signal(['ii:',num2str(shotnum)]);  % internal inductance 
    data.psi = cdb.get_signal(['psi_RZ:',num2str(shotnum)]); 

    % NOT MEASURED
    % signal = cdb.get_signal('ion_temperature:7529');  

    % THOMSON SCAT. DATA
    try 
        data.ne = cdb.get_signal(['ne/THOMSON:',num2str(shotnum)]);
        data.te = cdb.get_signal(['Te/THOMSON:',num2str(shotnum)]);
        
%         disp(['number of NaNs: ',num2str([length( find(isnan(data.ne.data))), length( find(isnan(data.te.data)))])]);
%         disp(num2str(size(data.ne.data)))
                
        for it=1:length(data.ne.time_axis.data)
            indnan=isnan(data.ne.data(it,:));
            
            data.ne.data(it, indnan) = interp1 ( data.ne.axis1.data (~indnan), data.ne.data(it,~indnan),  ...
              data.ne.axis1.data(indnan)  );
          
            data.te.data(it, indnan) = interp1 ( data.te.axis1.data (~indnan), data.te.data(it,~indnan), ...
                data.te.axis1.data(indnan)  );                                        
            
            indnan=isnan(data.ne.data(it,:));
            data.ne.data(it,indnan) = min(data.ne.data(it,:));
            data.te.data(it,indnan) = min(data.te.data(it,:));
        end
                
%         disp(num2str(size(data.ne.data)))  
%         disp(num2str(data.ne.data));
        disp(['Number of NaNs in THOMSON data: ',num2str([length( find(isnan(data.ne.data))), length( find(isnan(data.te.data)))])]);
    catch 
        disp('THOMSON data not available')
    end     

    disp('End of reading signals from CDB')        

    % plot(signal.time_axis.data,-signal.data)
%     ti = 125;
%     contour(signal.axis1.data(ti,:),signal.axis2.data(ti,:), reshape(signal.data(ti,:,:), [33 33] ),50 );
%     xlabel('R [m]')
%     ylabel('Z [m]')
