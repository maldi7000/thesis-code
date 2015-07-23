function [ SNR ] = calculate_snr_at_eff( S, R, eff )
%CALCULATE_SNR_AT_EFF calculates the SNR achievable for a given efficiency
% 
% TO COME
% get the SNR for a given efficiency
% CAUTION: for this to work properly R has to be monotonically increasing
% in each column AND it has to be greater than r at one point!

% by Thomas Madlener, 2015

gtr = R >= eff; % mark all values, that are larger than a given value
gtr = diff(gtr); % find the jump
gtr = [gtr; zeros(1,size(gtr,2))]; % add a line of zeros (bring matrix back to same size as R and S)
SNR = S((gtr ~= 0)); % get the according SNR values from S (for each column there is only one non-zero entry in gtr now)
end


