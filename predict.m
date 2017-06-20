% |----------------------------------------------------------------------------
% |'predict' is a function. It takes a scalar or a column vector of arbitrary
% |dimension ('x0') representing (a) new input value(s), the results of a
% |calibration method ('model') generated with one of the following functions: 
% |'LSR', 'bootCal', 'bayesCal' (note that the 'calibration' metafunction 
% |allows to generate several models at once), and a target resolution
% |('calOpt.resolution'). It returns the new input value(s) ('result.x), the 
% |predicted target value(s) ('result.y'), and (if the 'model' was obtained 
% |from either 'bootCal' or 'bayesCal') the predicted target-uncertainty 
% |value(s) ('result.u').
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function result = predict(x0,model,calOpt)

  %%% input inspection and processing %%%

  if size(x0,2) > 1
    error("first argument must not be a row vector or a matrix");
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  if ~isfield(calOpt,'resolution')
    calOpt.resolution = [];
  elseif length(calOpt.resolution) > 1
    error("'calOpt.resolution' must be empty or a scalar");
  elseif ~isempty(calOpt.resolution) && mod(calOpt.resolution,1)
    error("'calOpt.resolution' (here, non-empty) must be an integer");
  end

  M  = length(model.mean) - 1;
  X0 = add((x0 - model.mx) / model.sx,M);

  %%% actual code starts here %%%

  result.x = x0;
  result.y = roundResult(X0 * model.mean,calOpt);

  if isfield(model,'cov')
    result.u = roundResult(sqrt(model.noise + diag(X0 * model.cov * X0')),...
               calOpt);
  end

end
