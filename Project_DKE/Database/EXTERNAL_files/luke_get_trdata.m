function d = luke_get_trdata( a )
%LUKE_GET_TRDATA d = luke_get_trdata( a )
%   For an input structure a this function returns the output data
%   structure d containing time resolved data from TCV for LUKE.
%
% Same input for all modes (other inputs optional):
%   a.shot
%   a.diag{i}.name
%   a.diag{j}.isel for a.diag{j}.name=='ECRH'
%
% Input for mode with automatic selection of (all) Thomson points:
%   do not set a.t -> all Thomson points
%   a.t set, but not a.dtres -> use a.t with Thomson resolution
%
% Input for mode with fixed time points and limited averaging range:
%   put time points in a.t and set a.dtres=[]
%   set a.dtreslim to specify averaging range limit (default: Thomson time)
%
% Input for mode with equidistant resolution in time interval:
%   set a.t as a time interval
%   specify the resolution in a.dtres
%
%
%   J. Kamleitner, CRPP, EPFL, Feb 2014

% first version:
%   * without conditional averaging
%   * with preselected diagnostics (depending on availability and parameters shot, t, dtres)

% required data can be seen in LUKE function load_externaldata_TCV.m
% best to use EQUIL as first diagnostic since others are based on it.

% dependencies:
% CRPP mds functions, tcvget, TCV database access and liuqe (latter on lac5)
% gti_chdtres.m
% gti_filter.m
% make_eqdsk.m

% some constants
% dtres0_pgyro=1e-4;
try
    outputpath_default=sprintf('/tmp/LUKE_%s_%s',getenv('USER'),timeid_jd(clock));
catch
    outputpath_default=sprintf('/tmp/LUKE_%s',getenv('USER'));
end

% common time base if not defined
if(~isfield(a,'t') || ~isfield(a,'dtres'))
    mdsopen(a.shot);
    tthom=mdsvalue('\results::thomson:times');
    dtres_default=round(60*min(diff(tthom)))/60;
    dtreslim_default=dtres_default;
    [tip,ip]=tcvget('IP');
    mdsclose;
    itip50=find(abs(ip)>=max(abs(ip))/2);
    t_default=tip(itip50([1 end]));
elseif(~isfield(a,'dtreslim') || isempty(a,'dtreslim'))
    mdsopen(a.shot);
    tthom=mdsvalue('\results::thomson:times');
    dtreslim_default=round(60*min(diff(tthom)))/60;
    mdsclose;
end

% go through the list of requested diagnostics
for i=1:length(a.diag)
    % set the parameters (priority for parameters in the diag struct)
    diag=a.diag{i};
    % shot
    shot=a.shot;
    if(isfield(diag,'shot'))
        shot=diag.shot;
    end
    % t
    if(isfield(a,'t'))
        t=a.t;
    else
        t=t_default;
    end
    if(isfield(diag,'t'))
        t=diag.t;
    end
    % dtres
    if(isfield(a,'dtres'))
        if(~isfield(a,'t') && isempty(a.dtres))
            dtres=dtres_default;
        else
            dtres=a.dtres;
        end
    else
        dtres=dtres_default;
    end
    if(isfield(diag,'dtres'))
        dtres=diag.dtres;
    end
    % dtreslim
    if(isfield(a,'dtreslim') && ~isempty(a.dtreslim))
        dtres=a.dtres;
    else
        dtreslim=dtreslim_default;
    end
    if(isfield(diag,'dtreslim'))
        dtres=diag.dtreslim;
    end
    % outputpath
    if(isfield(a,'outputpath'))
        outputpath=a.outputpath;
    else
        outputpath=outputpath_default;
    end
    if(isfield(diag,'outputpath'))
        outputpath=diag.outputpath;
    end
    if(~exist(outputpath,'dir'))
        system(sprintf('mkdir -p %s',outputpath));
    end
    % isel
    if(isfield(diag,'isel'))
        isel=diag.isel;
    end
    % tca
    if(isfield(a,'tca'))
        tca=a.tca;
    else
        tca=NaN;
    end
    if(isfield(diag,'tca'))
        tca=diag.tca;
    end
    % tcr
    if(isfield(a,'tcr'))
        tcr=a.tcr;
    else
        tcr=NaN;
    end
    if(isfield(diag,'tcr'))
        tcr=diag.tcr;
    end
    
    % read the data of the diagnostic
    fprintf('- Get %s data for shot %d, t=[%g,%g]s.\n',diag.name,shot,t(1),t(end));
    switch diag.name
        case 'BT'
            d.btsign.shot=shot;
            d.btsign.rawdiag={'MagneticProbes'};
            d.btsign.time=mean(t([1 end]));
            mdsopen(shot);
            d.btsign.data=sign(mdsdata('\magnetics::iphi[$]',d.btsign.time));
            mdsclose;
        case 'IP'
            d.ipsign.shot=shot;
            d.ipsign.rawdiag={'CoilCurrents'};
            d.ip.shot=shot;
            d.ip.rawdiag={'MagneticProbes'};
            d.ipsign.time=mean(t([1 end]));
            [Ip,tip,d.ipsign.data]=ip_trapeze_woos(shot);
            [d.ip.time,d.ip.data]=gti_chdtres(tip,Ip',t,dtres,dtreslim);
        case 'VLOOP'
            d.vloop.shot=shot;
            d.vloop.rawdiag={'FluxLoops'};
            mdsopen(shot);
            vloop=tdi('\magnetics::vloop[*,"001"]');
            mdsclose;
            % if no coherent/condistional averaging:
            if(dtres_bt(2e-3,t,dtres,dtreslim))
                % if requested time resolution better than 2ms filter out
                % the strong 1.3kHz noise using a 630Hz low-pass filter
                [tvl,vl]=gti_filter(vloop.dim{1},vloop.data',[-Inf 630]);
                [d.vloop.time,d.vloop.data]=gti_chdtres(tvl,vl,t,dtres,dtreslim);
            else
                % otherwise no filter is applied, just averaging
                [d.vloop.time,d.vloop.data]=gti_chdtres(vloop.dim{1},vloop.data',t,dtres,dtreslim);
            end
        case 'NE'
            d.ne.shot=shot;
            % if no coherent/condistional averaging:
            if(dtres_bt(0.016,t,dtres,dtreslim))
                d.ne.rawdiag={'FIR','LIUQE'};
                firpar=gti_gds(shot,t([1 end]),'FIR','Flux1D','MinFishReg','Unique','Unique',0);
                firpar.diag.frequency.filter.hlb='no';
                firout=gti_expert(firpar);
                d.ne.source='GTI';
                fprintf('  . Using %s profiles from %s for NE.\n',d.ne.rawdiag{1},d.ne.source);
                [d.ne.time,d.ne.data]=gti_chdtres(firout.res.time,firout.res.inverted,t,dtres,dtreslim);
                d.ne.rho=firout.res.rho;
            else
                d.ne.rawdiag={'Thomson','LIUQE','FIR'};
                neraw=luke_get_nete_raw(diag.name,shot);
                d.ne.source=neraw.source;
                fprintf('  . Using %s profiles from %s for NE.\n',d.ne.rawdiag{1},d.ne.source);
                jnotnan=~any(isnan(neraw.data));
                [d.ne.time,d.ne.data]=gti_chdtres(neraw.time(jnotnan),neraw.data(:,jnotnan),t,dtres,dtreslim);
                d.ne.rho=neraw.rho;
            end
        case 'TE'
            d.te.shot=shot;
            % if no coherent/condistional averaging:
%             if(dtres_bt(0.016,t,dtres,dtreslim))
%                 d.te.rawdiag={'DMPX','LIUQE','Thomson'};
%                 par=
%             else
                d.te.rawdiag={'Thomson','LIUQE'};
                teraw=luke_get_nete_raw(diag.name,shot);
                d.te.source=teraw.source;
                fprintf('  . Using %s profiles from %s for TE.\n',d.te.rawdiag{1},d.te.source);
                jnotnan=~any(isnan(teraw.data));
                [d.te.time,d.te.data]=gti_chdtres(teraw.time(jnotnan),teraw.data(:,jnotnan),t,dtres,dtreslim);
                d.te.rho=teraw.rho;
%             end
        case 'TI'
            d.ti.shot=shot;
            % for the moment, do not set T_i (will lead to usage of T_e normalization)
            d.ti.rawdiag='None';
            d.ti.time=mean(t);
            d.ti.rho=linspace(0,1,41);
            d.ti.data=NaN(41,1);
        case 'ZEFF'
            d.zeff.shot=shot;
            % for the moments use the single value from proffit
            % (ZX if proffit not available), should to be replaced by a
            % multi-diagnostic Z_eff profile
            d.zeff.rawdiag={'XTOMO','Thomson','LIUQE','FIR'};
            mdsopen(shot);
            zeffproffit=tdi('\results::proffit:z_eff');
            mdsclose;
            if(mod(zeffproffit.status,2) && ~isempty(zeffproffit.data) && ~all(all(isnan(zeffproffit.data))));
                d.zeff.source='proffit';
                zeff_tdi=zeffproffit;
            else
                mdsopen(shot);
                zeff_zx=tdi('\results::zx');
                mdsclose;
                d.zeff.source='zx';
                zeff_tdi=zeff_zx;
            end
            fprintf('  . Using Z_eff value from %s.\n',d.zeff.source);
            % if no coherent/condistional averaging:
            [d.zeff.time,d.zeff.data]=gti_chdtres(zeff_tdi.dim{1},zeff_tdi.data(:,1)',t,dtres,dtreslim);
        case 'ZAXIS'
            d.zaxis.shot=shot;
            d.zaxis.rawdiag={'LIUQE'};
            mdsopen(shot);
            zraw=tdi('\results::z_axis');
            mdsclose;
            % if no coherent/condistional averaging:
            [d.zaxis.time,d.zaxis.data]=gti_chdtres(zraw.dim{1},zraw.data',t,dtres,dtreslim);
        case 'ECRH'
            d.ecrh.shot=shot;
            d.ecrh.rawdiag={'ECRH'};
            d.ecrh.isel=isel;
            mdsopen(shot);
            praw=tdi('\results::toray.input:p_gyro');
            mdsclose;
            % get the polarisation
            % if no coherent/condistional averaging:
            ox_t=gti_chdtres([],[],t,dtres,dtreslim);
            [ox_xfrac,ox_times,~]=ecpol_ox_fraction(shot,0,ox_t);
            for j=1:length(isel)    % do a loop over all selected launchers
                k=isel(j);
                % get power: independent of harmonic, kW->W
                itknotnan=~isnan(praw.data(:,k));
                % if no coherent/condistional averaging:
                if(~any(itknotnan))
                    [d.ecrh.pow{k}.time,d.ecrh.pow{k}.data]=gti_chdtres(mean(t),NaN,t,dtres,dtreslim);
                else
                    [d.ecrh.pow{k}.time,d.ecrh.pow{k}.data]=gti_chdtres(praw.dim{1}(itknotnan),1e3*praw.data(itknotnan,k)',t,dtres,dtreslim);
                end
                if(k<7) % X2 launchers 1-6
                    % constant data (from collect_parameters_for_luke.m)
                    ang.freq=82.7e9;
                    ang.P1_R=1.3072;
                    ang.P1_theta=52.013/180*pi;
                    ang.P2_R=1.1906;
                    ang.P2_d=0.01;
                    if(j==1 || j==4)
                        ang.P1_Z=-0.05865;
                        ang.P2_Z=0.0645;
                        ang.P3_Z=-0.0025;
                    else
                        ang.P1_Z=0.39885;
                        ang.P2_Z=0.522;
                        ang.P3_Z=0.455;
                    end
                    ang.P3_tor=0.0;
                    % data from tree
                    mdsopen(shot);
                    thetaraw=mdsvalue(sprintf('_theta=\\ecrh::launchers:theta_l:x2_%d',k))'*pi/180;
                    timeraw=mdsvalue('dim_of(_theta)');
                    phiraw=mdsvalue(sprintf('\\ecrh::launchers:phi_l:x2_%d',k))'*pi/180;
                    mdsclose;
                    % if no coherent/condistional averaging:
                    [ang.time,allangdata]=gti_chdtres(timeraw,[thetaraw;phiraw],t,dtres,dtreslim);
                    ang.theta=allangdata(1,:);
                    ang.phi=allangdata(2,:);
                    ang.theta_eff=-atan(ang.theta).*cos(ang.phi);
                    ang.phi_eff=atan(tan(ang.theta).*sin(ang.phi))./sqrt(1+tan(ang.theta).^2.*cos(ang.phi).^2);
                    % ox fraction data
                    % if no coherent/condistional averaging:
                    % put into d.ecrh.xfrac{k}.time and .data
                    d.ecrh.xfrac{k}.time=ox_t;
                    d.ecrh.xfrac{k}.data=NaN(1,numel(ox_t));
                    for ell=1:length(ox_t)
                        if(any(ox_times==ox_t(ell)))
                            d.ecrh.xfrac{k}.data(1,ell)=ox_xfrac(k,ox_times==ox_t(ell));
                        end
                    end
                else    % X3 launchers 7-9
                    % constant data (from collect_parameters_for_luke.m)
                    ang.freq=118.e9;
                    ang.P1_Z=.9885;
                    ang.P1_theta=0;
                    ang.P2_Z=ang.P1_Z;
                    ang.P2_d=0;
                    ang.P3_Z=ang.P1_Z;
                    % data from tree
                    mdsopen(shot);
                    datatemp=mdsvalue('_theta=\ecrh::launchers:theta_l:x3');
                    if(ischar(datatemp))
                        thetaraw=NaN;
                        timeraw=mean(t);
                    else
                        thetaraw=datatemp'*pi/180;
                        timeraw=mdsvalue('dim_of(_theta)');
                    end
                    datatemp=mdsvalue(sprintf('\\ecrh::launchers:phi_l:x3_%d',k));
                    if(ischar(datatemp))
                        phiraw=NaN(size(timeraw));
                    else
                        phiraw=datatemp*pi/180*ones(size(thetaraw));
                    end
                    datatemp=mdsvalue('\ecrh::launchers:R:x3');
                    if(ischar(datatemp))
                        rraw=NaN(size(timeraw));
                    else
                        rraw=datatemp';
                    end
                    mdsclose;
                    % if no coherent/condistional averaging:
                    [ang.time,allangdata]=gti_chdtres(timeraw,[thetaraw;phiraw;rraw],t,dtres,dtreslim);
                    thetaraw=allangdata(1,:);
                    phiraw=allangdata(2,:);
                    ang.P1_R=allangdata(3,:);
                    ang.P2_R=ang.P1_R;
                    ang.P3_tor=(ang.P1_R+0.125).*tan(phiraw);
                    ang.theta=atan2(sqrt(sin(thetaraw).^2+tan(phiraw).^2),cos(thetaraw));
                    ang.phi=atan2(tan(phiraw),sin(thetaraw));
                    ang.theta_eff=-thetaraw;
                    ang.phi_eff=atan2(tan(phiraw),abs(cos(thetaraw)));
                end
                d.ecrh.ang{k}=ang;
                clear ang;
            end
        case 'EQUIL'
            d.equil.shot=shot;
            d.equil.rawdiag={'LIUQE'};
            % if no coherent/condistional averaging:
            fprintf('- Checking availability of LIUQE equilibria for shot %d at requested time points\n',shot);
            if( isempty(dtres) && (length(t)==1 || ~((max(diff(t))/min(diff(t))-1)<5*eps)) )
                % specify times
                d.equil.time=t;
                % get times where equilibria exist already
                mdsopen(shot);
                t_liuqe=mdsvalue('dim_of(\results::i_p)');
                mdsclose;
                for it=1:length(d.equil.time)
                    if(min(d.equil.time(it)-t_liuqe)>eps(single(1)))
                        fprintf('  . LIUQE not available in MDS tree for t=%gs.\n',d.equil.time(it));
                        job = matstandardjob_jd('runmat');
                        job.funcopy=false;
                        tempcommand=sprintf('/home/codes/liuqe/liuqe %d %g %g %d',shot,d.equil.time(it),d.equil.time(it),1);
                        sprintf('  . running LIUQE on lac5 for requested time point %gs.\n',d.equil.time(it));
                        if(~exist('matremote_jd','file'))
                            pwd_save=pwd;
                            cd('/home/decker');
                            startup;
                            cd(pwd_save);
                        end
                        [err,res,text]=matremote_jd('system',{tempcommand},feval('remote_CRPP_LAC5','','local'),job);
                        % check if LIUQE ran on lac5 (warning if not)
                        if(~isempty(err))
                            warning('matremote_jd:LIUQE:failed','The LIUQE run on lac5 failed!');
                            disperr_jd(err);
                        elseif(res)
                            disp(text);
                            warning('matremote_jd:LIUQE:failed','The LIUQE run on lac5 failed, see output above!');
                        end
                    else
                        fprintf('  . LIUQE available in MDS tree for t=%gs.\n',d.equil.time(it));
                    end
                end
                % create the equilibrium files                
                make_eqdsk(shot,d.equil.time,outputpath,'TCV');
                d.equil.data=outputpath;                
            else
                % specify times
                if(isempty(dtres) || length(t)==1) % equidistant with dtres=[]
                    d.equil.time=t;
                    t1=d.equil.time(1);
                    t2=d.equil.time(end);
                    n12=length(d.equil.time);
                else % equidistant with dtres specified
                    z1=ceil(t(1)/dtres-5*eps);
                    z2=floor(t(end)/dtres+5*eps);
                    t1=z1*dtres;
                    t2=z2*dtres;
                    n12=z2-z1+1;
                    d.equil.time=linspace(t1,t2,n12);
                end
                % check if equilibria exist already
                mdsopen(shot);
                t_liuqe=mdsvalue('dim_of(\results::i_p)');
                mdsclose;
                flag_run=false(size(d.equil.time));
                for it=length(d.equil.time)
                    if(min(d.equil.time(it)-t_liuqe)>eps(single(1)))
                        fprintf('  . LIUQE not available in MDS tree for t=%gs.\n',d.equil.time(it));
                        flag_run(it)=true;
                    end
                end
                if(any(flag_run))
                    % run LIUQE if not all equilibria available (using matremote_jd)
                    job = matstandardjob_jd('runmat');
                    job.funcopy=false;
                    if(sum(flag_run)==1)
                        tempcommand=sprintf('/home/codes/liuqe/liuqe %d %g %g 1',shot,d.equil.time(flag_run),d.equil.time(flag_run));
                        sprintf('  . running LIUQE on lac5 for requested time point %gs.\n',d.equil.time(flag_run));
                    elseif(sum(flag_run)==2)
                        t_temp=d.equil.time(flag_run);
                        tempcommand=sprintf('/home/codes/liuqe/liuqe %d %g %g 2',shot,t_temp(1),t_temp(2));
                        sprintf('  . running LIUQE on lac5 for requested time points %gs and %gs.\n',t_temp(1),t_temp(2));
                    else
                        tempcommand=sprintf('/home/codes/liuqe/liuqe %d %g %g %d',shot,t1,t2,n12);
                        sprintf('  . running LIUQE on lac5 for all requested times linspace(%g,%g,%d)s.\n',t1,t2,n12);
                    end
                    if(~exist('matremote_jd','file'))
                        pwd_save=pwd;
                        cd('/home/decker');
                        startup;
                        cd(pwd_save);
                    end
                    [err,res,text]=matremote_jd('system',{tempcommand},feval('remote_CRPP_LAC5','','local'),job);
                    % check if LIUQE ran on lac5 (warning if not)
                    if(~isempty(err))
                        warning('matremote_jd:LIUQE:failed','The LIUQE run on lac5 failed!');
                        disperr_jd(err);
                    elseif(res)
                        disp(text);
                        warning('matremote_jd:LIUQE:failed','The LIUQE run on lac5 failed, see output above!');
                    end
                else
                    fprintf('  . LIUQE already available in MDS tree for all requested times: no LIUQE run.\n');
                end
                % create the equilibrium files
                make_eqdsk(shot,d.equil.time,outputpath,'TCV');
                d.equil.data=outputpath;
            end
    end
end


end

function neteraw=luke_get_nete_raw(nete,shot)
    if(strcmp(nete,'NE'))
        proffitnode='\results::proffit.avg_time:neft_abs';
        autonode='\results::thomson.profiles.auto:ne:foo';
    elseif(strcmp(nete,'TE'))
        proffitnode='\results::proffit.avg_time:teft';
        autonode='\results::thomson.profiles.auto:te:foo';
    end
    mdsopen(shot);
    neteproffit=tdi(proffitnode);
    mdsclose;
    % check proffit data
    takeproffit=(mod(neteproffit.status,2) && ~isempty(neteproffit.data) && ~all(all(isnan(neteproffit.data))));
    if(takeproffit)
        % put time coordinate in second dimension, radial in
        % first dimension
        it=find(strcmp('s',neteproffit.dimunits) | strcmp('time [s]',neteproffit.dimunits));
        neteraw.time=neteproffit.dim{it};
        neteraw.rho=neteproffit.dim{3-it};
        if(it==1)
            neteraw.data=neteproffit.data';
        else
            neteraw.data=neteproffit.data;
        end
        neteraw.source='proffit';
    else
        % get Thomson autofits
        mdsopen(shot);
        neteauto=tdi(autonode);
        mdsclose;
        % check autofits data
        takeauto=(mod(neteauto.status,2) & ~isempty(neteauto.data) & ~all(all(isnan(neteauto.data))));
        if(takeauto)
            % put time coordinate in second dimension, radial in
            % first dimension
            it=find(strcmp('s',neteauto.dimunits) | strcmp('time [s]',neteauto.dimunits));
            neteraw.time=neteauto.dim{it};
            neteraw.rho=neteauto.dim{3-it};
            if(it==1)
                neteraw.data=neteauto.data';
            else
                neteraw.data=neteauto.data;
            end
            neteraw.source='autofits';
        else
            error('No Thomson data available - try to run proffit or to reset autofits');
            % take FIR data (to be implemented later)
        end
    end
end


function flag=dtres_bt(val,t,dtres,dtreslim)
    flag=false;
    if(~isempty(dtres)) % specification by dtres
        if(~isnan(dtres(1)) && (dtres(1)<val)) % dtres(1)
            flag=true;
        elseif((length(dtres)==2) && ~isnan(dtres(2)) && (dtres(2)<val) ) % dtres(2)
            flag=true;
        elseif((length(dtres)==3) && ~all(isnan(dtres(2:3))) && (nanmean(dtres(2:3))<val)) % dtres(2:3)
            flag=true;
        end
    else % specification by dtreslim
        if(~isempty(dtreslim))
            if(all(size(dtreslim)==[1,1]))
                if(~isnan(dtreslim) && (dtreslim<val))
                    flag=true;
                end
            elseif(all(size(dtreslim)==[1,2]))
                if(~all(isnan(dtreslim)) && (nanmean(dtreslim)<val))
                    flag=true;
                end
            elseif(all(size(dtreslim)==[2,1]))
                if(~isnan(dtreslim(1)) && dtreslim(1)<val)
                    flag=true;
                end
            elseif(all(size(dtreslim)==[2,2]))
                if(~all(isnan(dtreslim(1,:))) && (nanmean(dtreslim(1,:))<val))
                    flag=true;
                end
            end
        end
    end
    if(length(t)>1 && (min(diff(t))<val)) % specification by t spacing
        flag=true;
    end
end
