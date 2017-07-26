function result = NodesWithNLinks(node, n)
    result = [];
    for i=1:length(node)
        if length(node(i).links) == n
            result = [result i];
        end
    end
    return;
end