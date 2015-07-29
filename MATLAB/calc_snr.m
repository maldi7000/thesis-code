function [snr, nS, nN] = calc_snr(data, row, varargin)
%CALC_SNR calculates the signal to noise ratio in the given data sample
%
% [SNR, NS, NN] = calc_snr(DATA, ROW) takes an NxM matrix DATA, where N is
% the size of one sample and M is the total number of samples, and a number
% ROW indicating the position where the signal flag is stored in the DATA
% matrix.
%
% If there are only signal samples in the set, SNR = 1 is returned

% by Thomas Madlener, 2015
if nargin < 2
    fprintf('only 1 argument. assuming signal flag to be in the last entry\n')
    row = size(data,1);
end
if ~ismatrix(data)
    error('first argument has to be a matrix!')
end
if ~isempty(varargin)
    warning('function takes only two arguments at the moment!')
end

nS = sum(data(row,:));
nN = sum(~data(row,:));
if nN ~= 0 
    snr = nS / nN;
else
%     warning('there are no noise samples in the data! Setting snr to nS!')
    snr = 1;
end