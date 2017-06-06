% |----------------------------------------------------------------------------
% |'LOOCV' is a function. It takes a N x 1 input vector ('data.x'), a N x 1
% |target vector ('data.y'), a N x 1 target-uncertainty vector ('u'), the
% |polynomial degree ('M'), and a structure of additional input ('calOpt'). 
% |It returns a (M + 1) x 1 parameter vector ('model.mean'), a 
% |(M + 1) x (M + 1) parameter covariance matrix ('model.cov'), the leave-one-
% |out cross-validation (LOOCV) estimator of prediction uncertainty 
% |('model.RLOO'), scaling factors ('model.mx' and 'model.sx') employed to
% |tranform 'x' according to x = (x - model.mx) / model.sx, and (if target
% |uncertainties are provided) the mean target uncertainty (model.mu).
% |----------------------------------------------------------------------------

function [model jack] = LOOCV(x,y,u,M,calOpt)

  %%% input inspection and processing %%%

  if size(x,2) > 1
    error("first argument must be not be a row vector or a matrix");
  end

  if ~prod(size(x) == size(y))
    error("first and second argument must be of same size");
  end

  if ~isempty(u)
    if ~prod(size(x) == size(u))
      if length(u) == 1
        u = repmat(u,length(x),1);
      else
        error("first and third argument must be of same size");
      end
    elseif ~prod(u > 0)
      error("all elements in third argument must be positive");
    end
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  if ~isfield(calOpt,'xScale')
    calOpt.xScale = 1;
  elseif length(calOpt.xScale) ~= 1
    error("field 'xScale' of fourth argument must be a scalar");
  elseif (calOpt.xScale ~= 0) && (calOpt.xScale ~= 1) && (calOpt.xScale ~= 2)
    error("field 'xScale' of fourth argument can only take values 0, 1, 2");
  end

  switch calOpt.xScale
    case 0
      mx = 0;
      sx = 1;
      X  = add(x,M);
    case 1
      mx = mean(x);
      sx = 1;
      X  = add(center(x),M);
    case 2
      mx = mean(x);
      sx = std(x);
      X  = add(zscore(x),M);
  end

  N = length(x);

  %%% actual code starts here %%%

  for n = 1:N
      
    jack(:,n) = remove(X,n) \ remove(y,n);
    r(n,1)    = (y(n) - X(n,:) * jack(:,n)).^2;

  end

  model.mean = mean(jack(:,n),2);
  model.cov  = cov(jack(:,n)');
  model.RLOO = sqrt(mean(r));
  model.mx   = mx;
  model.sx   = sx;
  if ~isempty(u)
    model.mu = sqrt(mean(u.^2));
  end

end
