% script iluke_hxrcamimport
%
hxr.cam = {};
%
if isfield(external.hxr,'ap') && isfield(external.hxr,'hxrparam'),% TCV data loaded by luke_get_hxr_diag_tcv
    %
    hxr.param = external.hxr.hxrparam;
    %
    ncams = length(external.hxr.ap.cams);
    %
    hxr.cam = cell(1,ncams);
    %
    for icam = 1:ncams
        %
        hxr.cam{icam} = tcv2r5x2(external.hxr.ap,icam);
        %
        hxr.cam{icam}.selectedchord = hxr.cam{icam}.centralchord;
        %
    end
    %
    hxr.param.kmin = external.hxr.hxr.kdiag_hxr(1,end);
    hxr.param.kmax = external.hxr.hxr.kdiag_hxr(2,end);
    %
    % process chords for each equilibrium and camera
    %
    flag_output = find(status.output == 1);
    %
    plasmas = equils(flag_output);
    nt = length(flag_output);
    %
    set(lukeobj.busy.handle,'Visible','on');drawnow;
    %
    for it = 1:nt,
        %
        if isfield(outputs{flag_output(it)},'radialDKE'),
            plasmas{it}.radialDKE = outputs{flag_output(it)}.radialDKE;
            plasmas{it}.Zcurr = outputs{flag_output(it)}.Zcurr;
        elseif isfield(outputs{flag_output(it)},'savefile') && exist(outputs{flag_output(it)}.savefile,'file'),
            data = load(outputs{flag_output(it)}.savefile);
            if isfield(data,'lukestructs') && isfield(data.lukestructs,'output'),
                plasmas{it}.radialDKE = data.lukestructs.output.radialDKE;
                plasmas{it}.Zcurr = data.lukestructs.output.Zcurr;
            else
                error('LUKE outputs cannot be retrieved for HXR calculations');
            end
        else
            error('LUKE outputs cannot be retrieved for HXR calculations');
        end
        %
    end
    %
    set(lukeobj.busy.handle,'Visible','off');drawnow;
    %
    mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
    %
    if mdce_mode > 2,
        mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
    end
    %
    dkecluster = clustermode_luke(mdce_mode,'',dkepath);%MatLab distributed computing environment
    %
    set(lukeobj.busy.handle,'Visible','on');drawnow;
    %
    [flag,Zbremchords,equilHXRs] = mdce_run('bremchord_dke_yp',{dkeparam,dkedisplay,'',[],[],hxr.cam,hxr.param},3,plasmas,dkecluster);
    %
    for it = 1:nt,
        %
        sdiags{1,flag_output(it)} = cell(1,ncams);
        %
        for icam = 1:ncams,
            sdiags{1,flag_output(it)}{icam}.Zbremchord = Zbremchords{it}{icam};
            sdiags{1,flag_output(it)}{icam}.equilHXR = equilHXRs{it}{icam};
        end
        %
        status.sdiag(1,flag_output(it)) = 1;
    end
    %
    set(lukeobj.busy.handle,'Visible','off');drawnow;
    %
    clear ncams icam it plasmas data mdce_mode dkecluster Zbremchords equilHXRs
    %
end
    


