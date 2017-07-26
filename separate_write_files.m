% This file takes a segmented volume and separates it into connected regions, writing each region to its own file.
% fname should have 2 format specifiers: one for the number of points in the region, another for the region number.
% min_points is the minimum number of points a region must have in order to be written to a file.
% example usage: [num_regions, points_per_region] = separate_write_files(Vol, 'mysegmentation_regions/region_%09d_%05d.vtk', 1000);
function [num_regions, points_per_region] = separate_write_files(Vol, fname, min_points)
    Z_SCALE_FACTOR = 2;
    num_regions = 0;
    points_per_region = [];
    for row = 1:size(Vol, 1)
        fprintf('\ron row %03d out of %d', row, size(Vol, 1));
        for col = 1:size(Vol, 2)
            for z = 1:size(Vol, 3)
                if (Vol(row, col, z) == 1)
                    % we found a new region, do a depth first search
                    region = zeros(size(Vol, 1), size(Vol, 2), size(Vol, 3));
                    num_points = 1;
                    stack = java.util.Stack();
                    stack.push([row; col; z]);
                    Vol(row, col, z) = 0;
                    region(row, col, z) = 1;
                    while ~stack.isEmpty()
                        point = stack.pop();
                        for offset = [[1;0;0],[-1;0;0],[0;1;0],[0;-1;0],[0;0;1],[0;0;-1]]
                            new_point = point + offset;
                            if in_bounds(new_point, Vol) && Vol(new_point(1), new_point(2), new_point(3))
                                stack.push(new_point);
                                Vol(new_point(1), new_point(2), new_point(3)) = 0;
                                region(new_point(1), new_point(2), new_point(3)) = 1;
                                num_points = num_points + 1;
                            end
                        end
                    end
                    if (num_points >= min_points)
                        points_per_region = [points_per_region, num_points];
                        num_regions = num_regions + 1;
                        WriteToVTKGeneric(region, sprintf(fname, num_points, num_regions), Z_SCALE_FACTOR);
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
