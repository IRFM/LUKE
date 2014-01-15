h = findobj(0,'type','figure','tag','luke');
if isempty(h)
       h=figure('tag','luke');
else
       figure(h);
end   
clf
set(h,'defaultaxesfontsize',10,'defaultaxesfontweight','bold','defaultaxesfontname','times', ...
	'defaultlinelinewidth',2,'color',[1 1 1])
   
subplot(2,2,1)   	 
,
	  graph1D_jd(equilDKE.xrho,j_OHM_c,0,0,'\rho','J_{ohm} (MA/m^2)',[par.conf,',I_{ohm} = ',num2str(I_OHM_c*1000,3),' (kA)'],NaN,'','','-','none','b',2);hold off,drawnow
%
%title('Ohmic current profile')
subplot(2,2,2)   


	  graph1D_jd(equilDKE.xrho,p_OHM_c,0,0,'\rho','P_{ohm} (MW/m^3)',['P_{ohm} = ',num2str(P_OHM_c*1000,4),' (kW) / P_{synohm}= ',num2str(P_OHMsyn_c*1000,4),' kw'],NaN,'','','-','none','r',2);drawnow
%title('Ohmic power')
subplot(2,2,3)   
        nolh = 1;
        nofce = 0;
        if isstruct(cons)
           if isfield(cons,'lh_cons')
             nolh = 1;
           else
             nolh = 0;
           end
           if isfield(cons,'ecrh_cons')
             nofce = 1;
           else
             nofce = 0;
           end
        end
	if nolh == 1 & nofce == 0 
	  graph1D_jd(equilDKE.xrho,j_RF_c,0,0,'\rho','J_{LH} (MA/m^2)',['I_{LH} = ',num2str(I_RF_c,3),' (MA) / Ip =',num2str(equi.ip/1e6,3),' (MA)'],NaN,'','','-','none','b',2);hold off,drawnow
        elseif nolh==0 & nofce == 1
	  graph1D_jd(equilDKE.xrho,j_RF_c,0,0,'\rho','J_{EC} (MA/m^2)',['I_{EC} = ',num2str(I_RF_c,3),' (MA) / Ip =',num2str(equi.ip/1e6,3),' (MA)'],NaN,'','','-','none','b',2);hold off,drawnow
        else
	  graph1D_jd(equilDKE.xrho,j_RF_c,0,0,'\rho','J_{tot} (MA/m^2)',['I_{tot} = ',num2str(I_RF_c,3),' (MA) / Ip =',num2str(equi.ip/1e6,3),' (MA)'],NaN,'','','-','none','b',2);hold off,drawnow
        end
%title('LH Current profile (consistent with E-field)')

subplot(2,2,4)
        if nolh == 1 & nofce == 0 
          if strcmp(par.lob,'No')
            if isstruct(cons)
              Pinj = sum(abs(cons.lh_cons))/1e3*0.7;
            else
              Pinj = sum(abs(cons))/1e3*0.7;
            end
          else
            if isstruct(cons)
              Pinj = sum(abs(cons.lh_cons))/1e3;
            else
              Pinj = sum(abs(cons))/1e3;
            end
          end
	  graph1D_jd(equilDKE.xrho,p_RF_c,0,0,'\rho','P_{LH} (MW/m^3)',['P_{LH} = ',num2str(P_RF_c*1000,4),' (kW) / Pinj=',num2str(Pinj,4),' kW'],NaN,'','','-','none','r',2);drawnow
        elseif nolh==0 & nofce == 1
          Pinj = sum(abs(cons))/1e3;
	  graph1D_jd(equilDKE.xrho,p_RF_c,0,0,'\rho','P_{EC} (MW/m^3)',['P_{EC} = ',num2str(P_RF_c*1000,4),' (kW) / Pinj=',num2str(Pinj,4),' kW'],NaN,'','','-','none','r',2);drawnow
        else
          if strcmp(par.lob,'No')
            Plh  = sum(abs(cons.lh_cons))*0.7;
          else
            Plh  = sum(abs(cons.lh_cons));
          end
          Pec  = sum(abs(cons.ecrh_cons));
          Pinj = Pec+Plh;
 	  graph1D_jd(equilDKE.xrho,p_RF_c,0,0,'\rho','P_{tot} (MW/m^3)',['P_{tot} = ',num2str(P_RF_c*1000,4),' (kW) / Pinj=',num2str(Pinj,4),' kW'],NaN,'','','-','none','r',2);drawnow
       end

%
%title('LH power')
