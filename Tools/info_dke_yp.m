function [] = info_dke_yp(mode,a,display_mode,color_mode)
%
%	Customized message display (may be colorized, with cprintf.m)
%
%	Input:
%
%		- mode: type of message [1,1]
%          (1): --------------------------- Essai de texte ---------------------------
%          (2): -------> message
%          (3): message...
%               -----------------
%          (4):  - message
%          (5): -----------------
%               message
%               -----------------
%          (6): WARNING: message
%		- a: the text (string) [1,m]
%		- display_mode: yes -> 1, no -> 0 [1,1]
%         (default: 0)
%       - color_mode: 'Black','Cyan','Magenta','Blue','Green','Red','Yellow','White' (string) [1,m]
%         (default: 'Black' if empty)
%
%	Output: none
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 2,
	info_dke_yp(2,'Wrong number of input arguments for info_dke_yp');
	return
end
if nargin < 3,
    display_mode = 1;
    color_mode = '';
end
if nargin < 4,
    color_mode = '';
    if isempty(display_mode),display_mode = 1;end
end
%
[lukeversion,matver] = LUKEversion_jd;
if str2num(matver) < 713,color_mode = '';end
%
if mode == 1,
	a1 = [];
	sa = size(a);
	nmax = 68; 
	n0 = nmax-sa(2);
	n1 = fix(n0/2);
	n2 = n0-n1;
	for i = 1:n1,a1 = [a1,'-'];end
	if n2==n1,
 		a2 = a1;
	else
 		a2 = [a1,'-'];
    end
    %
    if isempty(color_mode)
        disp([a1,' ',a,' ',a2]);
    else
        cprintf(color_mode,[a1,' ',a,' ',a2,'\n']);
    end
elseif mode == 2,
    if isempty(color_mode)
        disp(['-------> ',a]);
    else
        cprintf(color_mode,['-------> ',a,'\n']);
    end
elseif mode == 3,
	ttt = [];
	sa = size(a);
    if isempty(color_mode)
        disp([a,'...']);
    else
        cprintf(color_mode,[a,'...','\n']);
    end
	for i = 1:sa(2)+10,
		ttt= [ttt,'-'];
    end
    %
    disp(ttt);
elseif mode == 4,
	ttt = [];
	sa = size(a);
    if isempty(color_mode)
        disp([' - ',a]);
    else
        cprintf(color_mode,[' - ',a,'\n']);
    end
    if isempty(color_mode)
        disp(ttt);
    else
        cprintf(color_mode,[ttt,'\n']);
    end
elseif mode == 5,
	ttt = [];
	sa = size(a);
	for i = 1:sa(2)+10,
		ttt= [ttt,'-'];
    end
    %
    disp(ttt);
    %
    if isempty(color_mode)
        disp(a);
    else
        cprintf(color_mode,[a,'\n']);
    end
    %
    disp(ttt);
elseif mode == 6,
    if isempty(color_mode)
        disp(['WARNING: ',a]);
    else
        cprintf(color_mode,['WARNING: ',a,'\n']);
    end
end
