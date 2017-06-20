% |----------------------------------------------------------------------------
% |'roundResult' is a function. It takes an arbitrary matrix ('z') and an
% |integer ('calOpt.resolution'). It returns a matrix of the same dimension as 
% |z with all values in z rounded to 10^(-calOpt.resolution).
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function f = roundResult(z,calOpt)

  %%% input inspection %%%

  if length(calOpt.resolution) > 1
    error("second argument must be empty or a scalar");
  elseif ~isempty(calOpt.resolution) && mod(calOpt.resolution,1)
    error("second argument (here, non-empty) must be an integer");
  end

  %%% actual code starts here %%%

  if isempty(calOpt.resolution)
    f = z;
  else
    f = round(z * 10^calOpt.resolution) * 10^(-calOpt.resolution);
  end
  
end
