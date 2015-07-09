function [ out ] = nn_class_hist(t,y,keyentries)
%NN_CLASS_HIST plots histograms of how a network classifies a certain input
%
% nn_class_hist(T,Y,KEYENTRIES) takes as inputs a 1xN row vector of targets T and a MxN
% matrix of network/classifier outputs Y, where N is the number of samples and M is
% the number of networks (from which the outputs are taken). It produces
% for each output a histogram of the output for the whole output and
% superimposed (not stacked!) a histogram of the output of the signal
% samples (as indicated by T).
%
% nn_class_hist(T,Y,KEYENTRIES) takes as inputs two 1xK or (Kx1) cell
% arrays T and Y, where the i-th entry in the cell-arrays is of the same
% form as the input for this function when vectors and matrices are used
% (see above). This allows to put networks/classifiers with different targets and
% outputs on the same drawing pad.
%
% The argument KEYENTRIES is optional and can be used to pass the along
% names for each network for better distinguishability. It has to be a
% cell-array of strings (with as many entries as there are networks).
%
% NOTE: to produce a suitable matrix (or cell-array) Y the analyze_nets function can be
% used.

% by Thomas Madlener, 2015

%% input handling and checking
if ~iscell(t), t = {t}; end % transform to cell-array
if ~iscell(y), y = {y}; end % transform to cell-array
if nargin == 3
   if ~iscellstr(keyentries), error('passed KEYENTRIES does contain non-string entries'), end
   if ~isvector(keyentries), error('KEYENTRIES has to be passed as vector-like cell-array'), end
else
    keyentries = {}; % populate later if nothing is passed
end
if ~isvector(t), error('T is not a 1xK or Kx1 cell-array'), end
if ~isvector(y), error('Y is not a 1xK or Kx1 cell-array'), end
if length(t) ~= length(y), error('the sizes of T and Y do not match'), end
for i=1:length(t)
    if ~isrow(t{i}), error('the target values have to be passed as a row vector'), end % check if targets are row
    if ~ismatrix(y{i}), error('the outputs have to be passed as a matrix'), end % check if outputs are matrix
    if length(t{i}) ~= length(y{i}) % check if both have the same length
        error('targets and outputs must have the same lenghts')
    end
end

%% function body
mins = cellfun(@(x) min(x,[],2), y, 'UniformOutput', false); % get min and max values for every network output
maxs = cellfun(@(x) max(x,[],2), y, 'UniformOutput', false);
nnets = sum(cellfun(@(x) size(x,1), mins)); % get the number of histograms to plot
[nR, nC] = calc_layout(nnets);
keyentries = check_and_handle(keyentries, nnets);

pad = figure; % return this?
iplot = 0; % keep track of the plots over different cell-arrays
for i=1:length(mins)
    for j=1:length(mins{i})
        iplot = iplot + 1;
        subplot(nR,nC,iplot);
        A = linspace(mins{i}(j), maxs{i}(j), 100);
        hall = histogram(y{i}(j,:),A);
        hold on
        htrue = histogram(y{i}(j,t{i}==1),A);
        hold off
        title(keyentries{iplot});
        xlabel('classifier output');
        ylabel('entries');
        legend('all samples', 'signal samples', 'Location', 'Best');
    end
end
end

%% helper functions
% calculate the 'optimal layout'
function [nR,nC] = calc_layout(nPlots)
    nR = ceil(sqrt(nPlots));
    nC = ceil(sqrt(nPlots) - 0.5);
end

% process the keyentries input such that no problems arise in its later use
function entries = check_and_handle(keyentries, nnets)
    if ~iscolumn(keyentries), keyentries = keyentries'; end % transform to column 'vector'
    nentries = length(keyentries);
    entries = keyentries;
    if nentries < nnets
        for i=nentries+1:nnets, entries{i} = sprintf('unlabeled %d', i-nentries); end
    end
    if nentries > nnets % remove extra entries
        warning('got %d names for legend entries, but only %d nets.', nentries, nnets)
        entries(nnets+1:end) = [];
    end
end
