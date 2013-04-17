function locid_simul = make_tail_simulid_jd(tail)
%
% This function creates a standard id string from tail and fluctuation parameters
%
if isstruct(tail) && ~isempty(fieldnames(tail)),
    if isinf(tail.dtn),
        locid_simul = 'static_tail';
    else
        locid_simul = ['fluct_tail_dtn_',num2str(tail.dtn)];
    end
    %
    if tail.mode == 1,% Gaussian distribution model 
        locid_simul =  [locid_simul,'_gauss_fwhm_',num2str(tail.bfwhm(1))];
    elseif tail.mode == 2,% Linear tail distribution model 
        if isinf(tail.dtn),
            error('No static model for linear tail. Please specify dtn.')
        end
        locid_simul =  [locid_simul,'_linear_tail_Nmax_',num2str(abs(tail.bNparmax_tail(1))),'_opt_',num2str(real(tail.bopt_tail(1)))];
    elseif tail.mode == 3,% calc_tail_jd distribution model 
        locid_simul =  [locid_simul,'_calc_tail_jd_Nmax_',num2str(abs(tail.bNparmax_tail(1))),'_n_',num2str(tail.bn_tail(1)),...
            '_P_',num2str(tail.bP_tail(1)),'_opt_',num2str(tail.bopt_tail(1))];
    else
        error('tail parameters not consistent.')
    end
else
    locid_simul = '';
end
