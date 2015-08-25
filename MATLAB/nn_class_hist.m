function [h_true, h_all, binc ] = nn_class_hist(t,y,b,keyentries)
%NN_CLASS_HIST plots histograms of how a network classifies a certain input
%
% [HT, HA, BE] = nn_class_hist(T,Y,B,KEYENTRIES) takes as inputs a 1xN row vector of targets T and a MxN
% matrix of network/classifier outputs Y, where N is the number of samples and M is
% the number of networks (from which the outputs are taken). It produces
% for each output a histogram of the output for the whole output and
% superimposed (not stacked!) a histogram of the output of the signal
% samples (as indicated by T).
%
% [HT, HA, BE] = nn_class_hist(T,Y,B,KEYENTRIES) takes as inputs two 1xK or (Kx1) cell
% arrays T and Y, where the i-th entry in the cell-arrays is of the same
% form as the input for this function when vectors and matrices are used
% (see above). This allows to put networks/classifiers with different targets and
% outputs on the same drawing pad.
%
% The return arguments are HT and HA, KxBINS matrices, that contain
% the count of signal (HT) and all (HA) that are int the bins with
% edges BE (again a Kx(BINS+1) matrix).
%
% The optional input argument B is either the number of bins
% (scalar input) or a vector (or matrix) of bin edges, that should be used for
% binning. If it is passed as matrix it has to be an Kx(BINS+1)
%
% The argument KEYENTRIES is optional and can be used to pass the along
% names for each network for better distinguishability. It has to be a
% cell-array of strings (with as many entries as there are networks).
%
% NOTE: to produce a suitable matrix (or cell-array) Y the analyze_nets function can be
% used.

% by Thomas Madlener, 2015

%% global definition of numbers of bins
nBins = 50;
e_set = false; % use user defined edges or determine them? (default false)

% input handling and checking
if ~iscell(t), t = {t}; end % transform to cell-array
if ~iscell(y), y = {y}; end % transform to cell-array
if nargin == 4
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

mins = cellfun(@(x) min(x,[],2), y, 'UniformOutput', false); % get min and max values for every network output
maxs = cellfun(@(x) max(x,[],2), y, 'UniformOutput', false);
nnets = sum(cellfun(@(x) size(x,1), mins)); % get the number of histograms to plot

if nargin > 2 % check if edges or number of bins is passed.
    if all(size(b) == [1,1]) && all(floor(b) == ceil(b)) % nBins passed
        nBins = abs(b);
    else
        if any(~isfinite(b))
            error(['B has no suitable format. must either be an ' ...
                   'integer value or a matrix containing only finite ' ...
                   'values'])
            if size(b,1) ~= nnets
                error(['B has to have as many rows as outputs are ' ...
                       'passed!'])
            end
        else
            e_set = true;
            nBins = size(b,2) - 1;
        end
    end
end

%% function body
[nR, nC] = calc_layout(nnets);
keyentries = check_and_handle(keyentries, nnets);


if nargout >= 1, % only reserve space if needed
    h_true = zeros(nnets, nBins);
    h_all = zeros(nnets, nBins);
    binc = zeros(nnets, nBins + 1);
end

pad = figure; % return this?
iplot = 0; % keep track of the plots over different cell-arrays
for i=1:length(mins)
    for j=1:length(mins{i})
        iplot = iplot + 1;
        subplot(nR,nC,iplot);
        if e_set, A = b(iplot,:);
        else, A = linspace(mins{i}(j), maxs{i}(j), nBins + 1); end
% $$$         hall = histogram(y{i}(j,:),A);
        hall = histcounts(y{i}(j,:),A);
        bc = A(1:end -1) + diff(A)/2;
        bar(bc, hall, 1.0, 'FaceColor', 'r');
        hold on
% $$$         htrue = histogram(y{i}(j,t{i}==1),A);
        htrue = histcounts(y{i}(j,t{i}==1),A);
        bar(bc, htrue, 1.0, 'FaceColor', 'b');
        hold off
        title(keyentries{iplot});
        xlabel('classifier output');
        ylabel('entries');
        legend('all samples', 'signal samples', 'Location', ...
               'Best');

        if nargout >= 1, % only fill if needed
            h_true(iplot,:) = htrue;
            h_all(iplot,:) = hall;
            binc(iplot,:) = A;
        end
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
