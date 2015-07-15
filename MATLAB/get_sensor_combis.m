function [N, C] = get_sensor_combis(data)
%GET_SENSOR_COMBIS checks the occuring sensor combinations in the passed data
%
% [N, C] = get_sensor_combis(DATA) takes a 17xN matrix DATA and calculates
% the number of sensor combinations N and also returns the sensor
% combinations in vector C.
%
% VxdIDs have to be on [10:12] in data

% by Thomas Madlener
sens_combs = data(10,:)*1e10 + data(11,:)*1e5 + data(12,:);
C = unique(sens_combs);
N = length(C);
end
