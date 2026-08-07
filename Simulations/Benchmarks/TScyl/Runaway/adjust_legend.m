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
boxtrim = 0.85;%1;%
lineshift = 0;
textshift = -0.05;

fch = get(gcf,'children');
leg = fch(1);%legend
%
set(leg,'PlotBoxAspectRatio',[1,boxtrim,1]);

lch = get(leg,'children');

for ich = 2:3:length(lch),
    set(lch(ich),'ydata',get(lch(ich),'ydata') + lineshift),
end
for ich = 3:3:length(lch),
    set(lch(ich),'position',get(lch(ich),'position') + [0,textshift,0]);
end
