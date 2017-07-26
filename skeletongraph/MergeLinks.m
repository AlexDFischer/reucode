function [node, link] = MergeLinks(node, link, link1, link2, node1, node2, dimensions)
    % draw a line from node1 on link1 to node2 on link2, merge link2 onto
    % link1, delete link1, and remove link1 and link2 from node1 and node2
    
    % remove link1 and link2 from node1 and node2, respectively, and remove
    % corresponding connections from node1 and node2
    link1index = find(node(node1).links == link1);
    link2index = find(node(node2).links == link2);
    node(node1).links = [node(node1).links(1:link1index - 1) node(node1).links(link1index + 1:end)];
    node(node2).links = [node(node2).links(1:link2index - 1) node(node2).links(link2index + 1:end)];
    % merge link1 and link2
    if link(link1).n1 == node1
        conn1 = link(link1).n2;
        p1 = link(link1).point(1);
    else % link(link1).n2 == node1
        conn1 = link(link1).n1;
        p1 = link(link1).point(end);
    end
    if link(link2).n1 == node2
        conn2 = link(link2).n2;
        p2 = link(link2).point(1);
    else % link(link2).n2 == node2
        conn2 = link(link2).n1;
        p2 = link(link2).point(end);
    end
    % connect p1 and p2 and add l2's points to l1
    [x1, y1, z1] = ind2sub(dimensions, p1);
    [x2, y2, z2] = ind2sub(dimensions, p2);
    [lx, ly, lz] = bresenham_line3d([x1, y1, z1], [x2, y2, z2]);
    link(link1).point = [link(link1).point, sub2ind(dimensions, lx, ly, lz), link(link2).point];
    % remove l2 and update connections and links of neighboring
    % points
    link = [link(1:link2 - 1) link(link2 + 1:end)];
    node(conn1).conn(node(conn1).links == link1) = conn2;
    node(conn2).conn(node(conn2).links == link2) = conn1;
    node(conn2).links(node(conn2).links == link2) = link1;
    % because we removed l2, shift all links greater than it
    % downwards by one
    for j=1:length(node)
        for k=1:length(node(j).links)
            if node(j).links(k) > link2
                node(j).links(k) = node(j).links(k) - 1;
            end
        end
    end
end