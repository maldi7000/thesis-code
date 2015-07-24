function [R,SNR] = analyze_class_bins(t,y,feat,nbins,cutval,name)
%ANALYZE_CLASS_BINS analyzes the classifier performance in bins of a
%feature
%
% TODO:
% t: target values of the classifier
% y: actual outputs of the classifier
% cutval: value that is used to divide the classifier outputs into
% (calculated from inputs if needed)
% signal/background (negative to
% feat: feature that is used to bin the results
% nbins: number of bins used for binning (default 10)
% name: name of the feature (string)
%
% R - efficiency in the bins
% SNR - snr in the bins of the feature

% by Thomas Madlener, 2015

%% input checks
if nargin < 3, error('not enough input arguments'), end
if length(t) ~= length(y), error('targets and output must be of the same length'), end
if length(t) ~= length(feat), error('feature has to have the same length as targets/outputs'), end
if ~isvector(t) || ~isvector(y) || ~isvector(feat),
    error('targets, outputs and features have to be passed as vectors')
end
if nargin < 4, nbins = 10; end
if ~isscalar(nbins), error('number of bins has to be a scalar'), end

if nargin < 5, calc_cut = true; else calc_cut = false; end
if nargin >= 5 && ~isscalar(cutval)
    warning('cutval was no scalar value. recalculating cut value')
    calc_cut = true;
end
if nargin < 6 || ~ischar(name), name = 'feature'; end

%% main
if calc_cut, cutval = calculate_cut(t,y,0.99); end % this should also work if there are only signal samples since only the efficiency is desired

[~,e,binds] = histcounts(feat,nbins); % calculate the edges and the indices for binning the feature
bincenters = e(1:end-1) + diff(e) / 2; % calculate the bin centers from the bin edges
[bint,biny] = get_bin_values(t,y,binds,nbins);
[bin_r, bin_s_gain] = calculate_bin_performance(bint,biny,cutval);

make_bin_plot(bincenters,bin_r,bin_s_gain,name);
make_occ_hist(bincenters,bint,name);
end

%% plotting functions
% plot the efficiency in every bin
function f = make_bin_plot(binc, eff, s_gain, xlab)
    plot_snr = any(s_gain ~= 0); % determine if there is any s_gain different from 0
    f = figure;
    if plot_snr
        [h,l1,l2] = plotyy(binc,eff,binc,s_gain);
        ylabel(h(1), 'efficiency')
        ylabel(h(2), 'SNR_{gain}')
        l1.LineStyle = 'none'; l2.LineStyle = 'none'; % remove lines
        l1.Marker = '+'; l2.Marker = 'x';
    else
        plot(binc,eff, 'LineStyle', 'none', 'Marker', '+')
        ylabel('efficiency')
    end
    grid, grid minor
    line(xlim,[0.99,0.99],'Color','k')
    xlabel(xlab);
    title('classifier performance')
end

% make an occupancy histogram
function f = make_occ_hist(binc, t, xlab)
    occ = cellfun(@length, t);
    sig = cellfun(@(x) sum(x==1), t);
    f = figure;
    bar(binc,occ,1);
    if sig ~= occ
        hold on
        bar(binc,sig,1,'FaceColor', 'r')
        hold off
        legend('all samples', 'signal samples', 'Location', 'Best')
    end
    ylabel('# samples / bin')
    xlabel(xlab)
    title('occupancy')
end

%% helper functions
% calculate the performance in the passed bins (cell-arrays)
function [R,S_gain] = calculate_bin_performance(bin_t, bin_y, cutval)
    R = zeros(size(bin_y));
    S_gain = zeros(size(bin_y));
    for i=1:length(bin_y)
        onlybg = all(unique(bin_t{i}) == 1); % check if there are bg values in the bin sample
        tt = sum(bin_y{i}(bin_t{i} == 1) >= cutval); % true positives
        R(i) = tt/sum(bin_t{i} == 1);
        
        if ~onlybg % if there are no background samples leave S_gain at 0
            ft = sum(bin_y{i}(bin_t{i} ~= 1) >= cutval); % false positives
            S_out = tt/ft;
            S_in = calc_snr(bin_t{i},1);
            S_gain(i) = S_out / S_in;
        end
    end
end

% get the target and output values for each feature bin (passing along the
% number of bins to also cover empty bins)
function [bin_t, bin_y] = get_bin_values(t,y,inds,ninds)
    bin_t = cell(ninds,1);
    bin_y = cell(ninds,1);
    for i=1:ninds
        bin_t{i} = t(inds == i);
        bin_y{i} = y(inds == i);
    end
end