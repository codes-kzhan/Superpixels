function h = draw_label_image(im, S, palette, classes, index, pAcc)

imLabeled = palette(S+1,:);
imLabeled = reshape(imLabeled,[size(S) 3]);
tmp = ones([size(imLabeled,1) 128 size(imLabeled,3)]);
imLabeled = [im, imLabeled tmp];
show(imLabeled); 
if nargin > 4
    text(300,240, [num2str(index) ' p=' num2str(pAcc)]);
end
hold on;
% colorbar('YTick',unique(predictLabel),'YTickLabel',classes(unique(predictLabel)));
labels = unique(S);
for cc = 1:length(labels);plot([0 0],'LineWidth', 8,'Color',palette(labels(cc)+1,:));end;
legend(classes(labels+1));hold off;drawnow;
set(gcf,'PaperPositionMode','auto');
% set(gca,'units','normalized','position',[0 0 0.8 0.8]);
hold off;