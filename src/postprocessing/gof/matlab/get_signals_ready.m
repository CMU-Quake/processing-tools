
function [N, DT, TIME, AS, VS, DS, AD, VD, DD] = get_signals_ready(dataFile,simuFile)

ROTANGLE  = 39.9;
FMIN      = 0.15;
FMAX      = 4;
ORDERLOW  = 9;
ORDERHIGH = 3;
RP        = 0.5;

% Loading data signals
% --------------------

fp = fopen(dataFile,'r');
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
simuDis(:,2) = temp(:,1).*(cos(radAngle)) + temp(:,2).*(sin(radAngle));
simuDis(:,3) = temp(:,3).*(-1);

temp = simuVel;
simuVel(:,1) = temp(:,1).*(cos(radAngle)) - temp(:,2).*(sin(radAngle));
simuVel(:,2) = temp(:,1).*(cos(radAngle)) + temp(:,2).*(sin(radAngle));
simuVel(:,3) = temp(:,3).*(-1);

temp = simuAcc;
simuAcc(:,1) = temp(:,1).*(cos(radAngle)) - temp(:,2).*(sin(radAngle));
simuAcc(:,2) = temp(:,1).*(cos(radAngle)) + temp(:,2).*(sin(radAngle));
simuAcc(:,3) = temp(:,3).*(-1);

% Filtering synthetics according to processing of data
% ----------------------------------------------------

cornerlow = FMAX / ( (1/simuDT)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

cornerhigh = FMIN / ( (1/simuDT)/2 );
[bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% Highpass

for i =1:3
    simuVel(:,i) = filter(bh,ah,simuVel(:,i));
end

% Lowpass

for i=1:3
    simuAcc(:,i) = filter(bl,al,simuAcc(:,i));
    simuVel(:,i) = filter(bl,al,simuVel(:,i));
    simuDis(:,i) = filter(bl,al,simuDis(:,i));
end

% Filtering data according to processing of data
% ----------------------------------------------------

cornerlow = FMAX / ( (1/dataDT)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

% Lowpass

for i=1:3
    dataAcc(:,i) = filter(bl,al,dataAcc(:,i));
    dataVel(:,i) = filter(bl,al,dataVel(:,i));
    dataDis(:,i) = filter(bl,al,dataDis(:,i));
end

% Find common lenght
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

% Apply common DT to signals
% --------------------------

DT   = 0.04; % <-------- XXXXXXXXXXXXXXXXXXX

TIME = 0:DT:minT-DT;
N    = length(TIME);

TIME = TIME';

for i=1:3

    AS(:,i) = interp1(simuT(:,1), simuAcc(:,i), TIME);
    VS(:,i) = interp1(simuT(:,1), simuVel(:,i), TIME);
    DS(:,i) = interp1(simuT(:,1), simuDis(:,i), TIME);

    AD(:,i) = interp1(dataT(:,1), dataAcc(:,i), TIME);
    VD(:,i) = interp1(dataT(:,1), dataVel(:,i), TIME);
    DD(:,i) = interp1(dataT(:,1), dataDis(:,i), TIME);

end

return;
