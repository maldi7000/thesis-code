function data = filter_vxdid( indata, option )
%FILTER_VXDID filters the data by the information obtainable from the VxdID
%
% DATA = filter_vxdid(INDATA, OPTION) takes an 17xN matrix INDATA and returns
% a 17xN matrix DATA, where the output has been sorted according to the
% passed OPTION.
%
% The VxdIds have to be stored in the columns 10,11,12
%
% OPTION == 0: the hits are on consecutive layers
% OPTION == [1-6]: the innermost hit is on layer OPTION
% OPTION == 7: the hits are not on consecutive layers (complement to 0)
% OPTION == 8: at least two hits are on the same layer
% OPTION == 9: there is a gap in layer number between at least two hits

%% global definitions
VXDRANGE = [8480,10304; 16672,19520; 24864,26432; 33056,35424; 41248,44160; 49440,53408]; % vxdid layer edges in raw format

% by Thomas Madlener

%% input checks
if nargin ~= 2, error('wrong number of input arguments'), end
if (option > 7 || option < 0), error('option has to be in the range [0,7]'), end

%% main
if option > 0 && option < 7
    data = innerlayer(indata,option, VXDRANGE);
else
    layers = get_layers(indata(10:12,:),VXDRANGE); % get the layer numbers
    l_diff = diff(layers); % calculate the difference between layers
    d_prod = prod(l_diff); % multiply the layer differences in each sample to differentiate below
end
if option == 0
    data = indata(:,d_prod == 1); % return only the data set where the layer increased by exactly one in each layer
end,
if option == 7
    data = indata(:,d_prod ~= 1); % return data where the difference in layers is not equal to one
end
if option == 8
    data = indata(:,d_prod == 0);
end
if option == 9
    data = indata(:,d_prod > 1);
end

end

%% helper functions
function data = innerlayer(indata,lay,vrange)
    on_layer = indata(10,:) >= vrange(lay,1) & indata(10,:) <= vrange(lay,2);
    data = indata(:,on_layer);
end

function layers = get_layers(vxdids, vrange)
    layers = zeros(size(vxdids));
    for i=1:6
        tmp = bsxfun(@ge, vxdids, vrange(i,1)) & bsxfun(@le, vxdids, vrange(i,2));
        layers = layers + i * tmp;
    end
end
