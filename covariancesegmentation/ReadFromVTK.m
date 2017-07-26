%% DOESN'T WORK
function Vol = ReadFromVTK(filename)
    [fid, error] = fopen(filename, 'r');
    if fid == -1
        fprintf('error: %s\n', error);
        Vol = [];
        return;
    end
    % get dimensions from file
    line = [];
    while ~strncmpi(line, 'DIMENSIONS', 10)
        line = fgets(fid);
    end
    dimensions = textscan(line, 'DIMENSIONS %d %d %d\n');
    dimensions = cell2mat(dimensions);
    Vol = zeros(dimensions(1), dimensions(2), dimensions(3));
    fclose(fid);
    return;
        