function [header, mapStructure] = load3ds_map(fileName)
% LOAD3DS_MAP Load a Nanonis 3ds dIdV-map
%
% [header, mapStructure] = LOAD3DS_MAP(fileName)
%
% The 'header' structure contains experimental information, e.g.
%   header.bias = [start bias, ..., end bias]
%   header.fixed_parameters = {'Sweep Start', 'Sweep End'}
%   header.experiment_parameters = {'X (m)', 'Y (m)', 'Z (m)', ... 
%       'Z offset (m)', 'Settling time (s)', 'Integration time', ...
%       'Z-Ctrl hold', 'Final Z (m)'}
%
% The 'mapStructure' structure contains...
%   mapStructure.R = X, Y, and Z topography
%   mapStructure.current = the 3d current channel map
%   mapStructure.lockinX = the 3d lockin-X channel map
%   mapStructure.lockinY = the 3d lockin-Y channel map
%
% Note on Nanonis 3ds file structure: The 3ds binary file consists of an
% ASCII header followed by binary data. The header consists of key-value
% pairs, separated by an equal sign. For example, 'Grid dim="64 x 64"'. The
% binary data which follow correspond to a set of data for each point. The
% first few bytes of each of these is parameter information, e.g. starting
% and ending sweep voltages, Z position, etc. The next bytes are channel
% information, e.g. current, lockin-X channel, etc.
%
% Example:
% [header, mapStructure] = load3ds_map('test.3ds');
% subplot(1,3,1); imagesc(mapStructure.R(:,:,3));
% subplot(1,3,2); imagesc(mapStructure.lockinX(:,:,1));
% subplot(1,3,3); image(fftshift(abs(fft2(mapStructure.lockinX(:,:,1)))));


% open the file for reading using big-endian
fid = fopen(fileName, 'r', 'ieee-be');


% read the header
header='';                              % header structure
while 1
    s = strtrim(fgetl(fid));            % get line without nl character
    if strcmpi(s,':HEADER_END:')        % check for end of header to break
        break
    end
    
    s1 = strsplit(s,'=');               % split line into key and value 

    s_key = strrep(lower(s1{1}), ' ', '_'); % make lower case
    s_val = strrep(s1{2}, '"', '');         %
    
    switch s_key                        % do something different for each
    
        % dimension:
        case 'grid_dim'
            s_vals = strsplit(s_val, 'x');
            header.grid_dim = [str2double(s_vals{1}), str2double(s_vals{2})];

        % grid settings:
        case 'grid_settings'
            header.grid_settings = sscanf(s_val, '%f;%f;%f;%f;%f');

        % fixed parameters, experiment parameters, channels:
        case {'fixed_parameters', 'experiment_parameters', 'channels'}
            s_vals = strsplit(s_val, ';');
            header.(s_key) = s_vals;

        % number of parameters:
        case '#_parameters_(4_byte)'
            header.num_parameters = str2double(s_val);

        % experiment size:
        case 'experiment_size_(bytes)'
            header.experiment_size = str2double(s_val);

        % spectroscopy points:
        case 'points'
            header.points = str2double(s_val);

        % delay before measuring:
        case 'delay_before_measuring_(s)'
            header.delay_before_meas = str2double(s_val);

        % other parameters -> treat as strings:
        otherwise
            s_key = regexprep(s_key, '[^a-z0-9_]', '_');
            header.(s_key) = s_val;
    end
    
end

% length in bytes of the data at a point (a physical tip location)
%   We don't actually use it, but it helps for understanding.
%   E.g. say you record 10 parameters and 3 channels of 21 points at each
%   location. All data are stored as floating points (4 bytes long).
%   header.num_parameters*4 = (10 parameters)*(4 bytes) = 40
%   header.experiment_size = (3 channels)*(21 points)*(4 bytes) = 252
%   exp_size = 40 + 252 = 292
%   So the block of data corresponding to one location is 292 bytes long.
%exp_size = header.num_parameters*4 + header.experiment_size;


% initialize 3d data object and channels
mapStructure = '';

mapStructure.R = zeros(header.grid_dim(1),header.grid_dim(2),3);
mapStructure.current = zeros(header.grid_dim(1),header.grid_dim(2),header.points);
mapStructure.lockinX = zeros(header.grid_dim(1),header.grid_dim(2),header.points);
mapStructure.lockinY = zeros(header.grid_dim(1),header.grid_dim(2),header.points);

% read the data at each point
for x_index = 1:header.grid_dim(1);
    
    for y_index = 1:header.grid_dim(2);
        
        % read the parameter bytes
        par = fread(fid, header.num_parameters, 'float');
        
        % read the channel bytes into columns of 'data'
        data = fread(fid, [header.points numel(header.channels)], 'float');

        mapStructure.R(x_index, y_index, 1) = par(3);   % X
        mapStructure.R(x_index, y_index, 2) = par(4);   % Y
        mapStructure.R(x_index, y_index, 3) = par(5);   % Z topography
        mapStructure.current(x_index, y_index, :) = data(:,1);
        mapStructure.lockinX(x_index, y_index, :) = data(:,2);
        mapStructure.lockinY(x_index, y_index, :) = data(:,3);
        
    end
    
end

% get the bias vector
header.bias = linspace(par(1), par(2), header.points);

fclose(fid);
