% test screening condition
close all
clear all
clc
%
atoms = {'Argon','Tungsten'};%'Tungsten','Xenon','Copper','Iron','Argon','Neon','Oxygen','Nitrogen','Carbon','Beryllium','Helium'
models = {'Tseng-Pratt-Botto'};%'Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'
%
fk = [0.1,0.5,0.9];%fraction of kinetic energy
%
mc2 = 511;
alpha = 1/137;
%
Ec = logspace(0,5,1000)/mc2;%relativistic units
%
E0 = Ec + 1;%relativistic units
p0 = sqrt(E0.^2 - 1);%relativistic units
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
%
siz = 20+14i;
%
xlab = 'E_c (MeV)';
ylab = 'r_{max}, a_Z [a_0]';
%
for iatom = 1:length(atoms)
    %
    for jmodel = 1:length(models)
        %
        ionradius = ionradius_yp(atoms{iatom},models{jmodel});
        %
        figure('Name',['Screening effect on bremsstrahlung, ',atoms{iatom},' (Z = ',int2str(ionradius.Z),')'])
        %
        tit = ['Screening effect on bremsstrahlung, ',atoms{iatom},' (Z = ',int2str(ionradius.Z),')'];
        %
        for ik = 1:length(fk)
            %
            k = fk(ik)*Ec;
            %
            E = E0 - k;%relativistic units
            p = sqrt(E.^2 - 1);%relativistic units
            %
            qmin = p0 - p - k;
            %
            rmax = alpha./qmin;%a0 units
            %
            leg={['k/E_c = ',num2str(fk(1))],['k/E_c = ',num2str(fk(2))],['k/E_c = ',num2str(fk(3))]};
            graph1D_jd(Ec*mc2/1000,rmax,1,1,xlab,ylab,tit,leg,NaN,NaN,linestyle{ik},'none',linecolor{1},2,siz,gca);
            %
            grid on
            %
        end
        %
        %
        for iZ = 1:length(ionradius.Z0)
            %
            rion = alpha*ionradius.a(iZ)/2*ones(size(Ec));
            %
            leg={['k/E_c = ',num2str(fk(1))],['k/E_c = ',num2str(fk(2))],['k/E_c = ',num2str(fk(3))],['Atomic model : ',models{jmodel}]};
            graph1D_jd(Ec*mc2/1000,rion,1,1,xlab,ylab,tit,leg,NaN,NaN,linestyle{4},'none',linecolor{3},2,siz,gca);
            %
            hold on
            grid on
        end
        %
    end
end
