function [R, SNR, BINC] = analyze_class_angular(targets,inputs,outputs,cutvalue)
%ANALYZE_CLASS_ANGULAR analyzes the performance of a classifier depending
%on the angle
%
% analyze_class_angular(T,X,Y,C)
%
% T - targets
% X - non-decorrelated classifier inputs (needed for determining the
% angular bins) as NxM matrix: N samples, M variables per input
% Y - classifier outputs for input X (or decorrelated version thereof)
% C - cutvalue to be used
%
% R - cell-array where first entry is efficiency for phi, second for theta
% SNR - cell-array where first entry is SNR_gain for phi, second for theta
% BINC - cell-array where first entry is phi bin centers, second for theta
% TODO: documentation, implementation

% by Thomas Madlener, 2015

% TODO: INPUT CHECKS
%% input checks and definition of 'global' variables
if nargin < 3
    error('not enough input arguments')
end

nThetaBins = 28; % yields approx 5 deg per bin
nPhiBins = 72; % yields 5 deg per bin

if nargin < 4 % calculate cutvalue if necessary
    cutvalue = calculate_cut(targets,outputs,0.99);
end
%% function main body
[theta,phi] = cart2sph_basf2(inputs(:,1:3));
% analyze_class_bins_dep(targets,outputs,phi,nPhiBins, '\phi [\circ]'); % old version of function for other plots
% analyze_class_bins_dep(targets,outputs,theta,nThetaBins, '\theta [\circ]'); % old version of function for other plots
if nargout > 1
    R = cell(2,1); SNR = cell(2,1); BINC = cell(2,1);
    [R{1},SNR{1},BINC{1}] = analyze_class_bins(targets,outputs,phi, ...
                                               nPhiBins, cutvalue,'\phi [\circ]');
    [R{2},SNR{2},BINC{2}] = analyze_class_bins(targets,outputs,theta, ...
                                               nThetaBins, cutvalue, '\theta [\circ]');
else
    analyze_class_bins(targets,outputs,phi,nPhiBins,cutvalue,['\phi ' ...
                        '[\circ]']);
    analyze_class_bins(targets,outputs,theta,nThetaBins,cutvalue,'\theta [\circ]');
end

end
%% helper functions
% transform cartesian coordinates X (Nx3 matrix) to spherical coordinates
% as used in BASF2 (defined by ROOT there) -> returns degrees
function [theta,phi] = cart2sph_basf2(X)
% $$$     [phi,theta,r] = cart2sph(X(:,1), X(:,2), X(:,3)); % angles in rad
% $$$     phi = phi * 180 / pi; % phi [-180,180] -> positive x-axis is 0
% $$$     theta = 90 - theta * 180 / pi; % theta [0,180] <-> [front, back]
    perp = sqrt(X(:,1).*X(:,1) + X(:,2).*X(:,2));
    xyzero = any(perp == 0, 2); % check if X AND Y are zero
    zzero = any(X(:,3) == 0, 2); % check if Z is zero
    phi = atan2(X(:,2), X(:,1)) .* (~xyzero) * 180/pi; % if X and Y are zero,
                                             % return 0 (done by
                                             % negating)
    theta = atan2(perp, X(:,3)) .* (~xyzero) .* (~zzero) * 180/pi; % if X, Y
                                                        % and Z are
                                                        % zero
                                                        % return 0
end
