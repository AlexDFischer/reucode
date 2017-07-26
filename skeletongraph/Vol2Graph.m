function [skel2, node, link] = Vol2Graph(skel1, min_length, writeFiles, intLinksFolder, extLinksFolder, endPointsFolder, intBPointsFolder, extBPointsFolder)
    width = size(skel1, 1);
    len = size(skel1, 2);
    height = size(skel1, 3);
    [~, node, link] = Skel2Graph3D(skel1, min_length);
    i = 0;
    while ~isempty(NodesWithNLinks(node, 0))
        i = i + 1;
        fprintf('converting for the %dth time: there are %d nodes with 2 links and %d nodes with 0 links\n', i, length(NodesWithNLinks(node, 2)), length(NodesWithNLinks(node, 0)));
        skel2 = Graph2Skel3D(node, link, width, len, height);
        [~, node, link] = Skel2Graph3D(skel2, min_length);
    end
    skel2 = Remove2LinkNodes(node, link, width, len, height);
    [~, node, link] = Skel2Graph3D(skel2, 0);
    fprintf('after removing bad nodes, there are %d nodes with 2 links\n', length(NodesWithNLinks(node, 2)));
    interiorLinks = [];
    exteriorLinks = [];
    for i=1:length(link)
        if node(link(i).n1).ep == 1 || node(link(i).n2).ep == 1
            exteriorLinks = [exteriorLinks, link(i)];
        else
            interiorLinks = [interiorLinks, link(i)];
        end
    end
    if writeFiles
        WriteLinks(interiorLinks, intLinksFolder, size(skel1));
        WriteLinks(exteriorLinks, extLinksFolder, size(skel1));
    end
    endPoints = [];
    exteriorBranchPoints = [];
    interiorBranchPoints = [];
    for i=1:length(node)
        if (node(i).ep == 1)
            endPoints = [endPoints, node(i)];
        elseif isExteriorBranchPoint(node, node(i))
            exteriorBranchPoints = [exteriorBranchPoints, node(i)];
        else
            interiorBranchPoints = [interiorBranchPoints, node(i)];
        end
    end
    if writeFiles
        WriteNodes(endPoints, endPointsFolder);
        WriteNodes(exteriorBranchPoints, extBPointsFolder);
        WriteNodes(interiorBranchPoints, intBPointsFolder);
    end
end

function result = isExteriorBranchPoint(node, point)
    for neighbor = point.conn
        if node(neighbor).ep == 1
            result = true;
            return;
        end
    end
    result = false;
    return;
end