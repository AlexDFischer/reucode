function result = MaxLinks(node)
    result = 0;
    for i=1:length(node)
        result = max(result, length(node(i).links));
    end
end