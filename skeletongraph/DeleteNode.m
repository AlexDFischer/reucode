function [node, link] = DeleteNode(node, link, i)
    % removes the given node from list of nodes, shifting all other node
    % id's downwards by 1
    
    % shift all connections greater than i downwards by one
    for j=1:length(node)
        for k=1:length(node(j).conn)
            if node(j).conn(k) > i
                node(j).conn(k) = node(j).conn(k) - 1;
            end
        end
    end
    % remove node i
    node = [node(1:i-1) node(i+1:end)];
    % because we removed node i, shift all node ids downwards by
    % one in all links
    for j=1:length(link)
        if link(j).n1 > i
            link(j).n1 = link(j).n1 - 1;
        end
        if link(j).n2 > i
            link(j).n2 = link(j).n2 - 1;
        end
    end
end