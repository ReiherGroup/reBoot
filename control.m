% |----------------------------------------------------------------------------
% |The control.m script defines all essential variables (default values) if not
% |already done by the user via the setting.m script, and checks whether
% |definitions made by the user (setting.m) are erroneous.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

if ~exist('inputOpt');
  inputOpt = struct();
end

if ~isfield(inputOpt,'multipleInputs') 
  inputOpt.multipleInputs = 0;
end

if ~isfield(inputOpt,'expUncertainty')
  inputOpt.expUncertainty = 0;
end

if inputOpt.expUncertainty && ~isfield(inputOpt,'allowOnlyEU')
  inputOpt.allowOnlyEU = 0;
end

if ~isfield(inputOpt,'critical')
  inputOpt.critical = 0;
end

if inputOpt.critical && ~exist('critical.txt')
  error("file 'critical.txt' does not exist");
end

if ~isfield(inputOpt,'randomData')
  inputOpt.randomData = 0;
end

if inputOpt.randomData && ~exist('N')
  N = 100;
elseif inputOpt.randomData && (length(N) ~= 1)
  error("number of data points ('N') must be a scalar");
elseif inputOpt.randomData && ((N < 0) || mod(N,1))
  error("number of data points ('N') must be a non-negative integer");
end

if ~inputOpt.randomData && ~exist('data.txt')
  error("file 'data.txt' does not exist");
end

if ~exist('M')
  M = 1;
end

if ~exist('inputID')
  inputID = 1;
elseif length(inputID) ~= 1
  error("'inputID' must be a scalar");
elseif (inputID < 0) || mod(inputID,1)
  error("'inputID' must be a non-negative integer");
end

if ~exist('B')
  B = 1000;
end

if ~exist('blrMode')
  blrMode = 2;
end

if ~exist('lsrType')
  lsrType = @OLS;
end

if ~exist('calOpt');
  calOpt = struct();
end

if ~isfield(calOpt,'xScale')
  calOpt.xScale = 1;
end

if ~isfield(calOpt,'resolution')
  calOpt.resolution = [];
end

if ~isfield(calOpt,'increase')
  calOpt.increase = 0;
end

if ~isfield(calOpt,'bootDetail')
  calOpt.bootDetail = 1;
end

if ~isfield(calOpt,'bayesConv')
  calOpt.bayesConv = 1e-3;
end

if ~isfield(calOpt,'bayesMaxIter')
  calOpt.bayesMaxIter = 100;
end

if ~isfield(calOpt,'irlsConv')
  calOpt.irlsConv = 1e-3;
end

if ~isfield(calOpt,'irlsMaxIter')
  calOpt.irlsMaxIter = 100;
end

if ~isfield(calOpt,'reglsPenalty')
  calOpt.reglsPenalty = 1e-3;
end

if ~exist('calPlot')
  calPlot = 0;
end
