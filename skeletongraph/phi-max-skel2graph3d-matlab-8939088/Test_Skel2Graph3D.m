%clear all;
%close all;

% load example binary skeleton image
%load skel

%skelBig = Skeleton3D(Vl3);
% V = Vl3(:, :, 700:end);
% skel = Skeleton3D(V);

%CC = bwconncomp(Vl3, 6);
% Vl4 = zeros(size(Vl3));
%
% ii = 1;
%
% Vl4(CC.PixelIdxList{ii}) = 1;
%%
w = size(skel,1);
l = size(skel,2);
h = size(skel,3);
%%
% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,20);

% total length of network
wl = sum(cellfun('length',{node.links}));

skel2 = Graph2Skel3D(node,link,w,l,h);
% [~,node2,link2] = Skel2Graph3D(skel2,0);
[A2, node2, link2] = Skel2Graph3D(skel2, 0);

% calculate new total length of network
wl_new = sum(cellfun('length',{node2.links}));

%iterate until there are no nodes with 2 connections
iterate_nodes = true;
if iterate_nodes
    while (hasNodeWith2Links(node2))
        skel2 = Graph2Skel3D(node2,link2,w,l,h);
        [A2, node2, link2] = Skel2Graph3D(skel2, 0);
    end
end

%%


% iterate the same steps until network length changed by less than 0.5%
iterate_len = false;
if iterate_len
    while(wl_new~=wl)

        wl = wl_new;

         skel2 = Graph2Skel3D(node2,link2,w,l,h);
         [A2,node2,link2] = Skel2Graph3D(skel2,0);

         wl_new = sum(cellfun('length',{node2.links}));

    end
end
%%
% display result
figure();
hold on;
L = [];
P = [];
indx = 1;
Thresh = 0;
for i=1:length(node2)
    x1 = node2(i).comx;
    y1 = node2(i).comy;
    z1 = node2(i).comz;

    if(node2(i).ep==1)
        ncol = 'c';
    else
        ncol = 'y';
    end;

    flag = 0;
    a = [];
    for j=1:length(node2(i).links)    % draw all connections of each node
        if (i < node2(i).conn(j)) % avoid drawing connections twice
            if (node2(i).ep == 1 || node2(node2(i).conn(j)).ep == 1)
                col='b'; % branches are blue
                link_type = 1;
                if (length(link2(node2(i).links(j)).point) >= Thresh)
                    flag = 1;
                end
            else
                col='r'; % links are red
                link_type = 2;
            end;


            % draw edges as lines using voxel positions
            %CC = rand(3,1);
            if (length(link2(node2(i).links(j)).point) < Thresh && link_type == 1)
                ;
            else
                kk = length(link2(node2(i).links(j)).point);
                [xs,ys,zs]=ind2sub([w,l,h],link2(node2(i).links(j)).point(1));
                [xe,ye,ze]=ind2sub([w,l,h],link2(node2(i).links(j)).point(kk));
                n1 = norm([xs,ys,zs]-[x1,y1,z1]);
                n2 = norm([xe,ye,ze]-[x1,y1,z1]);
                if (nnz([n1 n2]) == 2)
                    if (n1 < n2)
                        L = [L; [indx, link_type, x1, y1, z1]];
                        line([y1 ys],[x1 xs],[z1 zs],'Color', col,'LineWidth',2);
                    end
                end
                %[i n1 n2 nnz([n1 n2])]
                a = [a, length(link2(node2(i).links(j)).point)];
                for k=1:length(link2(node2(i).links(j)).point)-1
                    [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
                    [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
                    line([y3 y2],[x3 x2],[z3 z2],'Color', col,'LineWidth',2);
                    L = [L; [indx, link_type, x3, y3, z3]];
                end;
                L = [L; [indx, link_type, x2, y2, z2]];
                if (nnz([n1 n2]) == 2)
                    if (n1 > n2)
                        L = [L; [indx, link_type, x1, y1, z1]];
                        line([ye y1],[xe x1],[ze z1],'Color', col,'LineWidth',2);
                    end
                end
                indx = indx + 1;
            end
        end
        %if(node2(link2(node2(i).links(j)).n2).ep==1)
        
    end;

    % draw all interior nodes as yellow circles
    if (ncol == 'y')% && flag)% && length(node2(i).links) >2)

        %if (length(a) > 2)
            P = [P; x1, y1, z1];
            %a
        %end
        %if (length(a) > 2)
            plot3(y1,x1,z1,'o','Markersize',9,...
                'MarkerFaceColor',ncol,...
                'Color','k');
        %end
    elseif (ncol == 'c')
        %[i, x1, y1, z1, length(node2(i).links)]
        % draw exterior nodes as cyan
        plot3(y1,x1,z1,'o','Markersize',9,...
                'MarkerFaceColor',ncol,...
                'Color','k');
    end
end
axis image;axis off;
set(gcf,'Color','white');
drawnow;
view(-17,46);

%return
fprintf('writing files\n');
dlmwrite('cntf_links_r2.txt', L, 'delimiter', ' ');
dlmwrite('cntf_points_r2.txt', P, 'delimiter', ' ');
fprintf('wrote files\n');

% function result = hasNodeWith2Links(node)
%     for i=1:length(node)
%         if length(node(i).links) == 2
%             result = true;
%             return;
%         end
%     end
%     result = false;
% end