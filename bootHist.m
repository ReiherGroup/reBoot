% |----------------------------------------------------------------------------
% |'bootHist' is a function. It takes a (M + 1) x B parameter matrix ('w')
% |obtained from the 'bootCal' function ('full.w') and the results of Bayesian
% |linear regression ('bayes') generated with the 'bayesCal' function. It
% |returns bootstrapped ('pdf.hist') and Gaussian ('pdf.bayes') probability
% |density functions and the corresponding abscissae ('pdf.abscissaHist' and
% |'pdf.abscissaBayes', respectively).
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function pdf = bootHist(w,bayes)

  %%% input inspection %%%

  if size(w,1) ~= length(bayes.mean)
    error("number of parameters different in first and second argument");
  elseif size(w,2) < 100
    error("number of samples in first argument must be 100 or larger");
  end

  %%% actual code starts here

  if (round(2 * size(w,2)^(1/3)) > 50)
    pdf.bins = 50;
  else
    pdf.bins = round(2 * size(w,2)^(1/3)); % Rice Rule
  end

  for i = 1:size(w,1)
    [pdf.hist(i,:) pdf.abscissaHist(i,:)] = hist(w(i,:),pdf.bins,1);
    [tmp pdf.abscissaBayes(i,:)] = hist(w(i,:),pdf.bins * 10,1);
    pdf.bayes(i,:) = ...
    normpdf(pdf.abscissaBayes(i,:),bayes.mean(i),sqrt(bayes.cov(i,i)));
    pdf.hist(i,:) /= diff(pdf.abscissaHist(i,:))(1);
  end
 
end
