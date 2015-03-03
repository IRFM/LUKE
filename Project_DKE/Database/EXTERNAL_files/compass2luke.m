function data_out = compass2luke(shotnum)
%
%Read data in COMPASS database.
%
cdb = cdb_client();
disp('Start of reading signals from CDB')

data_out.I_plasma = cdb.get_signal(['I_plasma:',num2str(shotnum)]);
data_out.U_loop = cdb.get_signal(['U_loop_02:',num2str(shotnum)]);
%
% EFIT DATA
%
data_out.efit.triangularity_lower_lcfs = cdb.get_signal(['triangularity_lower_lcfs:',num2str(shotnum)]);  % many of them
data_out.efit.ii = cdb.get_signal(['ii:',num2str(shotnum)]);  % internal inductance 
data_out.efit.psi_RZ = cdb.get_signal(['psi_RZ:',num2str(shotnum)]); 
data_out.efit.Ip = cdb.get_signal(['Ip:',num2str(shotnum)]); 
data_out.efit.R_mag_axis = cdb.get_signal(['R_mag_axis:',num2str(shotnum)]);
data_out.efit.Z_mag_axis = cdb.get_signal(['Z_mag_axis:',num2str(shotnum)]); 
%
% NOT MEASURED
% signal = cdb.get_signal('ion_temperature:7529');  
%
% THOMSON SCATTERING DATA
%
try 
    data_out.ne = cdb.get_signal(['ne/THOMSON:',num2str(shotnum)]);
    data_out.te = cdb.get_signal(['Te/THOMSON:',num2str(shotnum)]);

%         disp(['number of NaNs: ',num2str([length( find(isnan(data_out.ne.data))), length( find(isnan(data_out.te.data)))])]);
%         disp(num2str(size(data_out.ne.data)))

    for it=1:length(data_out.ne.time_axis.data)
        indnan=isnan(data_out.ne.data(it,:));

        data_out.ne.data(it, indnan) = interp1 ( data_out.ne.axis1.data (~indnan), data_out.ne.data(it,~indnan),  ...
          data_out.ne.axis1.data(indnan)  );

        data_out.te.data(it, indnan) = interp1 ( data_out.te.axis1.data (~indnan), data_out.te.data(it,~indnan), ...
            data_out.te.axis1.data(indnan)  );                                        

        indnan=isnan(data_out.ne.data(it,:));
        data_out.ne.data(it,indnan) = min(data_out.ne.data(it,:));
        data_out.te.data(it,indnan) = min(data_out.te.data(it,:));
    end

%         disp(num2str(size(data_out.ne.data)))  
%         disp(num2str(data_out.ne.data));
    disp(['Number of NaNs in THOMSON data: ',num2str([length( find(isnan(data_out.ne.data))), length( find(isnan(data_out.te.data)))])]);
catch 
    disp('THOMSON data not available')
end     
%
disp('End of reading signals from CDB')        
%
% plot(signal.time_axis.data,-signal.data)
%     ti = 125;
%     contour(signal.axis1.data(ti,:),signal.axis2.data(ti,:), reshape(signal.data(ti,:,:), [33 33] ),50 );
%     xlabel('R [m]')
%     ylabel('Z [m]')
