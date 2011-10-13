%LUKE - Test function for LUKE GPU computing
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
close all
clc
clear all
%
reset(parallel.gpu.GPUDevice.current());%reset memory on GPU device (should be done to have the largest memory available)
GPUstatus = gpuDevice;%data from the GPU device
%
if GPUstatus.DeviceSupported,
	disp(['The GPU calculations on the ',GPUstatus.Name,' graphic card is supported']);
	disp(['Max. GPU free memory available :',num2str(round(GPUstatus.FreeMemory/1e6)),' MBytes']);
	disp('---------------------------------');
	%
	nmax_single = round(sqrt(GPUstatus.FreeMemory/8));
	nmax_double = round(sqrt(GPUstatus.FreeMemory/16));
	%
	dummy = gather(arrayfun(@funGPU,gpuArray(rand(10))));clear dummy;%Initialisation of Matlab in GPU
	%
	% Single precision
	%
	nm_single = [100:100:nmax_single];
	%
	etime = zeros(1,length(nm_single));
	etime_GPU = zeros(1,length(nm_single));
    sizeX_single = zeros(1,length(nm_single));
	%
	for im = 1:length(nm_single),
	    %
	    X = rand(nm_single(im),'single');
	    sizeX = whos('X');
	    sizeX_single(im) = sizeX.bytes/1e6;%Mbytes
	    %
	    tic,Y = funGPU(X);etime(im) = toc;
	    %
		tic,Y_GPU = gather(arrayfun(@funGPU,gpuArray(X)));etime_GPU(im) = toc;
	end
	%
	gain_GPU_single = etime./etime_GPU;
	%
	% Double precision
	%
	nm_double = [100:100:nmax_double];
	%
	etime = zeros(1,length(nm_double));
	etime_GPU = zeros(1,length(nm_double));
	sizeX_double = zeros(1,length(nm_double));
	%
	for im = 1:length(nm_double),
	    %
	    X = rand(nm_double(im),'double');
	    sizeX = whos('X');
	    sizeX_double(im) = sizeX.bytes/1e6;%Mbytes
	    %
	    tic,Y = funGPU(X);etime(im) = toc;
	    %
		tic,Y_GPU = gather(arrayfun(@funGPU,gpuArray(X)));etime_GPU(im) = toc;
	end
	%
	gain_GPU_double = etime./etime_GPU;
	%
	figure(1),
	graph1D_jd(nm_double,gain_GPU_double,0,0,'n -> random matrix size (n*n)','Gain',GPUstatus.Name,'Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
	graph1D_jd(nm_single,gain_GPU_single,0,0,'n -> random matrix size (n*n)','Gain',GPUstatus.Name,'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
	legend(['Double','Single']);
	%
	figure(2),
	graph1D_jd(sizeX_double,gain_GPU_double,0,0,'Matrix size (MBytes)','Gain',GPUstatus.Name,'Double',NaN,NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);hold on
	graph1D_jd(sizeX_single,gain_GPU_single,0,0,'Matrix size (MBytes)','Gain',GPUstatus.Name,'Single',NaN,NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
	legend(['Double','Single']);
else
	error(['The GPU calculations on the ',GPUstatus.Name,' graphic card is not supported']);
end


