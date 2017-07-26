% This function separates a segmented volume into connected regions. the regions variable that is returned is the same shape as the Vol
% variable inputted, but it will be either 0, or 1, 2, 3 ... depending on what region the point was assigned to. So regions(1,5,4) will
% be 0 if it's not in the segmented volume, 1, if it's in the first region it found, 2 if it's in the second region, etc.
% min_points is the minimum number of points a connected region must have in order to be considered.
% example usage: [regions, num_regions, points_per_region] = separate(Vol, 1000);
function [regions, num_regions, points_per_region] = separate(Vol, min_points)
    regions = zeros(size(Vol, 1), size(Vol, 2), size(Vol, 3));
    num_regions = 0;
    points_per_region = [];
    fprintf('\n');
    for row = 1:size(Vol, 1)
        fprintf('\ron row %03d out of %d', row, size(Vol, 1));
        for col = 1:size(Vol, 2)
            for z = 1:size(Vol, 3)
                if (Vol(row, col, z) == 1)
                    % we found a new region, do a depth first search
                    points_per_region = [points_per_region,1];
                    num_regions = num_regions + 1;
                    stack = java.util.Stack();
                    stack.push([row; col; z]);
                    Vol(row, col, z) = 0;
                    regions(row, col, z) = num_regions;
                    while ~stack.isEmpty()
                        point = stack.pop();
                        for offset = [[1;0;0],[-1;0;0],[0;1;0],[0;-1;0],[0;0;1],[0;0;-1]]
                            new_point = point + offset;
                            if in_bounds(new_point, Vol) && Vol(new_point(1), new_point(2), new_point(3))
                                stack.push(new_point);
                                Vol(new_point(1), new_point(2), new_point(3)) = 0;
                                regions(new_point(1), new_point(2), new_point(3)) = num_regions;
                                points_per_region(num_regions) = points_per_region(num_regions) + 1;
                            end
                        end
                    end
                    if (points_per_region(num_regions) < min_points)
                        regions(regions == num_regions) = 0;
                        num_regions = num_regions - 1;
                        points_per_region = points_per_region(1:end-1);
                    end
                end
            end
        end
    end
    fprintf('\n');
    return;

function in_bounds = in_bounds(p, Vol)
    in_bounds = p(1) >= 1 && p(1) <= size(Vol, 1) ...
             && p(2) >= 1 && p(2) <= size(Vol, 2) ...
             && p(3) >= 1 && p(3) <= size(Vol, 3);
     return;
