function skel = Remove2LinkNodes(node, link, w, l, h)
    % use someone else's implementation of Bresenham's line drawing
    % algorithm to remove those pesky nodes with only 2 connections
    skel = Graph2Skel3D(node, link, w, l, h);
    bad_nodes = NodesWithNLinks(node, 2);
    for i=bad_nodes
        skel(node(i).idx) = 0;
        if link(node(i).links(1)).n1 == i
            p1 = link(node(i).links(1)).point(1);
        else
            p1 = link(node(i).links(1)).point(end);
        end
        if link(node(i).links(2)).n1 == i
            p2 = link(node(i).links(2)).point(1);
        else
            p2 = link(node(i).links(2)).point(end);
        end
        [x1, y1, z1] = ind2sub([w, l, h], p1);
        [x2, y2, z2] = ind2sub([w, l, h], p2);
        [lx, ly, lz] = bresenham_line3d([x1, y1, z1], [x2, y2, z2]);
        for j=1:length(lx)
            skel(lx(j), ly(j), lz(j)) = 1;
        end
    end
end