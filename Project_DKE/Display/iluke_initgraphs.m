
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
