
function [simuVel, success] = compare_signals(dataRoot,simuRoot,stationName,stationNumber,doPlot,hf)

ROTANGLE  = 39.9;
FMIN      = 0.15;
FMAX      = 1;
ORDERLOW  = 9;
ORDERHIGH = 3;
RP        = 0.5;

dataFile = [dataRoot, '/', stationName, '.her'];
simuFile = [simuRoot, '/station.', num2str(stationNumber)];
simuVel = 0.0;
success = 0;

% Loading data signals
% --------------------

fprintf('Opening datafile %s\n', dataFile);
fp = fopen(dataFile,'r');
if (fp == -1)
    return;
end

fgetl(fp);

temp = fscanf(fp, '%g %g %g %g %g %g %g %g %g %g\n', [10,inf]);
temp = temp';

dataT   = temp(:,1);
dataDis = temp(:,2:4);
dataVel = temp(:,5:7);
dataAcc = temp(:,8:10);

dataDT   = temp(2,1);
dataSize = size(dataT);
dataSize = dataSize(1);
dataTime = dataT(dataSize,1);

fclose(fp);

% Loading simulation synthetics
% -----------------------------

fp = fopen(simuFile,'r');
fgetl(fp);

temp = fscanf(fp, '%g %g %g %g %g %g %g %g %g %g\n', [10,inf]);
temp = temp';

simuT   = temp(:,1);
simuDis = temp(:,2:4)*100;
simuVel = temp(:,5:7)*100;
simuAcc = temp(:,8:10)*100;

simuDT   = temp(2,1);
simuSize = size(simuT);
simuSize = simuSize(1);
simuTime = simuT(simuSize,1);

fclose(fp);

% Rotate synthetics (counter clockwise)
% -------------------------------------

radAngle = ROTANGLE * pi / 180;

temp = simuDis;
simuDis(:,1) = temp(:,1).*(cos(radAngle)) - temp(:,2).*(sin(radAngle));
simuDis(:,2) = temp(:,2).*(cos(radAngle)) + temp(:,1).*(sin(radAngle));
simuDis(:,3) = temp(:,3).*(-1);

temp = simuVel;
simuVel(:,1) = temp(:,1).*(cos(radAngle)) - temp(:,2).*(sin(radAngle));
simuVel(:,2) = temp(:,2).*(cos(radAngle)) + temp(:,1).*(sin(radAngle));
simuVel(:,3) = temp(:,3).*(-1);

temp = simuAcc;
simuAcc(:,1) = temp(:,1).*(cos(radAngle)) - temp(:,2).*(sin(radAngle));
simuAcc(:,2) = temp(:,2).*(cos(radAngle)) + temp(:,1).*(sin(radAngle));
simuAcc(:,3) = temp(:,3).*(-1);

% Filtering synthetics according to processing of data
% ----------------------------------------------------

cornerlow = FMAX / ( (1/simuDT)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

cornerhigh = FMIN / ( (1/simuDT)/2 );
[bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% Highpass

simuVel(:,1) = filter(bh,ah,simuVel(:,1));
simuVel(:,2) = filter(bh,ah,simuVel(:,2));
simuVel(:,3) = filter(bh,ah,simuVel(:,3));

% Lowpass

simuAcc(:,1) = filter(bl,al,simuAcc(:,1));
simuAcc(:,2) = filter(bl,al,simuAcc(:,2));
simuAcc(:,3) = filter(bl,al,simuAcc(:,3));

simuVel(:,1) = filter(bl,al,simuVel(:,1));
simuVel(:,2) = filter(bl,al,simuVel(:,2));
simuVel(:,3) = filter(bl,al,simuVel(:,3));

simuDis(:,1) = filter(bl,al,simuDis(:,1));
simuDis(:,2) = filter(bl,al,simuDis(:,2));
simuDis(:,3) = filter(bl,al,simuDis(:,3));

% Find common length
% ------------------

length(dataT);
length(simuT);
totalTimeData = dataT(length(dataT));
totalTimeSimu = simuT(length(simuT));
minT = min(totalTimeData,totalTimeSimu);
nData = fix(minT/dataDT+1);
nSimu = fix(minT/simuDT+1);

dataT   = dataT(1:nData,:);
dataAcc = dataAcc(1:nData,:);
dataVel = dataVel(1:nData,:);
dataDis = dataDis(1:nData,:);

simuT   = simuT(1:nSimu,:);
simuAcc = simuAcc(1:nSimu,:);
simuVel = simuVel(1:nSimu,:);
simuDis = simuDis(1:nSimu,:);

% Compute Spectra
% ---------------

infFreq = 0.05;
supFreq = FMAX+1;

[fData,dataV(:,1)] = fourierbounded(dataVel(:,1),infFreq,supFreq,dataDT,16384);
[fData,dataV(:,2)] = fourierbounded(dataVel(:,2),infFreq,supFreq,dataDT,16384);
[fData,dataV(:,3)] = fourierbounded(dataVel(:,3),infFreq,supFreq,dataDT,16384);

[fSimu,simuV(:,1)] = fourierbounded(simuVel(:,1),infFreq,supFreq,simuDT,16384);
[fSimu,simuV(:,2)] = fourierbounded(simuVel(:,2),infFreq,supFreq,simuDT,16384);
[fSimu,simuV(:,3)] = fourierbounded(simuVel(:,3),infFreq,supFreq,simuDT,16384);


% Finding maxima for Acc and Vel
% ------------------------------

for i=1:3
    [accMaxT(1,i),accMax(1,i)] = find_maximum(dataAcc(:,i),dataDT);
    [accMaxT(2,i),accMax(2,i)] = find_maximum(simuAcc(:,i),simuDT);
    [velMaxT(1,i),velMax(1,i)] = find_maximum(dataVel(:,i),dataDT);
    [velMaxT(2,i),velMax(2,i)] = find_maximum(simuVel(:,i),simuDT);
end

% Finding P and S arrivals and ploting them
% -----------------------------------------

% for i=1:3
%     dataRefMax = max(abs(velMax(1,i)));
%     simuRefMax = max(abs(velMax(2,i)));
%     dataPSTimes(i,:) = find_arrivals(dataVel(:,i),velMax(1,i),dataDT)
%     simuPSTimes(i,:) = find_arrivals(simuVel(:,i),velMax(2,i),simuDT)
% end

% Plotting Time Series (Velocity)
% -------------------------------

if doPlot == 1
    ylabels = ['NS';'EW';'UD'];
    for i = 1:3
        
        % Time Series
        figure(hf);
        subplot(3,12,[(i-1)*12+1 (i-1)*12+7]);
        plot(dataT(:,1),dataVel(:,i),'r');
        hold on;
        plot(simuT(:,1),simuVel(:,i),'b');
        plot(velMaxT(1,i),velMax(1,i),'ro');
        plot(velMaxT(2,i),velMax(2,i),'bo');
        hold off;
%         plot(dataPSTimes(i,:),[dataRefMax dataRefMax]*1.1,'-r.');
%         plot(simuPSTimes(i,:),[simuRefMax simuRefMax]*1.1,'-b.');
%         xlim([0 20]);
        if (i == 1)
            title(['Station ' stationName ' --- Velocity (cm/s)']);
        end
        ylabel(ylabels(i,:));
        if (i == 3)
            xlabel('Time (s)');
        end
        xlim([0 minT]);

        % Fourier Spectra
        figure(hf);
        subplot(3,12,[(i-1)*12+9 (i-1)*12+12]);
        plot(fData,dataV(:,i),'r');
        hold on;
        plot(fSimu,simuV(:,i),'b');
        hold off;
        if (i == 1)
            title(['Fourier Spectra (cm)']);
        end
        if (i == 3)
            xlabel('Frequency (Hz)');
        end
%         set(gca,'YScale','log');
    end
end

success = 1;
return;
