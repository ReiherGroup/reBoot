% |----------------------------------------------------------------------------
% |'add' is a function. It takes a N x 1 vector of the input variable ('x')
% |and the polynomial degree ('M'). It returns a N x (M + 1) design matrix 
% |where the m-th column refers to x.^(m - 1).
% |----------------------------------------------------------------------------

function X = add(x,M)
  
  %%% input inspection and processing %%%

  if size(x,2) > 1
    error("first argument must not be a row vector or a matrix");
  end

  if length(M) ~= 1
    error("second argument must be a scalar");
  elseif (M < 1) || mod(M,1)
    error("second argument must be a positive integer");
  end

  N = size(x,1);
  X = ones(N,1);

  %%% actual code starts here %%%

  for m = 1:M
    X = [X, x.^m];
  end

end
