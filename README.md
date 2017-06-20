# reBoot
Statistical Calibration of Property Models

reBoot is a toolbox for statistical calibration of physicochemical property models.
A detailed description of the reBoot toolbox can be found in the "manual.pdf" file.
A detailed discussion on the statistical calibration of property models employed in a scientific context can be found in DOI:10.1021/acs.jctc.7b00235.

In the currently available version, we support polynomial models based on a single scalar input variable.
As the model is linear in its parameters, all calibration procedures implemented in reBoot are currently based on different types of linear (least-squares) regression: ordinary, weighted, iteratively reweighted, regularized.
For the determination of model prediction uncertainty (MPU), we currently provide nonparametric bootstrapping, k-fold cross-validation, and the evidence approximation to Bayesian inference (based on the normal-population assumption).
Note that the statistical methods implemented in reBoot are not limited to single-variable polynomial models that are linear with respect to their parameters. For instance, implementation of non-polynomial models, many-variable models, or models being nonlinear in their parameters is straightforward. 

reBoot is based on scripts written in the GNU Octave programming language.
Additional packages for GNU Octave are not required.
All that needs to be done is to clone the reBoot repository to a local directory (say, bootDir), and to set a path to that directory by typing addpath('absolute-path-to-bootDir') in the GNU Octave shell (a permanent alternative is to append the .octaverc file in the home directory by the absolute path to bootDir).

The "init.m" script needs to be executed first in a reBoot session.
It clears previous sessions, provides information on the reBoot toolbox, and starts the input processing.
