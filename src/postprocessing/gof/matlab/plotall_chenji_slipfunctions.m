
function [slip,sliprate,slipfas,t,f] = plotall_chenji_slipfunctions(file)

DT        = 0.01;
TOTALTIME = 3;
FMIN      = 0.01;
FMAX      = 4;
POINTS    = 16384;

dt        = DT;
totaltime = TOTALTIME;
fmin      = FMIN;
fmax      = FMAX;
points    = POINTS;

[pointsources,n] = read_chenjiformat(file);

figure;
t = 0:dt:totaltime-dt;
subplot(2,2,1); hold on;
subplot(2,2,3); hold on;
subplot(2,2,4); hold on;
    
for i = 1:n
    
    slipfunction = chenji_slipfunction(pointsources(i,:),dt,totaltime,0);
    
    subplot(2,2,1)
    plot(t,slipfunction(:,1));

    subplot(2,2,3)
    plot(t,slipfunction(:,2));
    
    [f,fs] = fourierbounded(slipfunction(:,2),fmin,fmax,dt,points);
    subplot(2,2,4)
    plot(f,fs);
    
    slip(:,i) = slipfunction(:,1);
    sliprate(:,i) = slipfunction(:,2);
    slipfas(:,i)=fs;
end


meanslip     = mean(slip,2);
meansliprate = mean(sliprate,2);
meanslipfas  = mean(slipfas,2);

[f,foo] = fourierbounded(meansliprate,fmin,fmax,dt,points);

figure;
subplot(3,1,1)
plot(t,meanslip);
subplot(3,1,2)
plot(t,meansliprate);
subplot(3,1,3)
plot(f,meanslipfas);
hold on;
plot(f,foo);
