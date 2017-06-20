% |----------------------------------------------------------------------------
% |'OLS' is a function. It takes a N x (M + 1) design matrix ('data.X') and
% |a N x 1 target vector ('data.y'). It returns a (M + 1) x 1 parameter vector
% |('model.mean') by applying the method of linear ordinary least-squares (OLS)
% |regression.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function model = OLS(data)

  model.mean = data.X \ data.y;

end
