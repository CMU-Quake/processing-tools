function plot_ready_peakvel(dataset)

load(['mats/' dataset '-peak-vel.mat']);

min(min(thePeakVel))
max(max(thePeakVel))

min(min(theLogPeakVel))
max(max(theLogPeakVel))

% figure;
% subplot(1,2,1);
% surf(x,y,thePeakVel')
% view(2);
% 
% colormap(white_to_black);
% 
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% set(gca,'YTickLabel',[])
% set(gca,'XTickLabel',[])
% set(gca,'Color',bc)
% 
% shading interp;       
% 
% colorbar;
%       
% axis on;
% grid off;
% box off;
% 
% xlim([0 180000])
% ylim([0 135000])
% 
% caxis([.3 80])
% 

figure;
% subplot(1,2,2);
surf(x,y,theLogPeakVel')
view(2);

colormap(white_to_black);

set(gca,'XTick',[])
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
set(gca,'XTickLabel',[])
set(gca,'Color',bc)

shading interp;       

colorbar;
      
axis on;
grid off;
box off;

xlim([0 180000])
ylim([0 135000])

caxis([log10(.3) log10(80)])


