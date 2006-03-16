function [xlambda,xYval,xYflag] = inv_ebwES_jd(xq,N,xabr,xguess);
%
global q_ebw_ES N_ebw_ES abr_ebw_ES
%
h = waitbar(0,'Calculates ES Roots');
%
for ix = 1:length(xq);
%
    q_ebw_ES = xq(ix);
    N_ebw_ES = N;
    abr_ebw_ES = xabr(ix);
    guess_ES = xguess(ix);
%
    try
        [xlambda(ix),xYval(ix),xYflag(ix)] = fzero(@F_jd,guess_ES);
    catch
        xlambda(ix) = NaN;
        xYval(ix) = NaN;
        xYflag(ix) = 0;
    end
%
    waitbar(ix/length(xq),h);
end
close(h)
%
% -----------------------------------------------
%
function Y = F_jd(lambda);
%
global q_ebw_ES N_ebw_ES abr_ebw_ES
%
alpha = lambda/abr_ebw_ES^2;
Xlambda = repmat(lambda,[N_ebw_ES,1]);
I = besseli(1:N_ebw_ES,lambda)'; % takes the Bessel function on lambda with orders 1:N
Y = alpha - 2*sum(exp(-Xlambda).*I.*(1:N_ebw_ES)'.^2./(q_ebw_ES^2 - (1:N_ebw_ES)'.^2));








