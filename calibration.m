% |----------------------------------------------------------------------------
% |'calibration' is a function. It takes a N x 1 input vector ('data.x') a 
% |N x 1 target vector ('data.y'), a N x 1 target-uncertainty vector ('u'), the
% |polynomial degree ('M'), the number of bootstrap samples ('B'), a structure 
% |of optional input ('calOpt'), and a boolean variable for plotting purposes 
% |('calPlot'). It returns a structure containing various estimates of model 
% |prediction uncertainty ('MPU'), a structure containing the results obtained
% |from various calibration methods ('models'), and (if the number of output 
% |arguments equals 3) the complete bootstrapping output ('full'). If 
% |calPlot = true, two plots will be generated. The left plot represents the 
% |model perspective, whereas the right plot represents the residual 
% |perspective (with respect to the bootstrapped mean). If target uncertainties
% |are provided, error bars will be plotted in addition.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function [MPU models full] = calibration(x,y,u,M,B,calOpt,calPlot)

  %%% input inspection and initialization %%%

  if size(x,2) > 1
    error("first argument must be not be a row vector or a matrix");
  end

  if ~exist('B') 
    B = 1000;
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
 
  if ~exist('calPlot')
    calPlot = 0;
  elseif length(calPlot) ~= 1
    error("seventh argument must be a scalar");
  end

  N                 = length(x);
  blrMode           = 2;
  calOpt.bootDetail = 1;

  %%% actual code starts here %%%

  bayes         = bayesCal(x,y,u,M,blrMode,calOpt);
  loo           = LOOCV(x,y,u,M,calOpt);
  if nargout < 3
    boot        = bootCal(x,y,u,M,B,calOpt);
  else
    [boot full] = bootCal(x,y,u,M,B,calOpt);
  end

  RMSE = LSR(x,y,u,M,@OLS,calOpt).RMSE;

  MPU.RMSE = roundResult(RMSE,calOpt);
  MPU.R632 = roundResult(boot.R632,calOpt);
  MPU.RMPV = roundResult(bayes.RMPV,calOpt);
  MPU.RLOO = roundResult(loo.RLOO,calOpt);

  models.boot  = boot;
  models.bayes = bayes;
  models.loo   = loo;

  %%% plotting session %%%

  if calPlot

    x = (x - bayes.mx) / bayes.sx;
    X = add(x,M);
    f = X * boot.mean;
    r = y - f;

    xlb = min(x) - (max(x) - min(x)) * 0.05;
    xub = max(x) + (max(x) - min(x)) * 0.05;
    if isempty(u)
      ylb = min(y) - (max(y) - min(y)) * 0.05;
      yub = max(y) + (max(y) - min(y)) * 0.05;
      rlb = min(r) - (max(r) - min(r)) * 0.05; 
      rub = max(r) + (max(r) - min(r)) * 0.05;
    else
      ylb = min(y-2*u) - (max(y+2*u) - min(y-2*u)) * 0.05;
      yub = max(y+2*u) + (max(y+2*u) - min(y-2*u)) * 0.05;
      rlb = min(r-2*u) - (max(r+2*u) - min(r-2*u)) * 0.05;
      rub = max(r+2*u) + (max(r+2*u) - min(r-2*u)) * 0.05;
    end
    z = linspace(xlb,xub,250)';
    Z = add(z,M);

    close(figure(1));

    figure(1);
    subplot(1,2,1); hold
      plot([z;flipud(z)],[Z * bayes.mean + 2 * sqrt(bayes.noise + ...
           diag(Z * bayes.cov * Z'));flipud(Z * bayes.mean - ...
           2 * sqrt(bayes.noise + diag(Z * bayes.cov * Z')))],'--r'); 
      plot([z;flipud(z)],[Z * boot.mean + 2 * sqrt(boot.noise + ...
           diag(Z * boot.cov * Z'));flipud(Z * boot.mean - ...
           2 * sqrt(boot.noise + diag(Z * boot.cov * Z')))],'-r');
      plot(z,Z * bayes.mean,'--k');
      plot(z,Z * boot.mean,'-k');
      if ~isempty(u)
        h = errorbar(x,y,2 * u,'.r');
        set(h,'markersize',4);
      end
      plot(x,y,'.k','markersize',4);
      axis([xlb xub ylb yub],'square');
      title("model +/- 95% prediction band");
      xlabel("x, input variable");
      ylabel("y, target observable");
      legend("Bayes","bootstrap");
      legend('boxoff');
      legend('location','southoutside');
    subplot(1,2,2); hold
      plot([z;flipud(z)],[Z * (bayes.mean - boot.mean) + 2 * ... 
           sqrt(bayes.noise + diag(Z * bayes.cov * Z'));...
           flipud(Z * (bayes.mean - boot.mean) - 2 * sqrt(bayes.noise + ...
           diag(Z * bayes.cov * Z')))],'--r');
      plot([z;flipud(z)],[2 * sqrt(boot.noise + diag(Z * boot.cov * Z'));...
           flipud(-2 * sqrt(boot.noise + diag(Z * boot.cov * Z')))],'-r');
      plot(z,Z * (bayes.mean - boot.mean),'--k');
      plot(z,Z * zeros(M+1,1),'-k');
      if ~isempty(u)
        h = errorbar(x,y - X * boot.mean,2 * u,'.r');
        set(h,'markersize',4);
      end
      plot(x,y - X * boot.mean,'.k','markersize',4);
      axis([xlb xub rlb rub],'square');
      title("residuals +/- 95% prediction band");
      xlabel("x, input variable");
      ylabel("y, target observable");
      legend("Bayes","bootstrap");
      legend('boxoff');
      legend('location','southoutside');
  
  end

end
