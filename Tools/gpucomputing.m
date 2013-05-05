function [flag,varargout] = gpucomputing(fun,args_in,arg_index,arg_range,scheduler)
% LUKE - Parallel computing of the loop
%
%   GPU computing of the loop (see tesGPU.m to check the GPU device availability and details on the programming technique)
%
%   WARNING: GPU is a powerful method for distributed computing, but its efficiency 
%   depends strongly of the function in the loop. 
%   
%   It is highly recommended to work with real numbers of 
%   single precision (using double precision real numbers is possible but performances can
%   drop down dramatically, and this reduction factor is card-dependent).
%   In addition, the gain is reduced by the time needed to reset the memory of the GPU card (to
%   maximize the free memory) and get the CUDA compatibility. 
%
%   gain_GPU = t_CPU/(t_GPU_init + t_GPU_transfer_forward + t_GPU + t_GPU_transfer_back)
%
%   t_GPU_init = fixed (few seconds)
%   t_GPU_transfer_forward = data size and precision (fraction of seconds)
%   t_GPU = data size and precision (seconds)
%   t_GPU_transfer_backward = data size and precision (seconds)
%   
%   Let suppose the following loop must be parallelized:
%   
%   for i=1:N,
%       [b1,b2,...,bk,...,bK] = fun(a1(i),a2(i),...,am(i),...,aM(i),c1,c2,...,cj,...,cJ);%m inputs and k ouputs
%   end
%
%   with size(bk) = size(a1(i)) for all i. cj coefficients are just needed for calculations
%
%   Best improvements CPU -> GPU are obtained for k = 1 and (a1,a2,...,am)
%   are all of small size. The more k value is large, the less improvements
%   are, because of the time to transfer data from the GPU memory back to the CPU memory
%   through the PCI bus. 
%  
%   Two techniques may be used:
%      
%   1) the default one, less efficient but more easily applicable to arbitrary function:
%   
%   for m=1:M,
%       tgpu_am = gpuArray.zeros(size(am,1),size(am,2),...,size(am,j),N);
%
%       for i = 1:N
%           tgpu_am(1:size(am,1),1:size(am,2),...,1:size(am,j),i) = single(am); 
%           ...
%       end
%       ...
%   end
%
%   [tgpu_b1,tgpu_b2,....tgpu_bk] = fun(tgpu_a1,tgpu_a2,...,tgpu_am,gpuArray(c1),gpuArray(c2),...,gpuArray(cj),...,gpuArray(cJ));%m inputs and k ouputs
%       
%   for k=1:K,
%       tbk = gather(tgpu_bk);%GPU -> CPU memory transfer
%       for i = 1:N
%           bk = tbk(1:size(am,1),1:size(am,2),...,1:size(am,j),i); 
%           ...
%       end
%       ...
%   end
%
%   2) using the matlab function arrayfun(), more efficient but less versatile (cj must be with one dimension)
%
%   [tgpu_b1,tgpu_b2,....tgpu_bk] = fun(tgpu_a1,tgpu_a2,...,tgpu_am,gpuArray(c1),gpuArray(c2),...,gpuArray(cj),...,gpuArray(cJ));%m inputs and k ouputs
%   
%   must be replaces by 
%
%   [tgpu_b1,tgpu_b2,....tgpu_bk] = arrayfun(@fun,tgpu_a1,tgpu_a2,...,tgpu_am,gpuArray.ones(size(tgpu_am))*c1,gpuArray.ones(size(tgpu_am))*c2,...,gpuArray.ones(size(tgpu_am))*cj,...,gpuArray.ones(size(tgpu_am))*c)));%m inputs and k ouputs
%
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of iterations 
%       - scheduler: scheduler information
%
%   OUTPUT:
%
%       - flag: status of the computation : scheduler.mode (OK with parcomputing) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
nargout_in = nargout - 1;
nrange = length(arg_range);
varargout_array = cell(1,nrange);
flag = scheduler.mode*ones(1,nrange);
configuration = findResource('scheduler','configuration',scheduler.configuration);
scheduler.clustersize = min([scheduler.clustersize,configuration.ClusterSize]);
%
try
    reset(parallel.gpu.GPUDevice.current());%reset memory on GPU device (should be done to have the largest memory available)
    gpuStatus = gpuDevice;%data from the GPU device
    %
    if gpuStatus.DeviceSupported,
        disp(['The GPU calculations on the ',gpuStatus.Name,' graphic card are supported']);
        GPUmem = [num2str(round(gpuStatus.FreeMemory/1e6)),' MBytes'];
        disp(['Max. GPU free memory available :',GPUmem]);
    else
        disp(['The GPU calculations on the ',gpuStatus.Name,' graphic card are not supported']);
        flag(:) = -2;
        return
    end
catch err
    info_dke_yp(2,['WARNING: exiting gpucomputing for function ',func2str(fun),'.m (mode 3) because of error: ',err.message]);
    flag(:) = -2;
    return
end
%
%Y_GPU = gather(arrayfun(@funGPU,gpuArray(X)));

%
parfor j_range = 1:nrange,
    %
    args_loc = args_in;
    args_loc{arg_index} = arg_range{j_range};
    varargout_loc = cell(1,nargout_in);
    try
        [varargout_loc{:}] = feval(fun,args_loc{:});
    catch me_seq
        disp(['Error executing the iteration ',int2str(j_range),'/',int2str(nrange),'.']);
        disp(['===> Error : ',getReport(me_seq)]);
        flag(j_range) = -2;
    end
    varargout_array{j_range} = varargout_loc;
    %
end




%
varargout = cell(1,nargout_in);
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
parfor j_argout = 1:nargout_in,
    %
    varargout{j_argout} = cell(nrange,1);
    for j_range = 1:nrange,
        varargout{j_argout}{j_range} = varargout_array{j_range}{j_argout};
    end
    %
end
%
matlabpool close force
%
      