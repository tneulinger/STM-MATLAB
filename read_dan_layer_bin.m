function layer = read_dan_layer_bin(fileName)
% READ_DAN_LAYER_BIN Read a layer BIN file from Dan's Java code (c.f. Layer.writeBIN)
%
% READ_DAN_LAYER_BIN(fileName)
% 
% layer.nx = number x pixels, int
% layer.ny = number y pixels, int
% layer.bias = bias, double
% layer.current = current, double
% layer.x = vector of x positions, double
% layer.y = vector of y positions, double
% layer.data = matrix of image, double
%

fid = fopen(fileName, 'r', 'ieee-be');

layer.nx = fread(fid, 1, 'int');
layer.ny = fread(fid, 1, 'int');
layer.v  = fread(fid, 1, 'double');
layer.current = fread(fid, 1, 'double');
layer.x = fread(fid, layer.nx, 'double');
layer.y = fread(fid, layer.ny, 'double');
layer.data = fread(fid, [layer.nx layer.ny], 'double');

fclose(fid);
