function [LUKE_struct] = CPO2LUKEstruct_yp(ver_mds,struct_name,CPO_struct,display_mode)
%LUKE - Function that build a LUKE compliant structure from the corresponding CPO in the ITM MDS+ database
%
%Function that build a LUKE compliant structure from the corresponding CPO in the ITM MDS+ database
%
% Input:
%
%   - ver_mds: version of the ITM MDS+ data format (4.09a, 4.10a,...). Important for the conversion to LUKE data format
%	- struct_name: CPO name that characterizes its type in the ITM database ('equilibrium', 'coreprof', etc)
%	- CPO_struct: CPO data
%	- display_mode: display results if any (0: do nothing, > 0: display results)
%
% Output:
%
%	- LUKE_struct: structure totally or partially compatible with LUKE package (for consistency problems with other ITM CPO's)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
[dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,clum] = pc_dke_yp;%Speed of light (m/s)
%
if nargin < 3,error('Not enough input arguments in CPO2LUKE_struct_yp.m');end
%
if nargin == 3,
    display_mode = 0;%display option
end
%
p_opt = -1;%printing option
%
mds_dataversion0 = str2num(ver_mds(1:end-1));%for using numbers
mds_dataversion1 = ver_mds(end:end);%for using 
%
if strcmp('equilibrium',struct_name),
    %
    if mds_dataversion0 >= 4.10,
        cocos = CPO_struct.datainfo.cocos;
    else
        cocos = '';
    end
    %
    grid_type = CPO_struct.profiles_2d.grid_type;%CPO is a java structure and it must be transfered to Matlab data first before any operation
    %
    if round(str2double(grid_type(1))) == 1,%rectangular grid
        xyBR = CPO_struct.profiles_2d.br;
        xyBZ = CPO_struct.profiles_2d.bz;
        xyBPHI = CPO_struct.profiles_2d.bphi;	
        %
        xypsi = CPO_struct.profiles_2d.psi;
        xypsi = xypsi/2/pi;
        psi = CPO_struct.profiles_1d.psi;
        psi = psi/2/pi;%Poloidal flux (with 1/2/pi)
        psia = CPO_struct.global_param.psi_bound;
        psia = psia/2/pi;
        psi0 = CPO_struct.global_param.psi_ax;
        psi0 = psi0/2/pi;
        %
        Rp = CPO_struct.global_param.mag_axis.position.r;	
        Zp = CPO_struct.global_param.mag_axis.position.z;
        %
        x = CPO_struct.profiles_2d.grid.dim1;
        x = x - Rp;
        y = CPO_struct.profiles_2d.grid.dim2;
        y = y - Zp;
        %
        Btor0 = CPO_struct.global_param.toroid_field.b0;%vacuum toroidal field (T) (for the sign only)
        %
        Ip = CPO_struct.global_param.i_plasma;%plasma current (A) (for the sign only)
        qspi = CPO_struct.profiles_1d.q;%signed safety factor
        % 
        if psi0 < psia, %IPHI is positive, PHI clockwise from top
            sigma = 1;
        else %IPHI is negative, PHI clockwise from top
            sigma = -1;
        end
        %
        xypsi = xypsi - psi0;%psi = 0 on the magnetic axis (arbitrary choice)
        psi = psi - psi0;
        psia = psia - psi0;
        %
        xypsin = xypsi/psia;%normalized poloidal magnetic flux
        psin = psi(:)'/psia;
        npsin = length(psin);%number of radial points (normalized grid point)
        %
        ntheta = 65;%number of theta points (poloidal angle)
        opt.sfac = 24;%have to increased when ray goes close to the magnetic axis
        opt.axenforce = true;
        %
        % (R,Z) to (psi,theta) grid conversion (two methods)
        %
        if isempty(xyBR) || isempty(xyBZ),%calculations of the poloidal B field from the poloidal magnetic flux
            %
            equil_magnetic_data.x = x;
            equil_magnetic_data.y = y;
            equil_magnetic_data.Rp = Rp;
            equil_magnetic_data.Zp = Zp;
            equil_magnetic_data.xypsin = xypsin;
            equil_magnetic_data.psia = psia;
            equil_magnetic_data.xBt = -xyBPHI(:,1);%sign change -> ITM: BPHI > 0 if direction counter clockwise, LUKE: BPHI > 0 direction is clockwise (both view from the top)
            equil_magnetic_data.psin = psin;
            equil_magnetic_data.pq = -qspi;%sign change -> ITM: Ip > 0 if direction counter clockwise, LUKE: Ip > 0 direction is clockwise (both view from the top)
            %
            [LUKE_struct,prho,pspsin,pspsinT] = equil_magnetic_rz2pt_jd(equil_magnetic_data,display_mode,p_opt,'','',npsin,ntheta,opt);
            %
        else,%direct interpolation of the magnetic field
            interp_method = 'spline';%interpolation method for grid conversion. 
            %
            [ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,ntheta,interp_method,display_mode,p_opt,'',opt);
            %
            ptBPHI = -griddata(x,y,xyBPHI',ptx,pty);%sign change -> ITM: BPHI > 0 if direction counter clockwise, LUKE: BPHI > 0 direction is clockwise (both view from the top)
            %
            ap = ptx(npsin,1);%Plasma minor radius on the LFS midplane
            psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
            ptR = Rp + ptx;
            %
            % Note that in LUKE we have B = F.gradphi + gradphi x gradpsi.
            %
            ptBx = griddata(x,y,xyBR',ptx,pty);
            ptBy = griddata(x,y,xyBZ',ptx,pty);
            %
            ptBP = sqrt(ptBx.^2 +ptBy.^2);
            ptB = sqrt(ptBP.^2 + ptBPHI.^2);
            %
            prho = ptx(:,1).'/ap;
            %
            if display_mode == 2, 
                %
                rx = [-fliplr(prho(2:npsin)),prho];
                rBx = [fliplr(ptBx(2:npsin,(ntheta+1)/2)'),ptBx(:,1)'];
                rBy = [fliplr(ptBy(2:npsin,(ntheta+1)/2)'),ptBy(:,1)'];
                rBPHI = [fliplr(ptBPHI(2:npsin,(ntheta+1)/2)'),ptBPHI(:,1)'];
                rBP = sqrt(rBx.^2 + rBy.^2);
                rB = sqrt(rBP.^2 + rBPHI.^2);
                %
                style = '-';
                marker = 'none';
                color1 = 'r';
                color2 = 'b';
                color3 = 'k';
                width = 2;
                siz = 20;
                red = 0.9;
                lspace = 0.7;
                bspace = 0.6;
                %
                xlab = 'r/a';
                ylab = 'B(T)';
                xlim = [-1,1];
                ylim = NaN;
                leg = ['B_T';'B_P';'B  '];
                %
                figure_yp('','B field radial profiles','clf');
                graph1D_jd(rx,abs(rBPHI),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
                graph1D_jd(rx,rBP,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width);
                graph1D_jd(rx,rB,0,0,xlab,ylab,'',leg,xlim,ylim,style,marker,color3,width);
                %
                figure_yp('','B field poloidal dependence','clf');
                graph1D_jd(theta,ptB(2,:),0,0,'','','',NaN,'','',style,marker,'b',width);hold on
                plot(theta,ptB([2:end],:))
                legend(['r/a = ',num2str(prho(2))])
                axis([0,2*pi,0,ceil(max(max(ptB([2:end],:)))*10)/10])
                xlabel('\theta (rd)'),ylabel('B(T)')
            end
            %
            ptx(:,end) = ptx(:,1);
            pty(:,end) = pty(:,1);
            ptBx(:,end) = ptBx(:,1);
            ptBy(:,end) = ptBy(:,1);
            ptBPHI(:,end) = ptBPHI(:,1);
            %
            % equil structure
            %
            LUKE_struct.psi_apRp = psi_apRp;
            LUKE_struct.theta = theta;
            LUKE_struct.ptx = ptx;
            LUKE_struct.pty = pty;
            LUKE_struct.ptBx = ptBx;
            LUKE_struct.ptBy = ptBy;
            LUKE_struct.ptBPHI = ptBPHI;
            LUKE_struct.Rp = Rp;
            LUKE_struct.Zp = Zp;
        end
        %
        % For writing results in CPO in a consistent manner with ITM definitions
        %
        LUKE_struct.ITM.psi0 = psi0;
        LUKE_struct.ITM.psia = psia;
        LUKE_struct.ITM.sign_BHI = sign(Btor0);
        LUKE_struct.ITM.sign_Ip = sign(Ip);
    else
        error('This grid is not yet recognized in CPO2LUKE_struct_yp.m.')
    end
    %
    LUKE_struct.id = CPO_struct.datainfo.whatref.machine;
	%
elseif strcmp('coreprof',struct_name),
    %
    LUKE_struct.psi = CPO_struct.psi.value;% Unfortunately, the poloidal psi for the 1-D profiles is not consistent with the psi defined in the equil structure (number of grid points, min and max !!!)... who named that CPO's, Consistent Physical Object....
    LUKE_struct.psi = LUKE_struct.psi(:)';% Unfortunately, the poloidal psi for the 1-D profiles is not consistent with the psi defined in the equil structure (number of grid points, min and max !!!)... who named that CPO's, Consistent Physical Object....
    LUKE_struct.pTe = CPO_struct.te.value;%keV units
    LUKE_struct.pTe = LUKE_struct.pTe(:)'/1000;%keV units
    LUKE_struct.pne = CPO_struct.ne.value;
    LUKE_struct.pne = LUKE_struct.pne(:)';
    LUKE_struct.pzTi = CPO_struct.ti.value;%keV units
    LUKE_struct.pzTi = transpose(LUKE_struct.pzTi)/1000;%keV units
    LUKE_struct.pzni = CPO_struct.ni.value;
    LUKE_struct.pzni = transpose(LUKE_struct.pzni);
    LUKE_struct.zZi = CPO_struct.composition.zn;
    LUKE_struct.zZi = LUKE_struct.zZi(:)';
    LUKE_struct.zmi = CPO_struct.composition.amn;
    LUKE_struct.zmi = LUKE_struct.zmi(:)';
    %
    if isempty(LUKE_struct.zZi) || isempty(LUKE_struct.zmi) || isempty(LUKE_struct.pzTi) || isempty(LUKE_struct.pzni),
        %
        info_dke_yp(6,'Ion parameters are not consistently described in the ITM MDS+ database. 50-50 deuterium-tritium with electroneutrality is enforced.')
        %
        LUKE_struct.zZi = [1,1,1]; 
        LUKE_struct.zmi = [1,2,3];
        %
        if ~isempty(LUKE_struct.pTe) && ~isempty(LUKE_struct.pne),
            LUKE_struct.pzTi = ones(3,1)*LUKE_struct.pTe;
            LUKE_struct.pzni = ones(3,1)*LUKE_struct.pne;
            LUKE_struct.pzni(1,:) = 0;
            LUKE_struct.pzni(2,:) = LUKE_struct.pzni(2,:)/2;
            LUKE_struct.pzni(3,:) = LUKE_struct.pzni(3,:)/2;
        else
            info_dke_yp(6,'Both ion and electrons parameters are not consistently described. Please check the ITM MDS+ database.')
        end
    end
    %
elseif strcmp('antennas',struct_name),
    %
	if mds_dataversion0 == 4.09,
        %
        for ia = 1:length(CPO_struct.antenna_unit),
            if ~isempty(CPO_struct.antenna_unit(ia).antenna_ec.name),
                LUKE_struct{ia}.id = CPO_struct.antenna_unit(ia).antenna_ec.name;
                LUKE_struct{ia}.type = 'EC';
                LUKE_struct{ia}.omega_rf = CPO_struct.antenna_unit(ia).antenna_ec.frequency;%wave angular frequency (rad/s)
                LUKE_struct{ia}.omega_rf = LUKE_struct{ia}.omega_rf*2*pi;
                %
                LUKE_struct{ia}.yR_L = CPO_struct.antenna_unit(ia).antenna_ec.position.r;
                LUKE_struct{ia}.yZ_L = CPO_struct.antenna_unit(ia).antenna_ec.position.z;
                LUKE_struct{ia}.yphi_L = CPO_struct.antenna_unit(ia).antenna_ec.position.phi;	
                %
                % Launch angles definitions for ITM are identical to those for Prater benchmark (see ITER simulation example in LUKE)
                %
                beta = CPO_struct.antenna_unit(ia).antenna_ec.launchangles.beta;
                alpha = CPO_struct.antenna_unit(ia).antenna_ec.launchangles.alpha;
                LUKE_struct{ia}.yalpha_L = sign(beta)*pi - atan(tan(beta)/cos(alpha));
                LUKE_struct{ia}.ybeta_L = pi - acos(cos(beta)*sin(alpha));            
                %
                LUKE_struct{ia}.yP_L = CPO_struct.antenna_unit(ia).antenna_ec.power.value;
                LUKE_struct{ia}.dNpar0 = NaN;
                LUKE_struct{ia}.ns = 1000;
                LUKE_struct{ia}.method1 = 'pchip';%1D interpolation
                LUKE_struct{ia}.method2 = 'cubic';%2D interpolation
                %
                frequency = CPO_struct.antenna_unit(ia).antenna_ec.frequency;
                alpha = frequency*pi/clum;%for the Rayleigh length
                waist = CPO_struct.antenna_unit(ia).antenna_ec.beam.spot.waist;
                invcurvrad = CPO_struct.antenna_unit(ia).antenna_ec.beam.phaseellipse.invcurvrad;
                %
                yw = alpha^2*waist(1)^4*invcurvrad(1);%WARNING: circular shape only.
                %
                LUKE_struct{ia}.w0 = waist(1)/sqrt(1 + yw*invcurvrad(1));
                LUKE_struct{ia}.z_L = -yw/(1 + yw*invcurvrad(1));                        
                %
                LUKE_struct{ia}.mmode = -CPO_struct.antenna_unit(ia).antenna_ec.mode;%LUKE definitions -> O/X mode: -1/+1. ITM ones are opposite
            end
            %
            if ~isempty(CPO_struct.antenna_unit(ia).antenna_lh.name),
                disp('WARNING: LH antenna not yet considered in ITM')
            end
        end
    elseif mds_dataversion0 >= 4.10,
       %
        if isfield(CPO_struct,'antenna_ec'),
            for ia = 1:length(CPO_struct.antenna_ec),
                if ~isempty(CPO_struct.antenna_ec(ia).name),
                    LUKE_struct{ia}.id = CPO_struct.antenna_ec(ia).name;
                    LUKE_struct{ia}.type = 'EC';
                    frequency = CPO_struct.antenna_ec(ia).frequency;
                    LUKE_struct{ia}.omega_rf = frequency*2*pi;%wave angular frequency (rad/s)
                    %
                    LUKE_struct{ia}.yR_L = CPO_struct.antenna_ec(ia).position.r;
                    LUKE_struct{ia}.yZ_L = CPO_struct.antenna_ec(ia).position.z;
                    LUKE_struct{ia}.yphi_L = CPO_struct.antenna_ec(ia).position.phi;	
                    %
                    % Launch angles definitions for ITM are identical to those for Prater benchmark (see ITER simulation example in LUKE)
                    %
                    alpha = CPO_struct.antenna_ec(ia).launchangles.alpha;
                    beta = CPO_struct.antenna_ec(ia).launchangles.beta;
                    %
                    LUKE_struct{ia}.yalpha_L = sign(beta)*pi - atan(tan(beta)/cos(alpha));
                    LUKE_struct{ia}.ybeta_L = pi - acos(cos(beta)*sin(alpha));            
                    %
                    LUKE_struct{ia}.yP_L = CPO_struct.antenna_ec(ia).power.value;
                    LUKE_struct{ia}.dNpar0 = NaN;
                    LUKE_struct{ia}.ns = 1000;
                    LUKE_struct{ia}.method1 = 'pchip';%1D interpolation
                    LUKE_struct{ia}.method2 = 'cubic';%2D interpolation
                    %
                    frequency = CPO_struct.antenna_ec(ia).frequency;
                    alpha = frequency*pi/clum;%for the Rayleigh length
                    %
                    size = CPO_struct.antenna_ec(ia).beam.spot.size;
                    invcurvrad = CPO_struct.antenna_ec(ia).beam.phaseellipse.invcurvrad;
                    %
                    yw = alpha^2*size(1)^4*invcurvrad(1);%WARNING: circular shape only.
                    %
                    LUKE_struct{ia}.w0 = size(1)/sqrt(1 + yw*invcurvrad(1));
                    LUKE_struct{ia}.z_L = -yw/(1 + yw*invcurvrad(1));                        
                    %
                    LUKE_struct{ia}.mmode = -CPO_struct.antenna_ec(ia).mode;%LUKE definitions -> O/X mode: -1/+1. ITM ones are opposite
                else
                    
                end
            end
        else
            disp('There is no EC antenna in the MDS+ database.')
        end
        %      
         if isfield(CPO_struct,'antenna_lh'),
            for ia = 1:length(CPO_struct.antenna_lh),
                if ~isempty(CPO_struct.antenna_lh(ia).name),
                    %
                else
                    
                end
            end
        else
            disp('There is no LH antenna in the MDS+ database.')
         end
        %         
        if isfield(CPO_struct,'antenna_ic'),
            for ia = 1:length(CPO_struct.antenna_ic),
                if ~isempty(CPO_struct.antenna_ic(ia).name),
                    %
                else
                    
                end
            end
        else
            disp('There is no IC antenna in the MDS+ database.')
        end    
	else
        error(['The version ',ver_mds,' of data in EUITM MDS+ database is not recognized in CPO2LUKEstruct_yp.m'])
    end
else
	error(['There is no CPO with the name ',struct_name,' in the ITM MDS+ database']);
end
