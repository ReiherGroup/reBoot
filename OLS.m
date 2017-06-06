% |----------------------------------------------------------------------------
% |'OLS' is a function. It takes a N x (M + 1) design matrix ('data.X') and
% |a N x 1 target vector ('data.y'). It returns a (M + 1) x 1 parameter vector
% |('model.mean') by applying the method of linear ordinary least-squares (OLS)
% |regression.
% |----------------------------------------------------------------------------

function model = OLS(data)

  model.mean = data.X \ data.y;

end
