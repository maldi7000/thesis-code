function [ output_args ] = analyze_class_angular(targets,inputs,outputs)
%ANALYZE_CLASS_ANGULAR analyzes the performance of a classifier depending
%on the angle
%
% analyze_class_angular(T,X,Y)
%
% T - targets
% X - non-decorrelated classifier inputs (needed for determining the
% angular bins) as NxM matrix: N samples, M variables per input
% Y - classifier outputs for input X (or decorrelated version thereof)
%
% TODO: documentation, implementation

% by Thomas Madlener, 2015

% TODO: INPUT CHECKS
%% input checks and definition of 'global' variables
if nargin < 3
    error('not enough input arguments')
end

nThetaBins = 28; % yields approx 5 deg per bin
nPhiBins = 72; % yields 5 deg per bin
efficiency = .99; % the desired efficiency

%% function main body
[~,theta,phi] = cart2sph_basf2(inputs(:,1:3));
[phi_bins, phi_bin_inds, theta_bins, theta_bin_inds] = get_angle_bins(phi,theta, nPhiBins, nThetaBins);

[phi_t, phi_y] = get_bin_values(phi_bin_inds,targets,outputs);
[theta_t, theta_y] = get_bin_values(theta_bin_inds,targets,outputs);

make_angular_occupancy_plot(phi_t,phi_bins, '\phi [\circ]');
make_angular_occupancy_plot(theta_t,theta_bins, '\theta [\circ]');

set(0,'DefaultFigureVisible','off') % suppress figure output of analyze_class_out. NOTE: only displaying disabled not the creation
[S_phi,R_phi,A_phi] = analyze_class_out(phi_t,phi_y);
[S_theta,R_theta,A_theta] = analyze_class_out(theta_t, theta_y);
set(0,'DefaultFigureVisible','on')

S_phi = get_snr_at_efficiency(S_phi,R_phi,efficiency);
S_theta = get_snr_at_efficiency(S_theta,R_theta,efficiency);

S_phi_in = get_input_snr(phi_t);
S_theta_in = get_input_snr(theta_t);

make_angular_plot(S_phi_in,S_phi,phi_bins, '\phi [\circ]');
make_angular_plot(S_theta_in, S_theta,theta_bins,'\theta [\circ]');
end

%% plotting function(s)
% plot SNR_in, SNR_out and SNR gain depending on the angle
function f = make_angular_plot(S_in,S_out,bins,angle)
    f = figure; hold on
    colors = colormap(lines(3));
    bar(bins,S_out,'FaceColor',colors(1,:));
    bar(bins,S_in,'FaceColor',colors(2,:));
    plot(bins,S_out./S_in, 'Color', colors(3,:), 'LineStyle', 'none',...
        'Marker', 'o', 'MarkerFaceColor', colors(3,:));
    hold off
    grid, grid minor
    legend('SNR @ r \geq 0.99', 'SNR input', 'SNR gain', 'Location', 'Best');
    xlabel(angle);
    xlim([round(min(bins),-1) - 5, round(max(bins),-1) + 5]); % round min/max to the next 10 degrees
end

% plot the occupancy of the bins
function f = make_angular_occupancy_plot(T,bins,angle)
    f = figure; hold on
    occ = cellfun(@length, T);
    bar(bins,occ,1);
    hold off
    grid, grid minor
    ylabel('# samples/bin')
    xlabel(angle);
    xlim([round(min(bins),-1) - 5, round(max(bins),-1) + 5]); % round min/max to the next 10 degrees
end

%% helper functions
% transform cartesian coordinates X (Nx3 matrix) to spherical coordinates
% as used in BASF2
function [r,theta,phi] = cart2sph_basf2(X)
    [phi,theta,r] = cart2sph(X(:,1), X(:,2), X(:,3)); % angles in rad
    phi = phi * 180 / pi; % phi [-180,180] -> positive x-axis is 0
    theta = 90 - theta * 180 / pi; % theta [0,180] <-> [front, back]
end

% get the values of the bin centers and the indices in the passed array
% corresponding to the bins
function [b1,b1i,b2,b2i] = get_angle_bins(a1,a2, nbin1, nbin2)
    centers = @(edges) edges(1:end-1) + diff(edges)/2; % transform the edge values to center values
    [~,e,b1i] = histcounts(a1,nbin1);
    b1 = centers(e);
    [~,e,b2i] = histcounts(a2,nbin2);
    b2 = centers(e);
end

% bin the targets and outputs according to the passed indices
function [bin_t,bin_y] = get_bin_values(inds,t,y)
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
% in each column AND if there is at least one entry that is greater than r!
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