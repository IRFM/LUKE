function launch = imake_tail_yp(launch)
%
% This function interactively builds the tail structure
%
if ~isfield(launch,'tail')
    if length(launch.bNpar0) <= 10,
        tail = struct;
        tail.dtn = input_dke_yp('Tail dtn ',Inf);
        tail.mode = input_dke_yp('Tail mode spectrum: (0) no tail model, (1)  Gaussian, (2) Linear, (3) calc_tail_jd ',3,0:3,'',[1,1]);
        tail.bNparmax_tail = input_dke_yp('Nparmax_tail: npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is 0, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)',0);
        tail.bn_tail = input_dke_yp('n_tail: number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen)',5);
        tail.bP_tail = input_dke_yp('P_tail: power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen))',0.5);
        tail.bopt_tail = input_dke_yp('opt_tail: final power fraction of the tail @ Nparmax_tail (+1i) Adjust initial dNpar0 such that initial and tail lobes have the same width',1 + 1i);
        %
        launch.tail = tail;
        %
        if isfield(launch,'tail')
            if launch.tail.bn_tail > 0 && (launch.tail.bP_tail > 0 || isnan(launch.tail.bP_tail)),
                launch.id = [launch.id,'_TAIL_',make_tail_simulid_jd(launch.tail)];
            end
        end
    else
        disp('WARNING: the launch structure has more than ten lobes')
    end
else
    disp('WARNING: a structure for the tail LH model already exists')
end
