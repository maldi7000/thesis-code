function [out_args] = analyze_class_bins(t, y, feat, nbins)
%ANALYZE_CLASS_BINS analyzes the classifier output in bins of a feature
%
% analyze_class_bins(T,Y, FEAT, N) takes as inputs the targets T and the
% outputs Y of a classifier together with a vector of same length FEAT that
% contains the feature that shall be used to bin the data into N bins.

% by Thomas Madlener

%% inupt checks and 'global' definitions
if nargin < 4, nbins = 50; end
efficiency = .99; % desired efficiency

%% main
[~,e,binds] = histcounts(feat,nbins);
bincenters = e(1:end-1) + diff(e)/2; % transform edge values to center values (of bins)
[bint, biny] = get_bin_values(t,y,binds);

set(0,'DefaultFigureVisible','off') % suppress figure output of analyze_class_out. NOTE: only displaying disabled not the creation
[snr,eff] = analyze_class_out(bint,biny);
set(0,'DefaultFigureVisible','on')

S = get_snr_at_efficiency(snr,eff,efficiency);
S_in = get_input_snr(bint);

make_bin_plot(S_in, S, bincenters);
make_occupancy_plot(bint,bincenters);
end

%% plotting functions
function f = make_bin_plot(S_in,S,bins)
    f = figure; hold on;
    colors = colormap(lines(3));
    bar(bins, S, 'FaceColor', colors(1,:));
    bar(bins, S_in, 'FaceColor', colors(2,:));
    plot(bins, S./S_in, 'Color', colors(3,:), 'LineStyle', 'none',...
        'Marker', 'o', 'MarkerFaceColor', colors(3,:));
    hold off
    grid, grid minor
    legend('SNR @ r \geq 0.99', 'SNR input', 'SNR gain', 'Location', 'Best')
end

function f = make_occupancy_plot(t,bins)
    f = figure;
    occ = cellfun(@length, t);
    bar(bins,occ,1);
    grid, grid minor
    ylabel('# samples / bin')
    hold off
end

%% helper functions
function [bin_t, bin_y] = get_bin_values(t,y,inds)
    ninds = length(unique(inds));
    bin_t = cell(ninds,1);
    bin_y = cell(ninds,1);
    for i=1:ninds
        bin_t{i} = t(inds == i);
        bin_y{i} = y(inds == i);
    end
end

% get the SNR for a given efficiency
% CAUTION: for this to work properly R has to be monotonically increasing
% in each column!
function SNR = get_snr_at_efficiency(S,R,r)
    gtr = R >= r; % mark all values, that are larger than a given value
    gtr = diff(gtr); % find the jump
    gtr = [gtr; zeros(1,size(gtr,2))]; % add a line of zeros (bring matrix back to same size as R and S)
    SNR = S((gtr ~= 0)); % get the according SNR values from S (for each column there is only one non-zero entry in gtr now)
end

% get the input SNR from the targets
function SNR = get_input_snr(t)
    SNR = zeros(length(t),1);
    for i=1:length(t)
        SNR(i) = calc_snr(t{i},1);
    end
end