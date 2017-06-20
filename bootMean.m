% |----------------------------------------------------------------------------
% |'bootMean' is a function. It takes an arbitrary column vector ('z') of
% |dimension 2 or larger and the number of bootstrap samples ('B'). It returns
% |the deviation of the bootstrapped mean from that of the original sample
% |('stats.bias') and the variance of all bootstrap-sample means ('stats.var').
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function stats = bootMean(z,B)

  %%% input inspection and processing %%%

  if size(z,2) > 1
    error("first argument must not be a row vector or a matrix");
  elseif size(z,1) < 2
    error("first argument must be a column vector of dimension 2 or larger");
  end

  if ~exist('B') || isempty(B)
    B = 1000;
  elseif length(B) ~= 1
    error("second argument must be a scalar");
  elseif (B < 100) || mod(B,1)
    error("second argument must be an integer that is 100 or larger");
  end

  N = size(z,1);

  %%% actual code starts here %%%

  for b = 1:B

    R      = randi([1,N],N,1);
    Z(:,b) = z(R);

    printf(">> %d / %d bootstrap samples\r",b,B);
    fflush(stdout);

  end

  disp("");

  stats.bias = mean(Z(:)) - mean(z);
  stats.var  = var(mean(Z));

end
