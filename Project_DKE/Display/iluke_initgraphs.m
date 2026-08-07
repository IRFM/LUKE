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

% empty graphs structure

graphs = struct;
graphs.handles = [];
graphs.info = '';
graphs.tag = '';
graphs.curtime = 0;
graphs(1) = [];% empty structure but keep memory of fields

ngraphs = 2+length(shotimes);%new,all,shotimes

lukeobj.plot1.gindex = zeros(1,ngraphs);
lukeobj.plot2.gindex = zeros(1,ngraphs);
lukeobj.plot3.gindex = zeros(1,ngraphs);

cleartags = cell(1,ngraphs);
cleartags(:) = {{}};

graphss = cell(1,ngraphs);
graphss(:) = {graphs};
clear ngraphs graphs
