%LUKE - Test function for LUKE GPU computing
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
close all
clc
clear all
%
p_opt = 2;
%
flag_GPU = 0;
%
disp(['Test of the GPU calculations. Search GPU devices...']);
disp('----------------------------------------------------------------------');
%
try
    for igpu = 1:length(gpuDevice),
        tic,reset(gpuDevice(igpu));%reset memory on each GPU unit (should be done to have the largest memory available)
        gpuStatus(igpu) = gpuDevice(igpu);%call each GPU unit to get the graphics card status, and the CUDA compatibility
        etime_init(igpu) = toc;
        %
        disp(['The initial phase (memory reset + CUDA compatibility) of the GPU card #',int2str(igpu),' last ',num2str(etime_init),' (s).']);
        disp('----------------------------------------------------------------------');
    end
    flag_GPU = 1;
catch
    error(['No supported GPU device was found on this computer']);
end
%
test_mode = input('GPU test mode (1): repetitive scan (same matrix), (2): progressive scan (matrix size is growing to the max. allowed by the GPU memory) ? ','s');
matrix_type = input('Matrix type (1): all coefficients are set to 1, (2): random coefficients ? ','s');
fun_mode = input('Operation type (1): full matrix product, (2): dot-product between coefficients  ? ','s');
inputs_mode = input('Inputs type (1): basic, (2): basic + table of cells, (3): basic + table of cells and structures ? ','s');
outputs_mode = input('Outputs type (0): none, (1): ones tensor, (2): two tensors, (3): one structure with two fields, (4): all data ? ','s');
%
for igpu = 1:length(gpuDevice),%loop over the number of available GPU units
    if flag_GPU && gpuStatus(igpu).DeviceSupported,
        disp('----------------------------------------------------------------------');
        disp(['Calculations on the GPU unit #',int2str(igpu),' ''',gpuStatus.Name,''' are supported']);
        GPUmem = [num2str(round(gpuStatus.FreeMemory/1e6)),' MBytes'];
        disp(['Max. GPU free memory available : ',GPUmem]);
        disp('----------------------------------------------------------------------');
        %
        a = 2;%for parametric dependence of funGPU
        b = 3;%for parametric dependence of funGPU
        %
        if strcmp(fun_mode,'1'),
            a = a + i;
        end
        %
        if strcmp(inputs_mode,'1'),
            nmax_single = round(sqrt(gpuStatus.FreeMemory/8)/3);%the factor three comes from the number input variables in funGPU.m
            nmax_double = round(sqrt(gpuStatus.FreeMemory/16)/3);%the factor three comes from the number input variables in funGPU.m
        elseif strcmp(inputs_mode,'2'),
            nmax_single = round(sqrt(gpuStatus.FreeMemory/8)/3);%the factor three comes from the number input variables in funGPU.m
            nmax_double = round(sqrt(gpuStatus.FreeMemory/16)/3);%the factor three comes from the number input variables in funGPU.           
        elseif strcmp(inputs_mode,'3'),
            nmax_single = round(sqrt(gpuStatus.FreeMemory/8)/3);%the factor three comes from the number input variables in funGPU.m
            nmax_double = round(sqrt(gpuStatus.FreeMemory/16)/3);%the factor three comes from the number input variables in funGPU.m            
        else
            inputs_mode = '1';
            nmax_single = round(sqrt(gpuStatus.FreeMemory/8)/3);%the factor three comes from the number input variables in funGPU.m
            nmax_double = round(sqrt(gpuStatus.FreeMemory/16)/3);%the factor three comes from the number input variables in funGPU.m            
        end
        %
        % Single precision calculations
        %
        nm_single = [100:100:nmax_single];
        as = single(a);
        bs = single(b);
        cs{1} = single(pi);cs{2} = single(3*i);cs{3} = single(2);
        ds(1).a = single(4);ds(2).a = single(3);ds(1).b = single(1+i);
        %
        if strcmp(test_mode,'1'),
            nm_single = ones(size(nm_single))*round(nmax_single/2);
        end
        %
        etime = zeros(1,length(nm_single));
        etime_single_GPU = zeros(1,length(nm_single));
        %etime_single_arrayfun_GPU = zeros(1,length(nm_single));
        sizeX_single = zeros(1,length(nm_single));
        %
        if strcmp(matrix_type,'1'),
            X = ones(round(nmax_single),'single');
        else
            X = rand(round(nmax_single),'single');    
        end
        %
        for im = 1:length(nm_single),
            %
            if strcmp(test_mode,'2'),
                if strcmp(matrix_type,'1'),
                    X = ones(nm_single(im),'single');  
                else
                    X = rand(nm_single(im),'single');    
                end    
            end
            %
            sizeX = whos('X');
            sizeX_single(im) = sizeX.bytes/1e6;%Mbytes
            %
            if strcmp(inputs_mode,'1'),
                tic,[Ys0,Zs0,Ts0] = funGPU(X,as,bs);etime_single(im) = toc;
            elseif strcmp(inputs_mode,'2'),
                tic,[Ys0,Zs0,Ts0] = funGPU(X,as,bs,cs);etime_single(im) = toc;
            elseif strcmp(inputs_mode,'3'),
                tic,[Ys0,Zs0,Ts0] = funGPU(X,as,bs,cs,ds);etime_single(im) = toc;
            end
            %           
            %if strcmp(inputs_mode,'1'),
            %   tic,[Y_GPU,Z_GPU,T_GPU] = arrayfun(@funGPU,gpuArray(X),gpuArray.ones(size(X))*a,gpuArray.ones(size(X))*b);%
            %end
            %
            %if outputs_mode == 1,
            %    Ys1 = gather(Y_GPU);
            %elseif outputs_mode == 2,
            %    Ys1 = gather(Y_GPU);
            %    Zs1 = gather(Z_GPU);
            %elseif outputs_mode == 3,
            %    Ts1 = gather(T_GPU);
            %elseif outputs_mode == 4,
            %    Ys1 = gather(Y_GPU);
            %    Zs1 = gather(Z_GPU);
            %    Ts1 = gather(T_GPU);
            %end
            %
            %etime_single_arrayfun_GPU(im) = toc;
            %
            if strcmp(inputs_mode,'1'),
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),as,bs);
            elseif strcmp(inputs_mode,'2'), 
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),as,bs,cs);
            elseif strcmp(inputs_mode,'3'), 
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),as,bs,cs,ds);
            end
            %
            if strcmp(outputs_mode,'1'),
                Ys1 = gather(Y_GPU);
            elseif strcmp(outputs_mode,'2'),
                Ys1 = gather(Y_GPU);
                Zs1 = gather(Z_GPU);
            elseif strcmp(outputs_mode,'3'),
                Ts1 = gather(T_GPU);
            elseif strcmp(outputs_mode,'4'),
                Ys1 = gather(Y_GPU);
                Zs1 = gather(Z_GPU);
                Ts1 = gather(T_GPU);
            end
            %
            etime_single_GPU(im) = toc;
            %
            disp(['Single precision calculations, iteration #',int2str(im),'/',int2str(length(nm_single)),', tfun = ',num2str(etime_single(im)),', tfunGPU = ',num2str(etime_single_GPU(im))])
            %
        end
        %
        gain_single_GPU = etime_single./etime_single_GPU;
        %gain_single_arrayfun_GPU = etime_single./etime_single_arrayfun_GPU;
        %
        % Double precision calculations
        %
        nm_double = [100:100:nmax_double];
        ad = double(a);
        bd = double(b);
        cd{1} = pi;cd{2} = 3.0*i;cd{3} = 2.0;
        dd(1).a = 4.0;dd(2).a = 3.0;dd(1).b = 1.0+i;
        %
        if strcmp(test_mode,'1'),
            nm_double = ones(size(nm_double))*round(nmax_double/2);
        end
        %
        etime = zeros(1,length(nm_double));
        etime_double_GPU = zeros(1,length(nm_double));
        %etime_double_arrayfun_GPU = zeros(1,length(nm_double));
        sizeX_double = zeros(1,length(nm_double));
        %
        if strcmp(matrix_type,'1'),
            X = ones(round(nmax_double),'double');
        else
            X = rand(round(nmax_double),'double');    
        end
        %
        for im = 1:length(nm_double),
            %
            if strcmp(test_mode,'2'),
                if strcmp(matrix_type,'1'),
                    X = ones(nm_double(im),'double');  
                else
                    X = rand(nm_double(im),'double');    
                end 
            end
            %
            sizeX = whos('X');
            sizeX_double(im) = sizeX.bytes/1e6;%Mbytes
            %
            if strcmp(inputs_mode,'1'),
                tic,[Yd0,Zd0,Td0] = funGPU(X,ad,bd);etime_double(im) = toc;
            elseif strcmp(inputs_mode,'2'),
                tic,[Yd0,Zd0,Td0] = funGPU(X,ad,bd,cd);etime_double(im) = toc;
            elseif strcmp(inputs_mode,'3'),
                tic,[Yd0,Zd0,Td0] = funGPU(X,ad,bd,cd,dd);etime_double(im) = toc;
            end
            %           
            %if strcmp(inputs_mode,'1'),
            %     tic,[Y_GPU,Z_GPU,T_GPU] = arrayfun(@funGPU,gpuArray(X),gpuArray.ones(size(X))*a,gpuArray.ones(size(X))*b);%
            %end
            %
            %if outputs_mode == 1,
            %    Y = gather(Y_GPU);
            %elseif outputs_mode == 2,
            %    Y = gather(Y_GPU);
            %    Z = gather(Z_GPU);
            %elseif outputs_mode == 3,
            %    T = gather(T_GPU);
            %elseif outputs_mode == 4,
            %    Y = gather(Y_GPU);
            %    Z = gather(Z_GPU);
            %    T = gather(T_GPU);
            %end
            %
            %etime_double_arrayfun_GPU(im) = toc;
            %
            if strcmp(inputs_mode,'1'),
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),ad,bd);
            elseif strcmp(inputs_mode,'2'), 
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),ad,bd,cd);
            elseif strcmp(inputs_mode,'3'), 
                tic,[Y_GPU,Z_GPU,T_GPU] = funGPU(gpuArray(X),ad,bd,cd,dd);
            end
            %
            if strcmp(outputs_mode,'1'),
                Yd1 = gather(Y_GPU);
            elseif strcmp(outputs_mode,'2'),
                Yd1 = gather(Y_GPU);
                Zd1 = gather(Z_GPU);
            elseif strcmp(outputs_mode,'3'),
                Td1 = gather(T_GPU);
            elseif strcmp(outputs_mode,'4'),
                Yd1 = gather(Y_GPU);
                Zd1 = gather(Z_GPU);
                Td1 = gather(T_GPU);
            end
            %
            etime_double_GPU(im) = toc;
            %
            disp(['Double precision calculations, iteration #',int2str(im),'/',int2str(length(nm_double)),', tfun = ',num2str(etime_double(im)),', tfunGPU = ',num2str(etime_double_GPU(im))])
            %
        end
        %
        gain_double_GPU = etime_double./etime_double_GPU;
        %gain_double_arrayfun_GPU = etime_double./etime_double_arrayfun_GPU;
        %
        if strcmp(test_mode,'2'),
            figure('Name','Random matrix size'),
            graph1D_jd(nm_single,gain_single_GPU,0,0,'Random matrix size: (n*n)','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            %graph1D_jd(nm_single,gain_single_arrayfun_GPU,0,0,'Random matrix size: (n*n)','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(nm_double,gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %graph1D_jd(nm_double,gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            legend(['Single';'Double']);
            %
            print_jd(p_opt,'fig_GPU_MatrixSize','./figures',1)
            %
            figure('Name','Random matrix memory size')
            graph1D_jd(sizeX_single,gain_single_GPU,0,0,'Random matrix (MBytes)','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            %graph1D_jd(sizeX_single,gain_single_arrayfun_GPU,0,0,'Random matrix (MBytes)','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(sizeX_double,gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %graph1D_jd(sizeX_double,gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            legend(['Single';'Double']);
            %
            print_jd(p_opt,'fig_GPU_MatrixMemorySize','./figures',1)
        else
            figure('Name','Uniform matrix size'),
            graph1D_jd([1:length(gain_single_GPU)],gain_single_GPU,0,0,'Number of trials','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            %graph1D_jd([1:length(gain_single_arrayfun_GPU)],gain_single_arrayfun_GPU,0,0,'Number of trials','GPU speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd([1:length(gain_double_GPU)],gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %graph1D_jd([1:length(gain_double_arrayfun_GPU)],gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            %legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            legend(['Single';'Double']);
            %
            print_jd(p_opt,'fig_GPU_MatrixSize','./figures',1)
        end
        %
        filename = ['GPU_test_',test_mode,'_matrix_',matrix_type,'_fun_',fun_mode,'_inputs_',inputs_mode,'_outputs_',outputs_mode,'.mat'];
        save(filename,'etime_init','nm_single','etime_single','etime_single_GPU','nm_double','etime_double','etime_double_GPU');
        disp(['Results saved in ',filename]);
        %
    else
        disp('----------------------------------------------------------------------');
        error(['The GPU calculations on the ',gpuStatus.Name,' graphic card is not supported']);
    end
end


