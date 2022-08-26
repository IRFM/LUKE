function analyse_rho_star(equil)

n = 30;
a = equil.a;
rho_stars=a/n:a/n:a;

equill = equil;
amplitudes = [];
sol_qualities = [];
Uas = [];

for rho = rho_stars
    equill.rho_star = rho;
    [amp,~,sol_quality] = computeAmplitudes(equill);
    sol_qualities = cat(1,sol_qualities,sol_quality);
    amplitudes = cat(1,amplitudes,amp); 
    Uas = cat(1,Uas,U_a(equill,amp));
end

% quality of the solutions
markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name','Quality of solutions','Visible',visiblemode);
h.WindowState = 'maximized';

plot(rho_stars,sol_qualities,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho_* (m)','FontSize',fontsize);
ylabel('Quality (1=excellent ; 2=good ; 3=bad)','FontSize',fontsize);
title('Quality of the solution as a function of the matching radius','FontSize',fontsize);

% plot the internal energy
h = figure('Name','Internal energy','Visible',visiblemode);
h.WindowState = 'maximized';
plot(rho_stars,Uas./1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho_* (m)','FontSize',fontsize);
ylabel('U(a) (MJ)','FontSize',fontsize);
title('Internal energy U(a) as a function of the matching radius','FontSize',fontsize);
xline(equil.rho_star,'k--','LineWidth',1.5);

% plot of the coefficients
name_amps = ["a", "R_m","d2R_0(0)","d4R_0(0)", "Z_m","d2Z_0(0)","d4Z_0(0)", "\kappa_m","d2e(0)","d4e(0)", "dS_2(0)","d3S_2(0)", "dA_2(0)","d3A_2(0)", "dS_3(0)","d3S_3(0)", "dA_3(0)","d3A_3(0)"];
for j=1:length(name_amps)
    h = figure('Name',char(name_amps(j)),'Visible',visiblemode);
    h.WindowState = 'maximized';
    plot(rho_stars,amplitudes(:,j),'r-','LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    xlabel('\rho_* (m)','FontSize',fontsize);
    ylabel(name_amps(j),'FontSize',fontsize);
    title("Value of "+name_amps(j)+" as a function of the matching radius",'FontSize',fontsize);
end

end

