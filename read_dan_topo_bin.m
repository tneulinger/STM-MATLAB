function t = read_dan_topo_bin(fileName)
% READ_DAN_TOPO_BIN Load a topo BIN file from Dan's Java code (c.f. Topomap.writeBIN)
%
% t = READ_DAN_TOPO_BIN(fileName)
%
% t.nx = number x pixels
% t.ny = number y pixels
% t.nlayers = number of layers
% t.x = column vector of x positions
% t.y = column vector of y positions
% t.v = column vector of bias values
% t.data = (t.nx) by (t.ny) by (t.nlayer) matrix of data
%
% Example:
% t = read_dan_topo_bin('myLockinX.bin');
% imagesc(t.data(:,:,1));

% open the file for reading using big-endian
fid = fopen(fileName, 'r', 'ieee-be');

% get t.nx, t.ny, and t.nlayers
t.nx = fread(fid, 1, 'int');
t.ny = fread(fid, 1, 'int');
t.nlayers = fread(fid, 1, 'int');

% read the x positions
t.x = zeros(t.nx,1);
for k = 1:t.nx
    t.x(k) = fread(fid, 1, 'double');
end

% read the y positions
t.y = zeros(t.ny,1);
for k = 1:t.ny
    t.y(k) = fread(fid, 1, 'double');
end

% read the biases
t.v = zeros(t.nlayers,1);
for k = 1:t.nlayers
    t.v(k) = fread(fid, 1, 'double');
end

% read the topomap
t.data = zeros(t.nx, t.ny, t.nlayers);
for l = 1:t.nlayers
    t.data(:, :, l) = fread(fid, [t.ny t.nx], 'double');
end

% read the names (?), leave this shit in binary
t.nameLengths = zeros(t.nlayers,1);
t.nameChars = cell(t.nlayers,1);
for k = 1:t.nlayers
   t.nameLengths(k) = fread(fid, 1, 'int');
   t.nameChars{k} = fread(fid, 2*t.nameLengths(k), 'char*1');
end


% close the file
fclose(fid);

end
