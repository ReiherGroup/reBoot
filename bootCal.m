% |----------------------------------------------------------------------------
% |'bootCal' is a function. It takes a N x 1 input vector ('data.x'), a N x 1
% |target vector ('data.y'), a N x 1 target-uncertainty vector ('u'), the
% |polynomial degree ('M'), the number of bootstrap samples ('B'), and a
% |structure of optional input ('calOpt'). It returns a (M + 1) x 1 parameter 
% |vector ('model.mean'), a (M + 1) x (M + 1) parameter covariance matrix
% |('model.cov'), a measure of data noise ('model.noise'), two prediction-
% |uncertainty estimate ('model.REMSE' and 'model.R632', the latter only if
% |calOpt.bootDetail = true), scaling factors ('model.mx' and 'model.sx')
% |employed to tranform 'x' according to x = (x - model.mx) / model.sx, the
% |mean target uncertainty ('model.mu', only if target uncertainties are 
% |provided), and the wall time ('model.t') needed for the bootstrap loop.
% |Furthermore, if the number of output arguments is 2 and 
% |calOpt.bootDetail = false, all sampled parameter vector will be returned.
% |If additionally calOpt.bootDetail = true, the function will return the set
% |of absent data pairs/triples per bootstrap sample ('full.out', where a 1
% |stands for absent and a 0 for present data pairs/triples), N (M + 1) x 1
% |jackknifed parameter vectors ('full.jack.mean'), N (M + 1) x (M + 1)
% |jackknifed covariance matrices ('full.jack.cov'), and N root-mean-square
% |deviations of the jackknifed samples versus the original sample
% |('full.jack.df').
% |----------------------------------------------------------------------------

function [model full] = bootCal(x,y,u,M,B,calOpt)

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

  if ~exist('B') || isempty(B)
    B = 1000;
  elseif length(B) ~= 1
    error("fifth argument must be a scalar");
  elseif (B < 100) || mod(B,1)
    error("fifth argument must be an integer that is 100 or larger");
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  if ~isfield(calOpt,'xScale')
    calOpt.xScale = 1;
  elseif length(calOpt.xScale) ~= 1
    error("field 'xScale' of sixth argument must be a scalar");
  elseif (calOpt.xScale ~= 0) && (calOpt.xScale ~= 1) && (calOpt.xScale ~= 2)
    error("field 'xScale' of sixth argument can only take values 0, 1, 2");
  end

  if ~isfield(calOpt,'bootDetail')
    calOpt.bootDetail = 1;
  elseif length(calOpt.bootDetail) ~= 1
    error("'calOpt.bootDetail' must be a scalar");
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

  if calOpt.bootDetail
    count = zeros(N,1);
    loo   = zeros(N,1);
    if nargout == 2
      jack = zeros(M+1,B,N);
    end
  end

  warning('off','Octave:broadcast');

  %%% actual code starts here %%%

  t_init = time();

  for b = 1:B

    R           = randi([1 N],N,1);
    full.w(:,b) = X(R,:) \ y(R);

    if calOpt.bootDetail
      out            = ~(sum(repmat(R,1,N) == repmat((1:N),N,1)))';
      count         += out;
      loo(out)      += (y(out) - X(out,:) * full.w(:,b)).^2;
      if nargout == 2
        jack(:,b,out) = ones(M+1,1,sum(out)) .* full.w(:,b);
        full.out(:,b) = out;
      end
    end

    printf(">> %d / %d bootstrap samples\r",b,B);
    fflush(stdout);

  end

  t_final = time();

  disp("");

  MSE          = mean((y - X * (X \ y)).^2);
  model.mean   = mean(full.w,2);
  model.cov    = cov(full.w');
  model.noise  = N / (N - M - 1) * MSE; 
  model.REMSE  = sqrt(mean((repmat(y,1,B) - X * full.w)(:).^2));
  if calOpt.bootDetail
    loo      ./= count;
    model.R632 = sqrt(.368 * MSE + .632 * mean(loo));
  end
  model.mx     = mx;
  model.sx     = sx;
  if ~isempty(u)
    model.mu   = sqrt(mean(u.^2));
  end
  model.t      = t_final - t_init;

  if (nargout == 2) && calOpt.bootDetail
    for n = 1:N
      nJack = jack(:,(prod(jack(:,:,n)) ~= 0),n); 
      full.jack.mean(:,1,n) = mean(nJack,2);
      full.jack.cov(:,:,n)  = cov(nJack');
      full.jack.df(:,1,n)   = sum((X * (model.mean - mean(nJack,2))).^2);
    end
    full.jack.df /= min(full.jack.df);
  end

end
