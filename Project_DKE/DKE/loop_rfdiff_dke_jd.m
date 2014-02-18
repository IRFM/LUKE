function [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = loop_rfdiff_dke_jd(dkepath,dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waveparam)
%
% This function splits the calculation of rfdiff_dke_jd
% with possible use of distributed computing
%
[dkecluster] = clustermode_luke(dkeparam.clustermode,'rfdiff_dke_jd',dkepath);
nproc = dkecluster.scheduler.clustersize;
%
ny = max(waveparam.biy_rf);
nproc = min([ny,nproc]);
dkecluster.scheduler.clustersize = nproc;
%
waveparams = cell(1,nproc);
nyd = ceil(ny/nproc);
%
for iproc=1:nproc,
    %
    bmask = (waveparam.biy_rf >= nyd*(iproc-1)+1) & (waveparam.biy_rf <= min([ny,nyd*iproc]));    
    %
    waveparams{iproc} = struct;
    waveparams{iproc}.model = waveparam.model;
    waveparams{iproc}.biy_rf = waveparam.biy_rf(bmask)-nyd*(iproc-1);
    waveparams{iproc}.bir_rf = waveparam.bir_rf(bmask);
    waveparams{iproc}.bds_rf = waveparam.bds_rf(bmask);
    waveparams{iproc}.bomega_rf = waveparam.bomega_rf(bmask);
    waveparams{iproc}.bopt_rf = waveparam.bopt_rf(bmask);
    waveparams{iproc}.bthetab_rf = waveparam.bthetab_rf(bmask);
    waveparams{iproc}.bB_rf = waveparam.bB_rf(bmask);
    waveparams{iproc}.bNpar_rf = waveparam.bNpar_rf(bmask);
    waveparams{iproc}.bdNpar_rf = waveparam.bdNpar_rf(bmask);
    waveparams{iproc}.bNperp_rf = waveparam.bNperp_rf(bmask);
    waveparams{iproc}.bepolp_rf = waveparam.bepolp_rf(bmask);
    waveparams{iproc}.bepolm_rf = waveparam.bepolm_rf(bmask);
    waveparams{iproc}.bepolz_rf = waveparam.bepolz_rf(bmask);
    waveparams{iproc}.bphinorm_rf = waveparam.bphinorm_rf(bmask);
    waveparams{iproc}.n_rf_list = waveparam.n_rf_list;
    %
end
%
[flags,ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = mdce_run('rfdiff_dke_jd',{dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,''},9,waveparams,dkecluster);
%
ZXYD_rf = conc_field_jd(ZXYD_rf);
ZXYF_rf = conc_field_jd(ZXYF_rf);
ZXYD_rf_tp = NaN;%conc_field_jd(ZXYF_rf_tp);       
ZXYF_rf_tp = NaN;%conc_field_jd(ZXYF_rf_tp);       
%
npn = gridindex_rf{1}.npn;
nmhu = gridindex_rf{1}.nmhu;
nr = gridindex_rf{1}.nr;
nr_dke = gridindex_rf{1}.nr_dke;
nn_rf = gridindex_rf{1}.nn_rf;
%
ny = gridindex_rf{1}.ny;
mask_y = gridindex_rf{1}.mask_y;
gridindex_rf{1} = rmfield(gridindex_rf{1},{'npn','nmhu','nr','nr_dke','nn_rf','ny','mask_y'});
for iproc = 2:nproc,
    %
    ny = ny + gridindex_rf{iproc}.ny;
    mask_y = [mask_y;gridindex_rf{iproc}.mask_y + nyd*(iproc-1)];
    gridindex_rf{iproc} = rmfield(gridindex_rf{iproc},{'npn','nmhu','nr','nr_dke','nn_rf','ny','mask_y'});
    %
end
%
gridindex_rf = conc_field_jd(gridindex_rf);
gridindex_rf.mask_y = mask_y;
gridindex_rf.npn = npn;
gridindex_rf.nmhu = nmhu;
gridindex_rf.nr = nr;
gridindex_rf.nr_dke = nr_dke;
gridindex_rf.nn_rf = nn_rf;
gridindex_rf.ny = ny;
%
end
%
function sout = conc_field_jd(sin)
%
sout = struct;
nin = length(sin);
%
fields = fieldnames(sin{1});
%
for ifield = 1:length(fields),
    %
    field = fields{ifield};
    %
    sout.(field) = sin{1}.(field);
    for iin = 2:nin,
        %
        sout.(field) = [sout.(field);sin{iin}.(field)];
        %
    end
    %
end
%
end


