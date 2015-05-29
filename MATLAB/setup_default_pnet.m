function net = setup_default_pnet(nHidden, varargin)
%SETUP_DEFAULT_PNET creates a patternnet with default settings
%
% NET = setup_default_pnet(NHIDDEN) creates a patternnet NET with NHIDDEN
% hidden neurons with predefined settings (from here on referred to as
% default) that differ from the MATLAB default. 
%
% NOTE: net is neither configured nor initialized on return!
%
% Function is essentially a convenience wrapper for easier setup of a
% common default.

% by Thomas Madlener, 2015
if ~isempty(varargin)
    warning('at the moment only one argument is supported. Ignoring all others!')
end
% COULDDO: check nHidden for some properties (e.g. only 1-dim matrix, ...)

tmpnet = patternnet(nHidden);

tmpnet.divideMode = 'sample'; % at the moment no clear explanation of this can be found! should work however
tmpnet.divideFcn = 'dividerand'; % divide data randomly
% NOTE: consider switching to divideind and providing the indices for
% better reproducibility

tmpnet.divideParam.trainRatio = 80/100;
tmpnet.divideParam.valRatio = 20/100;
tmpnet.divideParam.testRatio = 0/100; %% testing with other sample

tmpnet.performFcn = 'mse';
tmpnet.trainParam.epochs = 10000;

net = tmpnet;