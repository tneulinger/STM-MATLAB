function write_dan_topo_bin(fileName, t)
% WRITE_DAN_TOPO_BIN Write a topo BIN file from Dan's Java code (c.f. Topomap.writeBIN)
%
% t = WRITE_DAN_TOPO_BIN(fileName)
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

% open the file for writing using big-endian
fid = fopen(fileName, 'w', 'ieee-be');

% write t.nx, t.ny, and t.nlayers
fwrite(fid, t.nx, 'int');       %t.nx = fread(fid, 1, 'int');
fwrite(fid, t.ny, 'int');       %t.ny = fread(fid, 1, 'int');
fwrite(fid, t.nlayers, 'int');  %t.nlayers = fread(fid, 1, 'int');

% write the x positions
for k = 1:t.nx
    fwrite(fid, t.x(k), 'double'); %t.x(k) = fread(fid, 1, 'double');
end

% write the y positions
for k = 1:t.ny
    fwrite(fid, t.y(k), 'double'); %t.y(k) = fread(fid, 1, 'double');
end

% write the biases
for k = 1:t.nlayers
    fwrite(fid, t.v(k), 'double'); %t.v(k) = fread(fid, 1, 'double');
end

% write the topomap
for k = 1:t.nlayers
    for j = 1:t.ny
        for i = 1:t.nx
            fwrite(fid, t.data(i,j,k), 'double');
        end
    end
end

% write the names (?)
for k = 1:t.nlayers
   fwrite(fid, t.nameLengths(k), 'int');    %t.nameLengths(k) = fread(fid, 1, 'int');
   fwrite(fid, t.nameChars{k}, 'char*1');   %t.nameChars{k} = fread(fid, 2*t.nameLengths(k), 'char*1');
end

% close the file
fclose(fid);

end
