function err_RC = aloha_err_RC(ne0,sc,rc)
%
sc.plasma.ne0 = ne0;
%
sc = aloha_scenario(sc);
%
err_RC = norm(sc.results.RC - rc);
%





