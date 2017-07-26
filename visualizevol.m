% This function displays a volume in MATLAB
function visualizevol(Vol)
figure();
clf();
col=[.7 .7 .8];
hiso = patch(isosurface(Vol,0),'FaceColor',col,'EdgeColor','none');
axis equal;axis off;
lighting phong;
isonormals(Vol,hiso);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;            
set(gcf,'Color','white');
view(140,80)
