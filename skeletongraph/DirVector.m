function dir_vector = DirVector(link, point, dimensions)
    % x, y, z is a unit vector pointing in the direction of the link from
    % the specified endpoint. point should be link.n1 or link.n2 to specify
    % the endpoint
    NUM_POINTS = 10; % max number of points to consider when finding the direction
    NUM_POINTS = min(NUM_POINTS, length(link.point));
    if (link.n1 == point)
        [xpoints, ypoints, zpoints] = ind2sub(dimensions, link.point(1:NUM_POINTS));
    else % link.n2 == point
        [xpoints, ypoints, zpoints] = ind2sub(dimensions, link.point(end-NUM_POINTS:end));
    end
    t = ([0:NUM_POINTS - 1])';
    fitx = fit(t, xpoints', 'poly1');
    fity = fit(t, ypoints', 'poly1');
    fitz = fit(t, zpoints', 'poly1');
    dir_vector = [fitx.p1, fity.p1, fitz,p1];
    dir_vector = dir_vector / norm(dir_vector);
end