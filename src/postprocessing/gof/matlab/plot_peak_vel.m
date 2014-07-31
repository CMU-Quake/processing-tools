%
% script to create peak velocity plot (HERCULES format)
%
fp=fopen('planedis-cvms.bin');

deltaT       = 0.001*20;
iTimeReal    = 1;

alongStrike  = 271;
downDip      = 361;

stepAlongStrike = 500;
stepDownDip     = 500;

% limitvel     = 0.7;

% figure('Position',[100 200 800 465],'Color',[0.3 0.3 0.3]); 
figure('Position',[100 1000 800 465]); 

y = 0:stepAlongStrike:stepAlongStrike*(alongStrike-1);
x = 0:stepDownDip:stepDownDip*(downDip-1);

dis = fread(fp, downDip*alongStrike*3,'float64');

X = dis(1:3:downDip*alongStrike*3);
Y = dis(2:3:downDip*alongStrike*3);
Z = dis(3:3:downDip*alongStrike*3);

disX1 = reshape(X,downDip,alongStrike);
disY1 = reshape(Y,downDip,alongStrike);
disZ1 = reshape(Z,downDip,alongStrike);    

thePeakVel = zeros(downDip,alongStrike);

load ./themaps.mat;

for iTime=1:5000;

    if(mod(iTime,10)==0) 
        disp(int2str(iTime));
    end

    dis = fread(fp, downDip*alongStrike*3,'float64');
    
    X = dis(1:3:downDip*alongStrike*3);
    Y = dis(2:3:downDip*alongStrike*3);
    Z = dis(3:3:downDip*alongStrike*3);

    disX2 = reshape(X,downDip,alongStrike);
    disY2 = reshape(Y,downDip,alongStrike);
    disZ2 = reshape(Z,downDip,alongStrike);    

    velX=(1/deltaT)*(disX2-disX1);
    velY=(1/deltaT)*(disY2-disY1);     
    velZ=(1/deltaT)*(disZ2-disZ1);

    theStepVelMag = (velX.^2 + velY.^2).^(0.5);
    thePeakVel = max(theStepVelMag,thePeakVel);
            
    disX1 = disX2;        
    disY1 = disY2;    
    disZ1 = disZ2;

end

thePeakVel = thePeakVel*100;

min(min(thePeakVel))
max(max(thePeakVel))

theLogPeakVel = log10(thePeakVel);

min(min(theLogPeakVel))
max(max(theLogPeakVel))

surf(x,y,theLogPeakVel')
view(2);

colormap(white_to_black);

bc = colormap;
bc = bc(1,:);

% xlabel('Dir Y');
% ylabel('Dir X');

set(gca,'XTick',[])
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
set(gca,'XTickLabel',[])
set(gca,'Color',bc)

shading interp;       

% caxis([0 limitvel])
% colormap(jet);

colorbar;
      
axis on;
grid off;
box off;

xlim([0 180000])
ylim([0 135000])

caxis([log10(.3) log10(80)])

saveas(gcf,'cvms-peak-vel','fig')
save('cvms-peak-vel.mat')


