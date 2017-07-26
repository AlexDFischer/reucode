function WriteLinks(link, fname, dimensions)
    [fid, message] = fopen(fname, 'w');
    if (fid == -1)
        fprintf('error: could not open file %s: %s\n', fname, message);
        return;
    end
    for link_num=1:length(link)
        for link_point_num = 1:length(link(link_num).point)
            [x, y, z] = ind2sub(dimensions, link(link_num).point(link_point_num));
            fprintf(fid, '%d %d %d\n', x, y, z);
            if isnan(x) || isnan(y) || isnan(z)
                fprintf('nan found at link_num = %d, link_point_num = %d\n', link_num, link_point_num);
            end
        end
    end
    fclose(fid);
end