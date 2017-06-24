% |----------------------------------------------------------------------------
% |'roundResult' is a function. It takes an arbitrary matrix ('z') and an
% |integer ('resolution'). It returns a matrix of the same dimension as z with
% |all values in z rounded to 10^(-resolution).
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function f = roundResult(z,calOpt)

  %%% input inspection %%%

  if length(resolution) > 1
    error("second argument must be empty or a scalar");
  elseif ~isempty(resolution) && mod(resolution,1)
    error("second argument (here, non-empty) must be an integer");
  end

  %%% actual code starts here %%%

  if isempty(resolution)
    f = z;
  else
    f = round(z * 10^resolution) * 10^(-resolution);
  end
  
end
