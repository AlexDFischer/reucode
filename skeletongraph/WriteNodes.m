function WriteNodes(node, fname)
    fid = fopen(fname, 'w');
    for i = 1:length(node)
        fprintf(fid, '%f %f %f\n', node(i).comx, node(i).comy, node(i).comz);
    end
    fclose(fid);
end