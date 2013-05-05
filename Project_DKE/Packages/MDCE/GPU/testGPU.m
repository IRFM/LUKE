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
try
    for igpu = 1:length(gpuDevice),
        tic,reset(gpuDevice(igpu));%reset memory on each GPU unit (should be done to have the largest memory available)
        gpuStatus(igpu) = gpuDevice(igpu);%call each GPU unit to get the graphics card status, and the CUDA compatibility
        etime_init(igpu) = toc;
        %
        disp(['The initial phase (memory reset + CUDA compatibility) of the GPU card #',int2str(igpu),' last ',num2str(etime_init),' (s).']);
        disp('------------------------------------------------------------');
    end
    flag_GPU = 1;
catch
    error(['No supported GPU device was found on this computer']);
end
%
gpu_mode = input('GPU test mode (1): uniform matrix size, (2): non-uniform matrix size ? ','s');
%
for igpu = 1:length(gpuDevice),%loop over the number of available GPU units
    if flag_GPU && gpuStatus(igpu).DeviceSupported,
        disp('------------------------------------------------------------');
        disp(['Calculations on the GPU unit #',int2str(igpu),' ''',gpuStatus.Name,''' are supported']);
        GPUmem = [num2str(round(gpuStatus.FreeMemory/1e6)),' MBytes'];
        disp(['Max. GPU free memory available : ',GPUmem]);
        disp('------------------------------------------------------------');
        %
        a = single(2);%for parametric dependence of funGPU
        b = single(3);%for parametric dependence of funGPU
        %
        nmax_single = round(sqrt(gpuStatus.FreeMemory/8)/3);%the factor three comes from the number input variables in funGPU.m
        nmax_double = round(sqrt(gpuStatus.FreeMemory/16)/3);%the factor three comes from the number input variables in funGPU.m
        %
        % Single precision calculations
        %
        nm_single = [100:100:nmax_single];
        %
        if gpu_mode == 1,
            nm_single = ones(size(nm_single))*round(nmax_single/2);
        end
        %
        etime = zeros(1,length(nm_single));
        etime_single_GPU = zeros(1,length(nm_single));
        etime_single_arrayfun_GPU = zeros(1,length(nm_single));
        sizeX_single = zeros(1,length(nm_single));
        %
        X = rand(round(nmax_single),'single');
        %
        for im = 1:length(nm_single),
            %
            if gpu_mode == 2,
                X = ones(nm_single(im),'single');   
            end
            %
            sizeX = whos('X');
            sizeX_single(im) = sizeX.bytes/1e6;%Mbytes
            %
            Y = zeros(size(X));
            Z = zeros(size(X));
            %
            tic,[Y,Z] = funGPU(X,a,b);etime(im) = toc;
            %
            Y_GPU = gpuArray.zeros(size(X));
            Z_GPU = gpuArray.zeros(size(X));
            %
            tic,
            [Y_GPU,Z_GPU] = arrayfun(@funGPU,gpuArray(X),gpuArray.ones(size(X))*a,gpuArray.ones(size(X))*b);%
            Y = gather(Y_GPU);
            Z = gather(Z_GPU);
            etime_single_arrayfun_GPU(im) = toc;
            %
        end
        %
        reset(gpuDevice(igpu));
        %
        for im = 1:length(nm_single),
            %
            if gpu_mode == 2,
                X = ones(nm_single(im),'single');   
            end
            %
            sizeX = whos('X');
            sizeX_single(im) = sizeX.bytes/1e6;%Mbytes
            %
            Y = zeros(size(X));
            Z = zeros(size(X));
            %
            tic,[Y,Z] = funGPU(X,a,b);etime(im) = toc;
            %
            Y_GPU = gpuArray.zeros(size(X));
            Z_GPU = gpuArray.zeros(size(X));
            %
            tic,
            [Y_GPU,Z_GPU] = funGPU(gpuArray(X),a,b);
            Y = gather(Y_GPU);
            Z = gather(Z_GPU);
            etime_single_GPU(im) = toc;    
            %
        end
        %
        gain_single_GPU = etime./etime_single_GPU;
        gain_single_arrayfun_GPU = etime./etime_single_arrayfun_GPU;
        %
        % Double precision calculations
        %
        reset(gpuDevice(igpu));
        %
        nm_double = [100:100:nmax_double];
        %
        if gpu_mode == 1,
            nm_double = ones(size(nm_double))*round(nmax_double/2);
        end
        %
        etime = zeros(1,length(nm_double));
        etime_double_GPU = zeros(1,length(nm_double));
        etime_double_arrayfun_GPU = zeros(1,length(nm_double));
        sizeX_double = zeros(1,length(nm_double));
        %
        X = rand(round(nmax_double),'double');
        %
        for im = 1:length(nm_double),
            %
            if gpu_mode == 2,
                X = rand(nm_double(im),'double');
            end
            %
            sizeX = whos('X');
            sizeX_double(im) = sizeX.bytes/1e6;%Mbytes
            %
            Y = zeros(size(X));
            Z = zeros(size(X));
            %
            tic,[Y,Z] = funGPU(X,a,b);etime(im) = toc;
            %
            Y_GPU = gpuArray.zeros(size(X));
            Z_GPU = gpuArray.zeros(size(X));
            %
            tic,
            [Y_GPU,Z_GPU] = arrayfun(@funGPU,gpuArray(X),gpuArray.ones(size(X))*a,gpuArray.ones(size(X))*b);%
            Y = gather(Y_GPU);
            Z = gather(Z_GPU);
            etime_double_arrayfun_GPU(im) = toc; 
            %
        end
        %
        reset(gpuDevice(igpu));
        %
        for im = 1:length(nm_double),
            %
            if gpu_mode == 2,
                X = rand(nm_double(im),'double');
            end
            %
            sizeX = whos('X');
            sizeX_double(im) = sizeX.bytes/1e6;%Mbytes
            %
            Y = zeros(size(X));
            Z = zeros(size(X));
            %
            tic,[Y,Z] = funGPU(X,a,b);etime(im) = toc;
            %
            Y_GPU = gpuArray.zeros(size(X));
            Z_GPU = gpuArray.zeros(size(X));
            %
            tic,
            [Y_GPU,Z_GPU] = funGPU(gpuArray(X),gpuArray(a),gpuArray(b));
            Y = gather(Y_GPU);
            Z = gather(Z_GPU);
            etime_double_GPU(im) = toc;  
            %
        end
        %
        gain_double_GPU = etime./etime_double_GPU;
        gain_double_arrayfun_GPU = etime./etime_double_arrayfun_GPU;
        %
        if gpu_mode == 2,
            figure('Name','Random matrix size'),
            graph1D_jd(nm_single,gain_single_GPU,0,0,'Random matrix size: (n*n)','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(nm_single,gain_single_arrayfun_GPU,0,0,'Random matrix size: (n*n)','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(nm_double,gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            graph1D_jd(nm_double,gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            %
            print_jd(p_opt,'fig_GPU_MatrixSize','./figures',1)
            %
            figure('Name','Random matrix memory size')
            graph1D_jd(sizeX_single,gain_single_GPU,0,0,'Random matrix (MBytes)','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(sizeX_single,gain_single_arrayfun_GPU,0,0,'Random matrix (MBytes)','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd(sizeX_double,gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            graph1D_jd(sizeX_double,gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            %
            print_jd(p_opt,'fig_GPU_MatrixMemorySize','./figures',1)
        else
            figure('Name','Uniform matrix size'),
            graph1D_jd([1:length(gain_single_GPU)],gain_single_GPU,0,0,'Number of trials','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd([1:length(gain_single_arrayfun_GPU)],gain_single_arrayfun_GPU,0,0,'Random matrix size: (n*n)','GPU Speed gain',[gpuStatus.Name,', ',GPUmem],'Single',NaN,NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
            graph1D_jd([1:length(gain_double_GPU)],gain_double_GPU,0,0,'','','','Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
            graph1D_jd([1:length(gain_double_arrayfun_GPU)],gain_double_arrayfun_GPU,0,0,'','','','Double',NaN,NaN,'--','none','b',2,20,gca,0.9,0.7,0.7);hold on
            legend(['Single              ';'Single with Arrayfun';'Double              ';'Double with Arrayfun']);
            %
            print_jd(p_opt,'fig_GPU_MatrixSize','./figures',1)

        end
    else
        disp('------------------------------------------------------------');
        error(['The GPU calculations on the ',gpuStatus.Name,' graphic card is not supported']);
    end
end


