function [ bdt ] = train_bdt(X,T,N,lRate,varargin)
%TRAIN_BDT trains a boosted decision tree
%
% BDT = TRAIN_BDT(X,T,N,lRate,Name,Value) trains a boosted decision tree
% (fitensemble) on the input data X and the target classes T. 
% N is the number of boosts (trees) that are used in the training. lRate 
% is the learning rate (AdaBoost default is 1). The
% Name,Value pairs can be used to set some properties of the trees that
% should be used for the training
%
% See also fitensemble, templateTree

% by Thomas Madlener, 2015

%% input checks necessary?

%% define a treeTemplate that is used for boosting and also the boosting algorithm
tempTree = templateTree(varargin{:}); % pass along varargin to tempTree
% boostAlg = 'AdaBoostM1'; % default is AdaBoostM1
boostAlg = 'LSBoost';

%%%%%% CLASSIFICATION COST TEST
% a = 1; % a==1 is default -> both misclassifictios equivalent. a > 0
% cost = struct;
% cost.ClassNames = [-1,1];
% cost.ClassificationCosts = [0,0.5;1,0]; % this way missclassified signals should be penalised

%%%%%%


bdt = fitensemble(X,T,boostAlg,N,tempTree,...
    'nprint',25, 'LearnRate', lRate) %,...
%     'Prior', 'Uniform',...
%     'Cost', [0,2;1,0]);
%     'Cost', [0,2;1,0]);
end