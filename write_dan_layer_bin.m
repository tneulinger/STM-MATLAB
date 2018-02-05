function write_dan_layer_bin(fileName, layer)
% WRITE_DAN_LAYER_BIN Write a layer BIN file for Dan's Java code (c.f. Layer.writeBIN)
%
% WRITE_DAN_LAYER_BIN(fileName, layer)
% 
% layer.nx = number x pixels, int
% layer.ny = number y pixels, int
% layer.bias = bias, double
% layer.current = current, double
% layer.x = vector of x positions, double
% layer.y = vector of y positions, double
% layer.data = matrix of image, double
%
% Examples:
% smiley = im2double(imread('face.png'));
% layer.nx = size(smiley, 1);
% layer.ny = size(smiley, 2);
% layer.v = 0.1;
% layer.current = 0.1;
% layer.x = linspace(0,10e-9, layer.nx);
% layer.y = linspace(0,10e-9, layer.ny);
% layer.data = im2double(smiley);
% write_dan_layer_bin('smiley.bin', layer)

% Open file for writing, big-endian
fid = fopen(fileName, 'w', 'ieee-be');

fwrite(fid, layer.nx, 'int');   % write number of x pixels
fwrite(fid, layer.ny, 'int');   % write number of y pixels
fwrite(fid, layer.v, 'double'); % write bias
fwrite(fid, layer.current, 'double');   % write current
fwrite(fid, layer.x, 'double'); % write x vector
fwrite(fid, layer.y, 'double'); % write y vector
fwrite(fid, layer.data(:), 'double');   % write data

fclose(fid);