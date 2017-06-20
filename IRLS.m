% |----------------------------------------------------------------------------
% |'IRLS' is a function. It takes a N x (M + 1) design matrix ('data.X'), a
% |N x 1 target vector ('data.y'), a N x 1 target-uncertainty vector
% |('data.u'), a convergence criterion ('calOpt.irlsConv'), and the maximum
% |number of iterations to be performed ('calOpt.irlsMaxIter'). It returns a 
% |(M + 1) x 1 parameter vector ('model.mean') and the model discrepancy
% |('model.d') by applying the method of linear iteratively reweighted 
% |least-squares (IRLS) regression.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function model = IRLS(data,calOpt)

  %%% input processing %%%

  N  = size(data.X,1);
  M  = size(data.X,2) - 1;
  U  = diag(data.u.^2) / mean(data.u.^2);
  S  = inv(U);
  u2 = mean(data.u.^2);

  %%% actual code starts here %%%

  w  = (sqrt(S) * data.X) \ (sqrt(S) * data.y);
  d2 = N / (N - M - 1) * mean((data.y - data.X * w).^2) - u2;

  if d2 <= 0 
    d2 = 0; 
    break; 
  end

  count = 0;

  do
    d2Old = d2;
    S     = inv(U + d2 * eye(N));
    w     = (sqrt(S) * data.X) \ (sqrt(S) * data.y);
    d2    = N / (N - M - 1) * mean((data.y - data.X * w).^2) - u2;
    if d2 <= 0
      d2 = 0; 
      break; 
    end
    ++count;
  until (count == calOpt.irlsMaxIter) || ...
        ((max(d2,d2Old) / min(d2,d2Old) - 1) < calOpt.irlsConv)

  if count == calOpt.irlsMaxIter
    warning("IRLS algorithm reached maximum number of steps \n\
         => final discrepancy ('model.d') may be unreliable");
  end

  model.mean = w;
  model.d    = sqrt(d2);

end
