function bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,ripple,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap)
%
% Draws the bounce and ripple loss domains
%
if bounce_mode >= 1,%Draw bounce domain boundaries
    line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))],'color','k');
    set(gca,'linewidth',2);
    line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))],'color','k');
    set(gca,'linewidth',2);
%
	if isempty(ripple) == 0,
    	if isnan(ripple) == 0,%Draw the magnetic ripple loss cone
			hold on,gcl = plot(pparsupertrap_ref,pperpsupertrap_ref,'g');hold off
			set(gcl,'linewidth',2);
			line([xpndetrap_ref(ir_display)*xmhusupertrap(ir_display),pnmax_S*xmhusupertrap(ir_display)],[xpndetrap_ref(ir_display)*sqrt(1-xmhusupertrap(ir_display)^2),pnmax_S*sqrt(1-xmhusupertrap(ir_display)^2)],'LineStyle','-','color','g','linewidth',2);
			line([-xpndetrap_ref(ir_display)*xmhusupertrap(ir_display),-pnmax_S*xmhusupertrap(ir_display)],[xpndetrap_ref(ir_display)*sqrt(1-xmhusupertrap(ir_display)^2),pnmax_S*sqrt(1-xmhusupertrap(ir_display)^2)],'LineStyle','-','color','g','linewidth',2);					
		end
    end
end
%
%--------------------------------------------------------------------------
%
