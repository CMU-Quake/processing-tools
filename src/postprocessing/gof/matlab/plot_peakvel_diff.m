function [ratio,logratio,x,y] = plot_peakvel_diff(data1,data2)

load(['mats/' data1 '-peak-vel.mat']);
thePeakVel_1 = thePeakVel;
theLogPeakVel_1 = theLogPeakVel;

load(['mats/' data2 '-peak-vel.mat']);
thePeakVel_2 = thePeakVel;
theLogPeakVel_2 = theLogPeakVel;


ratio = thePeakVel_1 - thePeakVel_2;
ratio = ratio ./ thePeakVel_2;

logratio = thePeakVel_1./thePeakVel_2;
logratio = log10(logratio);

min(min(ratio))
max(max(ratio))

min(min(logratio))
max(max(logratio))

figure;
surf(x,y,logratio')
hold on;
contour(x,y,10+logratio',8,'k')
view(2);

load 'mats/bipolar-red-white-blue.mat';
colormap(redwhiteblue1);

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

caxis([-1.0 1.0])



