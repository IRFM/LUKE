function dataout = mdsplusload(datain)
% MATREMOTE - Remote mdsplus database access
%
% Remote mdsplus database access 
%
% by Y. Peysson (CEA/IRFM, yves.peysson@cea.fr) and J. Decker (CRPP/EPFL, joan.decker@epfl.ch)
%
try
    %
    dataout.mdsplus.ipserver = datain.ipserver;
    dataout.mdsplus.shotnumber = datain.shotnumber;
    %
    dataout.mdsplus.connect = mdsconnect(datain.ipserver);%connect to MDS+ server
    %
    for itree =  1:length(datain.tree),
        %
        dataout.mdsplus.tree(itree).name = datain.tree(itree).name;
        dataout.mdsplus.tree(itree).open = mdsopen(datain.tree(itree).name,str2num(datain.shotnumber));%open the MDS+ tree
        %
        for ivalue = 1:length(datain.tree(itree).values),
            %
            [data,status_data]= mdsvalue(datain.tree(itree).values(ivalue));
            [time,status_time] = mdsvalue(['dim_of(',datain.tree(itree).values{ivalue},')']); % measured in seconds
            %
            dataout.mdsplus.tree(itree).values(ivalue).name = datain.tree(itree).values(ivalue);
            dataout.mdsplus.tree(itree).values(ivalue).units = datain.tree(itree).units(ivalue);
            %
            dataout.mdsplus.tree(itree).values(ivalue).data = data;
            dataout.mdsplus.tree(itree).values(ivalue).status_data = status_data;
            %
            dataout.mdsplus.tree(itree).values(ivalue).time = time;
            dataout.mdsplus.tree(itree).values(ivalue).status_time = status_time;
            %
            clear data status_data time status_time
            %
        end
        %
        mdsclose;
        %
    end
    %
    mdsdisconnect;
    %
catch
    dataout.mdsplus.err = ['Error reading MDS+ database at ip address ',datain.ipserver,' ',getReport(MException.last)];
end
%

