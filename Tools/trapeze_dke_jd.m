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
function [mhu] = trapeze_dke_jd(mhumin,mhumax,dmhu,dmhumax);
%
% Generates a grid with linear increase in the steps from the edge to the center
%
%   INPUTS:
%
%       - mhumin : lower bound for the grid
%       - mhumax : upper bound for the grid
%       - dmhu : egde grid step
%       - dmhumax : maximum grid step
%
%   OUTPUTS:
%
%       - mhu : resulting grid
%
rfactor = dmhumax/dmhu;
mhuw = (mhumax - mhumin)/2;
if mhuw >= 2*dmhu & rfactor >= 2
    for i=1:rfactor-1
        mhun(i) = dmhu*((i+2)*(i+1)/2-1);
    end
    n = max(find(mhun <= mhuw));
    j = n;
    while j > 0
        d = 2*(mhuw - mhun(j));
        dmhuj = (j+1)*dmhu;
        dmhujp = (j+2)*dmhu;
        m = floor(d/dmhuj);
        if m > 0 & (d/m) <= dmhujp
            mhum = mhumin + [0 mhun(1:j-1)];
            mhup = mhumax - [0 mhun(1:j-1)];
            mhuc = linspace(mhumin + mhun(j),mhumax - mhun(j),m+1);
            mhu = [mhum,mhup,mhuc];
            break
        end
        j = j-1;
    end
else
    j=0;
end
if j == 0
    d = 2*mhuw;
    dmhuj = dmhu;
    m = floor(d/dmhuj);
    mhu = linspace(mhumin,mhumax,m+2);
end
mhu = sort(mhu);
    

