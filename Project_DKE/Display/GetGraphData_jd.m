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
function [x,y,z,xlab,ylab,zlab,warnstr] = GetGraphData_jd(handles, graph);
%
% This function retrieves the data from a given scenario and graph type and
% sends the data as a (x,y) or (x,y,z) group. 
%
x = [];
y = [];
z = [];
xlab = '';
ylab = '';
zlab = '';
warnstr = [];
%
load(graph.scenario,'graphs')
%
if exist('graphs','var'),
    %
    NumberOfGraphs = length(graphs);
    %
    for igraph = 1:NumberOfGraphs
        if isequal(graphs{igraph}.type,graph.type),
            x = graphs{igraph}.x;
            y = graphs{igraph}.y;
            z = graphs{igraph}.z;
            xlab = graphs{igraph}.xlab;
            ylab = graphs{igraph}.ylab;
            zlab = graphs{igraph}.zlab;
            return
        end
    end
else
    NumberOfGraphs = 0;
end
%
if isequal(graph.type,handles.listofgraphtypes{1}),% xte
    %
    load(graph.scenario,'equil');
    x = psi2rho_jd(equil,equil.ppsi/equil.ppsi(length(equil.ppsi)));
    y = equil.pTe;
    z = [];
    xlab = '\rho';
    ylab = 'T_e';
    zlab = '';
    %
end
%
if isequal(graph.type,handles.listofgraphtypes{2}),% xne
    %
    load(graph.scenario,'equil');
    x = psi2rho_jd(equil,equil.ppsi/equil.ppsi(length(equil.ppsi)));
    y = equil.pne;
    z = [];
    xlab = '\rho';
    ylab = 'n_e';
    zlab = '';
    %
end
%
graphs{NumberOfGraphs + 1}.type = graph.type;
graphs{NumberOfGraphs + 1}.x = x;
graphs{NumberOfGraphs + 1}.y = y;
graphs{NumberOfGraphs + 1}.z = z;
graphs{NumberOfGraphs + 1}.xlab = xlab;
graphs{NumberOfGraphs + 1}.ylab = ylab;
graphs{NumberOfGraphs + 1}.zlab = zlab;
%
save(graph.scenario,'graphs','-append')
