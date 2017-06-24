% |----------------------------------------------------------------------------
% |If inputOpt.randomData = false, a reference data set will be generated based
% |on the information provided in the data.txt file. If 
% |inputOpt.expUncertainty = true, data triples will be generated; data pairs 
% |otherwise. If additionally inputOpt.allowOnlyEU = true, only target values 
% |with known uncertainty will be considered; otherwise, the uncertainty of 
% |target values with unknown uncertainty will be estimated by the root-mean-
% |square value of all known uncertainties. If inputOpt.critical = true, data 
% |pairs/triples will be removed according to the IDs provided in the 
% |critical.txt file (Attention! The IDs must refer to the descending order of
% |target values). If inputOpt.multipleInputs = true, multiple input sets will
% |be generated; only one otherwise (as defined by the integer 'inputID').
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

D = load('data.txt');
N = size(D,1);

[y y_sort] = sort(D(:,end - ~~inputOpt.expUncertainty),'descend');
 D         = D(y_sort,:);

if inputOpt.critical
  D = remove(D,load('critical.txt'));
  y = D(:,end - ~~inputOpt.expUncertainty);
  N = size(D,1);
end

if inputOpt.expUncertainty
  if inputOpt.allowOnlyEU
    D = D(D(:,end) ~= 0,:);
    N = size(D,1);
    y = D(:,end - 1);
    u = D(:,end);
  else
    mu = roundResult(sqrt(mean((D(D(:,end) ~= 0,end)).^2)),calOpt.resolution);
    D(D(:,end) == 0,end) += mu;
    u = D(:,end);
    clear('mu');
  end
end

if inputOpt.multipleInputs
  dimInput = size(D,2) - (1 + ~~inputOpt.expUncertainty);
  x        = D(:,1:dimInput);
else
  if (inputID > size(D,2) - (1 + ~~inputOpt.expUncertainty))
    error("'inputID' larger than number of input sets");
  end
  dimInput = 1;
  x        = D(:,inputID);
end

clear('D','y_sort');
