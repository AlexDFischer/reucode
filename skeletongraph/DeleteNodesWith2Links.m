function [node, link] = DeleteNodesWith2Links(node, link, dimensions)
    i = 1;
    while i <= length(node)
        if length(node(i).links) == 2
            [node, link] = MergeLinks(node, link, node(i).links(1), node(i).links(2), i, i, dimensions);
            [node, link] = DeleteNode(node, link, i);
%             l1 = node(i).links(1);
%             l2 = node(i).links(2);
%             % merge l1 and l2
%             if link(l1).n1 == i
%                 conn1 = link(l1).n2;
%                 badNodeP1 = link(l1).point(1);
%             else
%                 conn1 = link(l1).n1;
%                 badNodeP1 = link(l1).point(end);
%             end
%             if link(l2).n1 == i
%                 conn2 = link(l2).n2;
%                 badNodeP2 = link(l2).point(1);
%             else
%                 conn2 = link(l2).n1;
%                 badNodeP2 = link(l2).point(end);
%             end
%             % connect p1 and p2 and add l2's points to l1
%             [x1, y1, z1] = ind2sub(dimensions, badNodeP1);
%             [x2, y2, z2] = ind2sub(dimensions, badNodeP2);
%             [lx, ly, lz] = bresenham_line3d([x1, y1, z1], [x2, y2, z2]);
%             link(l1).point = [link(l1).point, sub2ind(dimensions, lx, ly, lz), link(l2).point];
%             % remove l2 and update connections and links of neighboring
%             % points to the bad node
%             link = [link(1:l2 - 1) link(l2 + 1:end)];
%             node(conn1).conn(node(conn1).conn == i) = conn2;
%             node(conn2).conn(node(conn2).conn == i) = conn1;
%             node(conn2).links(node(conn2).links == l2) = l1;
%             % because we removed l2, shift all links greater than it
%             % downwards by one, and shift all connections greater than i
%             % downwards by one
%             for j=1:length(node)
%                 for k=1:length(node(j).links)
%                     if node(j).links(k) > l2
%                         node(j).links(k) = node(j).links(k) - 1;
%                     end
%                     if node(j).conn(k) > i
%                         node(j).conn(k) = node(j).conn(k) - 1;
%                     end
%                 end
%             end
%             % remove node i
%             node = [node(1:i-1) node(i+1:end)];
%             % because we removed node i, shift all node ids downwards by
%             % one in all links
%             for j=1:length(link)
%                 if link(j).n1 > i
%                     link(j).n1 = link(j).n1 - 1;
%                 end
%                 if link(j).n2 > i
%                     link(j).n2 = link(j).n2 - 1;
%                 end
%             end
        else
            i = i + 1;
        end
    end
end