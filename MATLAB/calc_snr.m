function [snr, nS, nN] = calc_snr(data, col, varargin)
%CALC_SNR calculates the signal to noise ratio in the given data sample
%
% [SNR, NS, NN] = calc_snr(DATA, ROW) takes an NxM matrix DATA, where N is
% the size of one sample and M is the total number of samples, and a number
% ROW indicating the position where the signal flag is stored in the DATA
% matrix.

% by Thomas Madlener, 2015
if nargin < 2
    fprintf('only 1 argument. assuming signal flag to be in the last entry\n')
    col = size(data,1);
end
if ~ismatrix(data)
    error('first argument has to be a matrix!')
end
if ~isempty(varargin)
    warning('function takes only two arguments at the moment!')
end

nS = sum(data(col,:));
nN = sum(~data(col,:));
if nN ~= 0 
    snr = nS / nN;
else
    warning('there are no noise samples in the data! Setting snr to nS!')
    snr = nS;
end