% |----------------------------------------------------------------------------
% |'WLS' is a function. It takes a N x (M + 1) design matrix ('data.X'), a
% |N x 1 target vector ('data.y'), and a N x 1 target-uncertainty vector 
% |('data.u'). It returns a (M + 1) x 1 parameter vector ('model.mean') by 
% |applying the method of linear weighted least-squares (WLS) regression.
% |----------------------------------------------------------------------------

function model = WLS(data)

  S = inv(diag(data.u.^2) / mean(data.u.^2));

  model.mean = (sqrt(S) * data.X) \ (sqrt(S) * data.y);

end
