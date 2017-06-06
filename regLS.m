% |----------------------------------------------------------------------------
% |'regLS' is a function. It takes a N x (M + 1) design matrix ('data.X'), a
% |N x 1 target vector ('data.y'), and a penalty factor 
% |('calOpt.reglsPenalty'). It returns a (M + 1) x 1 parameter vector 
% |('model.mean') by applying the method of linear regularized least-squares 
% |(regLS) linear regression.
% |----------------------------------------------------------------------------

function model = regLS(data,calOpt)

  M = size(data.X,2) - 1;

  model.mean = inv(data.X' * data.X + calOpt.reglsPenalty * eye(M + 1)) ...
             * data.X' * data.y;

end
