% |----------------------------------------------------------------------------
% |The init.m script needs to be executed prior to any other application of 
% |reBoot. It clears previous sessions, provides information on the reBoot 
% |toolbox,and starts the input processing.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
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
disp("|Cite us : J. Proppe, M. Reiher, DOI: 10.1021/acs.jctc.7b00235");
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
