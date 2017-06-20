% |----------------------------------------------------------------------------
% |'LSR' is a function. It takes a N x 1 input vector ('x'), a N x 1 target
% |vector ('y'), a N x 1 target-uncertainty vector ('u'), the polynomial degree
% |('M'), the 'lsrType' of linear least-squares regression (@OLS, @WLS, @IRLS,
% |or @regLS), and a structure of optional input ('calOpt'). It returns a
% |(M + 1) x 1 parameter vector ('model.mean') depending on 'lsrType', the 
% |model discrepancy ('model.d') in case of lsrType = @IRLS, a prediction-
% |uncertainty estimate ('model.RMSE'), scaling factors ('model.mx' and 
% |'model.sx') employed to tranform 'x' according to x = (x - model.mx) / 
% |model.sx, and (if target uncertainties are provided) the mean target 
% |uncertainty ('model.mu').
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function model = LSR(x,y,u,M,lsrType,calOpt)

  %%% input inspection and processing %%%

  if size(x,2) > 1
    error("first argument must be not be a row vector or a matrix");
  end

  if ~prod(size(x) == size(y))
    error("first and second argument must be of same size");
  end

  if isempty(u) && (lsrType == @WLS || lsrType == @IRLS)
    error("third argument must not be empty in case of lsrType @WLS or @IRLS");
  elseif ~isempty(u)
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

  if ~exist('lsrType') || isempty(lsrType)
    lsrType = @OLS;
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  if lsrType == @IRLS
    if ~isfield(calOpt,'irlsConv')
      calOpt.irlsConv = 1e-3;
    elseif length(calOpt.irlsConv) ~= 1
      error("field 'irlsConv' of sixth argument must be a scalar");
    end
    if ~isfield(calOpt,'irlsMaxIter')
      calOpt.irlsMaxIter = 100;
    elseif length(calOpt.irlsMaxIter) ~= 1
      error("field 'irlsMaxIter' of sixth argument must be a scalar");
    elseif (calOpt.irlsMaxIter < 1) || mod(calOpt.irlsMaxIter,1)
      error("field 'irlsMaxIter' of sixth argument must be a positive integer");
    end
  end

  if lsrType == @regLS
    if ~isfield(calOpt,'reglsPenalty')
      calOpt.reglsPenalty = 1e-3;
    elseif length(calOpt.reglsPenalty) ~= 1
      error("field 'reglsPenalty' of sixth argument must be a scalar");
    elseif calOpt.reglsPenalty <= 0
      error("field 'reglsPenalty' of sixth argument must be \n\
       a positive real number");
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

  data = struct('X',X,'y',y,'u',u);

  %%% actual code starts here %%%

  model      = feval(lsrType,data,calOpt);
  model.RMSE = sqrt(mean((y - X * model.mean).^2));
  model.mx   = mx;
  model.sx   = sx;
  if ~isempty(u)
    model.mu = sqrt(mean(u.^2));
  end

end
