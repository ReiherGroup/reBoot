% |----------------------------------------------------------------------------
% |The init.m script needs to be run prior to any other application of reBoot.
% |It clears previous sessions, provides information on the reBoot toolbox,
% |and prepares the reference data set required for calibration.
% |----------------------------------------------------------------------------

close all;
clear all;
format long;
clc;

%%% Welcome to reBoot! %%%

disp("|Program : reBoot");
disp("|Version : 2017-06-06");
disp("|Authors : Jonny Proppe and Markus Reiher");
disp("|Address : ETH Zurich, Vladimir-Prelog-Weg 2, 8093 Zurich, Switzerland");
disp("|Contact : reboot@phys.chem.ethz.ch");
disp("|Website : www.reiher.ethz.ch/software/reboot.html");
disp("|Purpose : Statistical calibration of property models");
disp("|Cite us : J. Proppe, M. Reiher, arXiv:1703.01685 (2017)");
disp("|------------------------------------------------------------------------------");
disp("");

%%% input processing %%%

if exist('setting.m')
  setting;
end
control;
if inputOpt.randomData
  randomData;
else
  userData;
end
