% |----------------------------------------------------------------------------
% |'jackBayes' is a function. It takes a N x 1 input vector ('x'), a N x 1
% |target vector ('y'), a N x 1 target-uncertainty vector ('u'), the polynomial
% |degree ('M'), the sophistication of the Bayesian-linear-regression algorithm
% |('blrMode'), and a structure of optional input ('calOpt'). It returns 
% |jackknifed estimates of prediction uncertainty ('jRMPV') obtained from
% |Bayesian linear regression.
% |----------------------------------------------------------------------------

function jRMPV = jackBayes(x,y,u,M,blrMode,calOpt)

  %%% input inspection and processing %%%
 
  if size(x,1) < 2
    error("number of rows of first argument must be 2 or larger");
  end

  if ~exist('blrMode')
    blrMode = 2;
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  N = size(x,1);

  %%% actual code starts here %%%

  for n = 1:N
    jRMPV(n,1) = ...
    bayesCal(remove(x,n),remove(y,n),remove(u,n),M,blrMode,calOpt).RMPV;
  end

end
