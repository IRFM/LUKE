function [listofgraphtypes,...
          listoflinestyles,listoflinewidths,listoflinecolors,...
          listofmarkerstyles,listofmarkersizes,listofmarkercolors]...
    = GetGraphProperties_jd;
% 
% This function is used to obtain the lists of graph property items
%

%
% List of graph types
%
listofgraphtypes{1} = 'xte';
listofgraphtypes{2} = 'xne';
%
% List of line styles
%
listoflinestyles{1} = '-';
listoflinestyles{2} = '--';
listoflinestyles{3} = ':';
listoflinestyles{4} = '-.';
listoflinestyles{5} = 'none';
%
% List of line width
%
listoflinewidths{1} = 0.5;
listoflinewidths{2} = 1.0;
listoflinewidths{3} = 2.0;
listoflinewidths{4} = 3.0;
listoflinewidths{5} = 4.0;
listoflinewidths{6} = 6.0;
listoflinewidths{7} = 8.0;
listoflinewidths{8} = 10.0;
listoflinewidths{9} = 15.0;
listoflinewidths{10} = 20.0;
listoflinewidths{11} = 25.0;
listoflinewidths{12} = 30.0;
%
% List of line colors
%
listoflinecolors{1} = [0,0,0];
listoflinecolors{2} = [0,0,1];
listoflinecolors{3} = [1,0,0];
listoflinecolors{4} = [0,0.5,0];
listoflinecolors{5} = [0,0.75,0.75];
%
% List of marker styles
%
listofmarkerstyles{1} = 'none';
listofmarkerstyles{2} = 'o';
listofmarkerstyles{3} = 'x';
listofmarkerstyles{4} = '.';
listofmarkerstyles{5} = 's';
%
% List of marker sizes
%
listofmarkersizes{1} = 0.5;
listofmarkersizes{2} = 1.0;
listofmarkersizes{3} = 2.0;
listofmarkersizes{4} = 3.0;
listofmarkersizes{5} = 4.0;
listofmarkersizes{6} = 6.0;
listofmarkersizes{7} = 8.0;
listofmarkersizes{8} = 10.0;
listofmarkersizes{9} = 15.0;
listofmarkersizes{10} = 20.0;
listofmarkersizes{11} = 25.0;
listofmarkersizes{12} = 30.0;
%
% List of marker colors
%
listofmarkercolors{1} = 'auto';
listofmarkercolors{2} = [0,0,0];
listofmarkercolors{3} = [0,0,1];
listofmarkercolors{4} = [1,0,0];
listofmarkercolors{5} = [0,0.5,0];
listofmarkercolors{6} = [0,0.75,0.75];
