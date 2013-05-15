%
% This example is based on the info in:
% http://www.mathworks.co.uk/help/distcomp/executing-cuda-or-ptx-code-on-the-gpu.html
%

%
% use nvcc to compile kernel_test.cu to PTX code
%

disp(' '); err = system('/Developer/NVIDIA/CUDA-5.0/bin/nvcc -ptx kernel_test.cu');
if (err==1)
  fprintf('error compiling kernel_test.cu: code = %d \n',err)
else
  disp('compiled kernel_test.cu successfully')
end

%
% now test the execution
%

k1 = parallel.gpu.CUDAKernel('kernel_test.ptx', 'kernel_test.cu', 'add1');
feval(k1, 1, 1)

k2 = parallel.gpu.CUDAKernel('kernel_test.ptx', 'kernel_test.cu', 'add2');
feval(k2, 1, 1)

N  = 32;
k2.ThreadBlockSize = N;
feval(k2, ones(N, 1), ones(N, 1))