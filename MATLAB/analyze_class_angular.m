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

cutvalue = 0.5; % TODO; CALCULATE THIS FROM INPUT DATA!
%% function main body
[~,theta,phi] = cart2sph_basf2(inputs(:,1:3));
% analyze_class_bins_dep(targets,outputs,phi,nPhiBins, '\phi [\circ]'); % old version of function for other plots
% analyze_class_bins_dep(targets,outputs,theta,nThetaBins, '\theta [\circ]'); % old version of function for other plots
analyze_class_bins(targets,outputs,cutvalue,phi,nPhiBins, '\phi [\circ]');
analyze_class_bins(targets,outputs,cutvalue,theta,nThetaBins, '\theta [\circ]');
end

%% helper functions
% transform cartesian coordinates X (Nx3 matrix) to spherical coordinates
% as used in BASF2
function [r,theta,phi] = cart2sph_basf2(X)
    [phi,theta,r] = cart2sph(X(:,1), X(:,2), X(:,3)); % angles in rad
    phi = phi * 180 / pi; % phi [-180,180] -> positive x-axis is 0
    theta = 90 - theta * 180 / pi; % theta [0,180] <-> [front, back]
end
