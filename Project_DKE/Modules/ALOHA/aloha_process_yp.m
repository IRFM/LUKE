function sc = aloha_process_yp(sc,rc,optim)
%
ne0 = fminsearch(@(X) aloha_err_RC(X,sc,rc),sc.plasma.ne0,optimset('TolFun',optim.tolfun,'TolX',optim.tolx,'MaxIter',optim.nitmax));
%ne0 = fminsearch(@(X) aloha_err_RC(X,sc,rc),sc.plasma.ne0);
%
sc.plasma.ne0 = ne0;
%
sc = aloha_scenario(sc);

    
    
    
    
