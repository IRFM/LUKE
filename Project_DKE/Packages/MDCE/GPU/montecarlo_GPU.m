close all; clear all

N = 1e8;

gpu = gpuDevice

for pass = 1:2
  disp(' ')
  if (pass==1)
    disp('Single precision:')
    prec = 'single';
  else
    disp('Double precision:')
    prec = 'double';
  end
  disp(' ')
  disp('GPU')

  for M = [1e5 1e6 1e7]
    parallel.gpu.rng('default');
    tic
    e4 = 0;
    for m = 1:M:N
      n  = min(M,N-m+1);
      x  = gpuArray.randn(1,n, prec);
      e4 = e4 + sum(x.^4);
    end
    e4 = e4 / N;
    wait(gpu);    % ensure it has completed)
    fprintf(' ave = %f, elapsed time = %f \n',e4,toc)
  end

  disp(' ')
  disp('CPU')

  for M = [1e4 1e5 1e6 1e7]
    rng('default');
    tic
    e4 = 0;
    for m = 1:M:N
      n  = min(M,N-m+1);
      y  = randn(1,n, prec);
      e4 = e4 + sum(y.^4);
    end
    e4 = e4 / N;
    fprintf(' ave = %f, elapsed time = %f \n',e4,toc)
  end
end

disp(' ')
whos