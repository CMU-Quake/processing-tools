
function extract_gridstation(ix,iy,stn)

% Input parameters

% Coordinates
% ix = 256;
% iy = 127;

wantPlot = 1;

% Hercules File
location = 'CI.SRN';
mypath   = '../data-planedis/';
inFile   = 'planedisplacements.1';

% Title
myTitle = strcat(location, ' :: Chino Hills');

% Main Program

% Parameters
myFile      = strcat(mypath,inFile);
fp          = fopen(myFile);
iTimeReal   = 1;
alongStrike = 271;
downDip     = 361; 
deltaT      = 0.03;
TotalTime   = 100;
theStep     = 500;

y = 0:theStep:theStep*(alongStrike-1);
x = 0:theStep:theStep*(downDip-1);

% Extract Hercules displacements

disp(' ');
disp(['   Extracting displacements at (x=' int2str(ix) ', y=' int2str(iy) ') ...']);

for iTime=1:(TotalTime/deltaT)

    dis = fread(fp, downDip*alongStrike*3,'float64');
 
    X = dis(1:3:downDip*alongStrike*3);
    Y = dis(2:3:downDip*alongStrike*3);
    Z = dis(3:3:downDip*alongStrike*3);

    disX = reshape(X,downDip,alongStrike);
    disY = reshape(Y,downDip,alongStrike);
    disZ = reshape(Z,downDip,alongStrike);    

    t(iTime) = deltaT*(iTime-1);
    
    % *********** IMPORTANT ***********
    % NOT switching the format YX-XY and -Z
    % *********************************
    
    stationX(iTime) =  disX(ix,iy);
    stationY(iTime) =  disY(ix,iy);
    stationZ(iTime) =  disZ(ix,iy);
    
    if(mod(iTime,100)==0)
        disp(int2str(iTime));
    end
    
end
fclose(fp);
sizeT = size(t);
disp('   Done...');

disp('   Printing velocities');
% td = t(1:sizeT(2));

N = length(stationX);

VstationX(1) = stationX(1)/deltaT;
VstationY(1) = stationY(1)/deltaT;
VstationZ(1) = stationZ(1)/deltaT;

VstationX(2:N) = (1/deltaT)*diff(stationX);
VstationY(2:N) = (1/deltaT)*diff(stationY);
VstationZ(2:N) = (1/deltaT)*diff(stationZ);

AstationX(1) = VstationX(1)/deltaT;
AstationY(1) = VstationY(1)/deltaT;
AstationZ(1) = VstationZ(1)/deltaT;

AstationX(2:N) = (1/deltaT)*diff(VstationX);
AstationY(2:N) = (1/deltaT)*diff(VstationY);
AstationZ(2:N) = (1/deltaT)*diff(VstationZ);

fid = fopen(['station.' num2str(stn)],'w');

fprintf(fid,'#  Time(s)         X|(m)         Y-(m)         Z.(m)       X|(m/s)       Y-(m/s)       Z.(m/s)      X|(m/s2)      Y-(m/s2)      Z.(m/s2)\n');
fprintf(fid,'%10.6f %13.6e %13.6e %13.6e %13.6e %13.6e %13.6e %13.6e %13.6e %13.6e\n', ...
    [t; stationX; stationY; stationZ; VstationX; VstationY; VstationZ; AstationX; AstationY; AstationZ]);
fclose(fid);
disp('   Done!');

if ( wantPlot == 1 )

% Plot velocities

figure('Position',[200 200 800 600]);
subplot(3,1,1)
title(myTitle)
plot( t, VstationX*100 );
ylabel('Vel_x (m/s)')

subplot(3,1,2)
plot( t, VstationY*100 );
ylabel('Vel_y (m/s)')

subplot(3,1,3)
plot( t, VstationZ*100 );
xlabel('t(s)')
ylabel('Vel_y (m/s)')

end