function bounce_ripple_jd(bounce_mode,pnmax,xmhubounce2,ir_display,Zmripple)
%
% Draws the bounce and ripple loss domains
%
nmhu_ripple = 100;
%
if bounce_mode >= 1,%Draw bounce domain boundaries
    %
    pparmax = pnmax*sqrt(xmhubounce2(ir_display));
    pperpmax = pnmax*sqrt(1 - xmhubounce2(ir_display));
    %
    graph1D_jd([0,pparmax],[0,pperpmax],0,0,'','','',NaN,NaN,NaN,'-','none','k',2);
    graph1D_jd([0,-pparmax],[0,pperpmax],0,0,'','','',NaN,NaN,NaN,'-','none','k',2);
    %
	if isempty(Zmripple) == 0,
    	%if isnan(Zmripple) == 0,%Draw the magnetic ripple loss cone
            %
            xpndetrap = Zmripple.xpndetrap;
            xmhusupertrap = cos((90 - Zmripple.xthetaloss)*pi/180);
            %
            mhu_ripple = linspace(-xmhusupertrap(ir_display),xmhusupertrap(ir_display),nmhu_ripple);           
            pparsupertrap = xpndetrap(ir_display)*mhu_ripple;%For contour plot of the supertrapped domain
            pperpsupertrap = xpndetrap(ir_display)*sqrt(1-mhu_ripple.^2);%For contour plot of the supertrapped domain
            %
            pparmin = xpndetrap(ir_display)*xmhusupertrap(ir_display);
            pperpmin = xpndetrap(ir_display)*sqrt(1-xmhusupertrap(ir_display)^2);
            pparmax = pnmax*xmhusupertrap(ir_display);
            pperpmax = pnmax*sqrt(1-xmhusupertrap(ir_display)^2);
            %
            graph1D_jd(pparsupertrap,pperpsupertrap,0,0,'','','',NaN,NaN,NaN,'--','none','k',2);
            graph1D_jd([pparmin,pparmax],[pperpmin,pperpmax],0,0,'','','',NaN,NaN,NaN,'--','none','k',2);
            graph1D_jd([-pparmin,-pparmax],[pperpmin,pperpmax],0,0,'','','',NaN,NaN,NaN,'--','none','k',2);
		%end
    end
end
%
%--------------------------------------------------------------------------
%
