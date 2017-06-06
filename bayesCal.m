% |----------------------------------------------------------------------------
% |'bayesCal' is a function. It takes a N x 1 input vector ('data.x'), a N x 1
% |target vector ('data.y'), a N x 1 target-uncertainty vector ('u'), the
% |polynomial degree ('M'), the sophistication of the Bayesian-linear-
% |regression algorithm ('blrMode'), and a structure of optional input 
% |('calOpt'). It returns a (M + 1) x 1 parameter vector ('model.mean'), a 
% |(M + 1) x (M + 1) parameter covariance matrix ('model.cov'), a measure of
% |data noise ('model.noise'), a prediction-uncertainty estimate 
% |('model.RMPV'), scaling factors ('model.mx' and 'model.sx') employed to
% |tranform 'x' according to x = (x - model.mx) / model.sx, the mean target 
% |uncertainty ('model.mu', only if target uncertainties are provided), and
% |three Bayesian hyperparameters ('model.alpha', 'model.beta', 'model.gamma').
% |If blrMode = 0, then model.alpha = 0, which is equivalent to ordinary
% |least-squares regression plus prediction uncertainty. If blrMode = 1, then
% |model.alpha equals the initial guess of alpha in the evidence approximation.
% |If blrMode = 2, then model.alpha equals the converged value of alpha
% |obtained from the evidence approximation.
% |----------------------------------------------------------------------------

function model = bayesCal(x,y,u,M,blrMode,calOpt)

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

  if ~exist('blrMode') || isempty(blrMode)
    blrMode = 2;
  elseif length(blrMode) ~= 1
    error("'blrMode' must be a scalar");
  elseif (blrMode ~= 0) && (blrMode ~= 1) && (blrMode ~= 2)
    error("'blrMode' can only take values 0, 1, 2");
  end

  if ~exist('calOpt')
    calOpt = struct();
  end
 
  if blrMode == 2
    if ~isfield(calOpt,'bayesConv')
      calOpt.bayesConv = 100;
    elseif length(calOpt.bayesConv) ~= 1
      error("'calOpt.bayesConv' must be a scalar");
    end
    if ~isfield(calOpt,'bayesMaxIter')
      calOpt.bayesMaxIter = 100;
    elseif length(calOpt.bayesMaxIter) ~= 1
      error("'calOpt.bayesMaxIter' must be a scalar");
    elseif (calOpt.bayesMaxIter < 1) || mod(calOpt.bayesMaxIter,1)
      error("'calOpt.bayesMaxIter' must be a positive integer");
    end
  end
  
  if ~isfield(calOpt,'xScale')
    calOpt.xScale = 1;
  elseif length(calOpt.xScale) ~= 1
    error("field 'xScale' of sixth argument must be a scalar");
  elseif (calOpt.xScale ~= 0) && (calOpt.xScale ~= 1) && (calOpt.xScale ~= 2)
    error("field 'xScale' of sixth argument can only take values 0, 1, 2");
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

  w     = X \ y;
  I     = eye(M+1);
  gamma = M + 1;

  if blrMode
    L     = eig(X' * X);
    alpha = gamma / (w' * w);
  else
    alpha = 0;
  end

  beta  = (N - gamma) / sum((y - X * w).^2);
  S     = inv(alpha * I + beta * X' * X);
  w     = beta * S * X' * y;
  cost  = mean(diag(X * S * X') + 1 / beta);

  if blrMode == 2

    count = 0;

    do
      oldCost = cost;
      gamma   = sum((L * beta) ./ (alpha + L * beta));
      alpha   = gamma / (w' * w);
      beta    = (N - gamma) / sum((y - X * w).^2);
      S       = inv(alpha * I + beta * X' * X);
      w       = beta * S * X' * y;
      cost    = mean(diag(X * S * X') + 1 / beta);
      ++count;
    until (count == calOpt.bayesMaxIter) || ...
          ((max(oldCost,cost) / min(oldCost,cost) - 1) < calOpt.bayesConv)

    if count == calOpt.bayesMaxIter
      warning("evidence approximation reached maximum number of steps \n\
           => results may be unreliable");
    end

  end

  model.mean     = w;
  model.cov      = S;
  model.noise    = 1 / beta;
  model.RMPV     = sqrt(cost);
  model.mx       = mx;
  model.sx       = sx;
  if ~isempty(u)
    model.mu     = sqrt(mean(u.^2));
  end
  model.alpha    = alpha;
  model.beta     = beta;
  model.gamma    = gamma;

end
