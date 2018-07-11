function [clab] = dataio_read_loc(clab_path)
%DATAIO_READ_LOC Summary of this function goes here
%   Detailed explanation goes here
% created : 10-08-2017
% last modified : -- -- --

fid = fopen(clab_path, 'rt');
fmt = '%d %f %f %s';
datacell = textscan(fid, fmt, 'Delimiter', '  ', 'CollectOutput', 1);
fclose(fid);
clab = datacell{end}';
end

