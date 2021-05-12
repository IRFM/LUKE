function err_RC = aloha_err_RC(ne0,sc,rc)
%
sc.plasma.ne0 = ne0;
%
sc = aloha_scenario(sc);
%
err_RC = sqrt(sum(sc.results.RC./rc - 1).^2);
%





