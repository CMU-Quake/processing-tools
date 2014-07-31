
function [t,dis,vel,acc,flag] = read_smc_station(filename, doplot)

DT        = 0.01;
FMIN      = 0.15;
FMAX      = 4;
ORDERLOW  = 13;
ORDERHIGH = 3;
RP        = 0.5;
RAMP      = 0.05;
EQTIME    = [18; 42; 15.71];
BUFFER    = 0.5; %1.21; % seconds before the earthquake
SIMTIME   = 100;

flag = 0;
t = 0; dis = 0; vel = 0; acc = 0;

% Open file and check for error
% -----------------------------

fp = fopen(filename,'r');

if fp < 0
    display(['Error opening file ' filename]);
    flag = -1;
    return;
end

% Line 1--3: Irrelevant
% ---------------------

fgetl(fp);
fgetl(fp);
fgetl(fp);

% Line 4: Trigger time and time-zone
% ----------------------------------

fscanf(fp, '%s', 4);
temp_string = fscanf(fp, '%s',1);
triggertime = strread(temp_string, '%f', 'delimiter', ':');
timezone = fscanf(fp, '%s', 1);
if timezone ~= 'UTC'
    display(['Timezone in file ' filename ' is not UTC']);
    flag = -2;
    return;
end
fgetl(fp);

% Line 5: Station, Coordinates and Channels
% -----------------------------------------

fscanf(fp, '%s', 2);
station_number = fscanf(fp, '%s', 1);

% Get latitude

latitude = fscanf(fp, '%f', 1);
tempchar = fscanf(fp, '%c', 1);
if tempchar ~= 'N' 
    if tempchar == 'S'
        latitude = -latitude;
    else
        display([filename ' has problems reading latitude']);
        flag = -2.1;
        return;
    end
end

% Get longitude

fscanf(fp, '%c', 1);
longitude = fscanf(fp, '%f', 1);
tempchar = fscanf(fp, '%c', 1);
if tempchar ~= 'E'
    if tempchar == 'W'
        longitude = -longitude;
    else
        display([filename ' has problems reading longitude']);
        flag = -2.2;
        return;
    end
end

% Get the number of channels

fscanf(fp, '%c', 22);
tempchar = fscanf(fp, '%c', 1);

if tempchar ~= '('
    display([filename ' has problems before channels']);
    flag = -2.3;
    return;
end

channels = fscanf(fp, '%i', 1);

% Multichannel flag

if channels ~= 3
    display([filename ' has problems identifying channels ']);
    flag = -3;
    return;
end

% Rewind to read channel
% ----------------------

frewind(fp);

% Read channels
% -------------

[flag1,dir1,azimuth1,samples1,dt1,signal1] = read_channel(fp);
[flag2,dir2,azimuth2,samples2,dt2,signal2] = read_channel(fp);
[flag3,dir3,azimuth3,samples3,dt3,signal3] = read_channel(fp);

% Check for errors
% ----------------

if (flag1 < 0) | (flag2 < 0) | (flag3 < 0)
%     display('There are errors with the sation');
%     flag1, flag2, flag3
    flag = -4;
    return;
end

if (dir1 ~= 4) & (dir2 ~= 4) & (dir3 ~= 4)
    if (dir1 == dir2) | (dir1 == dir3) | (dir2 == dir3)
        display(['Repeated directions']);
%         dir1, dir2, dir3
        flag = -5;
        return;
    end
end

if (dt1 ~= dt2) | (dt1 ~= dt3) | (dt2 ~= dt3)
%     display(['Different dt']);
    dt1, dt2, dt3
    flag = -6;
    return;
end

% Set the number of samples
% -------------------------

samples  = min([samples1 samples2 samples3]);
dt = dt1;

% Assign signals to the acc matrix
% --------------------------------

acc = zeros(samples,3);
azimuth = zeros(1,2);

if dir1 == 1
    azimuth(1) = azimuth1;
    acc(:,1) = signal1(1:samples,1);
    if dir2 == 2
        azimuth(2) = azimuth2;
        acc(:,2) = signal2(1:samples,1);
        acc(:,3) = signal3(1:samples,1);
    else
        azimuth(2) = azimuth3;
        acc(:,2) = signal3(1:samples,1);
        acc(:,3) = signal2(1:samples,1);
    end
elseif dir1 == 2
    acc(:,2) = signal1(1:samples,1);
    azimuth(2) = azimuth1;
    if dir2 == 1
        azimuth(1) = azimuth2;
        acc(:,1) = signal2(1:samples,1);
        acc(:,3) = signal3(1:samples,1);
    else
        azimuth(1) = azimuth3;
        acc(:,1) = signal3(1:samples,1);
        acc(:,3) = signal2(1:samples,1);
    end
elseif dir1 == 3
    acc(:,3) = signal1(1:samples,1);
    if dir2 == 1
        azimuth(1) = azimuth2;
        azimuth(2) = azimuth3;
        acc(:,1) = signal2(1:samples,1);
        acc(:,2) = signal3(1:samples,1);
    else
        azimuth(1) = azimuth3;
        azimuth(2) = azimuth2;
        acc(:,1) = signal3(1:samples,1);
        acc(:,2) = signal2(1:samples,1);
    end
elseif (dir1 == 4) | (dir2 == 4) | (dir3 == 4)
%     display('Entering fix rotation')
    azimuths = [azimuth1, azimuth2, azimuth3];
    dirs = [dir1, dir2, dir3];
    acc(:,1) = signal1(1:samples,1);
    acc(:,2) = signal2(1:samples,1);
    acc(:,3) = signal3(1:samples,1);
    [azimuth,acc] = fix_smc_rotation(dirs,azimuths,samples,acc);
else
    display('We have bigger problems');
    flag = -7;
    return;
end

% Sanity check
% if dir1 == 4 | dir2 == 4 | dir3 == 4
if (azimuth(1) ~= 0) | (azimuth(2) ~= 90)
    display('Rotation failed')
    flag = -8;
    return;
end

% Filter before integrating
% -------------------------

% f1 = FMIN-RAMP;
% f2 = FMIN;

% f3 = FMAX;
% f4 = FMAX+RAMP;

% f3 = FMAX+10;
% f4 = FMAX+10+RAMP;

% acc(:,1) = ormsby(acc(:,1),dt,f1,f2,f3,f4);
% acc(:,2) = ormsby(acc(:,2),dt,f1,f2,f3,f4);
% acc(:,3) = ormsby(acc(:,3),dt,f1,f2,f3,f4);

% corner = FMAX / ( (1/dt)/2 );
% [b,a] = butter(9,corner,'low');

% corners = [FMIN FMAX] / ( (1/dt)/2 );
% [b,a] = butter(POLES,corners);

cornerlow = FMAX / ( (1/dt)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

cornerhigh = FMIN / ( (1/dt)/2 );
[bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% corner = FMAX / ( (1/dt)/2 );
% [b,a] = cheby1(9,RP,corner,'low');
% 
% acc(:,1) = filter(bl,al,acc(:,1));
% acc(:,2) = filter(bl,al,acc(:,2));
% acc(:,3) = filter(bl,al,acc(:,3));
% 
% corner = FMIN / ( (1/dt)/2 );
% [b,a] = cheby1(3,RP,corner,'high');

% acc(:,1) = filter(bh,ah,acc(:,1));
% acc(:,2) = filter(bh,ah,acc(:,2));
% acc(:,3) = filter(bh,ah,acc(:,3));

% Correct baseline
% ----------------

% acc(:,1) = correct_baseline(acc(:,1));
% acc(:,2) = correct_baseline(acc(:,2));
% acc(:,3) = correct_baseline(acc(:,3));

% Taper signals
% -------------

% acc(:,1) = taper_signal(acc(:,1), samples, dt);
% acc(:,2) = taper_signal(acc(:,2), samples, dt);
% acc(:,3) = taper_signal(acc(:,3), samples, dt);

% Adjust to earthquake time
% -------------------------

% The buffer is to make sure we allow the slipfunction
% to rise smoothly from zero to one, assuming that the
% earthquake time was set at the 50% of the rise time.

time_diff    = EQTIME - [0; 0; BUFFER] - triggertime;
seconds_diff = time_diff.*[3600; 60; 1];
seconds_diff = sum(seconds_diff);
temp = fix(seconds_diff/dt);
seconds_diff = temp*dt;

newsamples = SIMTIME/dt;
sig = acc;
% acc = zeros(newsamples,3);

if seconds_diff > 0
    
    % Station started recording earlier than the earthquake time
    % minus the buffer time and the signal must be cut by the difference
    
    samples_to_cut = fix(seconds_diff/dt);
    remaining_samples = samples - samples_to_cut;
    
    if remaining_samples < newsamples
        % the signal is shorter that the simulation
        newsamples = remaining_samples;
        acc = zeros(newsamples,3);
        acc(1:remaining_samples,:) ...
            = sig(samples_to_cut+1:samples,:);
    else
        % the signal is longer than the simulation
        acc = zeros(newsamples,3);
        acc(1:newsamples,:) ...
            = sig(samples_to_cut+1:samples_to_cut+newsamples,:);
    end
    
else
    
    % Station started later than the earthquake time minus the buffer time
    % and the signal must be padded with zeros in front of it
    
    padding_samples = -fix(seconds_diff/dt);
    new_length = padding_samples + samples;
    
    if newsamples > new_length
        % the signal is shorter than the simulation
        newsamples = new_length;
        acc = zeros(newsamples,3);
        acc(padding_samples+1:new_length,:) ...
            = sig(:,:);
    else
        % the signal is now longer than the simulation
        acc = zeros(newsamples,3);
        end_sample = newsamples-(padding_samples + samples - newsamples);
        acc(padding_samples+1:newsamples,:) ...
            = sig(1:newsamples-padding_samples,:);
    end
end

% Update samples

samples = newsamples;

% Adjust to universal DT
% ----------------------

if dt ~= DT
    datatime = 0:dt:(samples-1)*dt;
    datatime = datatime';
    datasimtime = (samples-1)*dt;

    if datasimtime < SIMTIME
        unisamples = fix(datasimtime/DT);
    else
        unisamples = SIMTIME/DT;
    end
    
    unitime = 0:DT:(unisamples-1)*DT;
    unitime = unitime';

    temp = zeros(unisamples,3);

    temp(:,1) = interp1(datatime,acc(:,1),unitime);
    temp(:,2) = interp1(datatime,acc(:,2),unitime);
    temp(:,3) = interp1(datatime,acc(:,3),unitime);
    
    temp(unisamples,:) = acc(samples,:);

%     if doplot == 1
%         figure;
%         subplot(3,1,1), hold on;
%         plot(datatime,acc(:,1));
%         plot(unitime,temp(:,1),'r');
%         subplot(3,1,2), hold on;
%         plot(datatime,acc(:,2));
%         plot(unitime,temp(:,2),'r');
%         subplot(3,1,3), hold on;
%         plot(datatime,acc(:,3));
%         plot(unitime,temp(:,3),'r');
%     end

    acc = temp;

    dt = DT;
    samples = unisamples;
end

% Renew Filters
% -------------

cornerlow = FMAX / ( (1/dt)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

cornerhigh = FMIN / ( (1/dt)/2 );
[bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% Compute velocities
% ------------------

vel = zeros(samples,3);

vel(:,1) = integrate_signal(acc(:,1),dt);
vel(:,2) = integrate_signal(acc(:,2),dt);
vel(:,3) = integrate_signal(acc(:,3),dt);

% Filter before integrating
% -------------------------

vel(:,1) = filter(bh,ah,vel(:,1));
vel(:,2) = filter(bh,ah,vel(:,2));
vel(:,3) = filter(bh,ah,vel(:,3));

% vel(:,1) = ormsby(vel(:,1),dt,f1,f2,f3,f4);
% vel(:,2) = ormsby(vel(:,2),dt,f1,f2,f3,f4);
% vel(:,3) = ormsby(vel(:,3),dt,f1,f2,f3,f4);

% Compute displacements
% ---------------------

dis = zeros(samples,3);

dis(:,1) = integrate_signal(vel(:,1),dt);
dis(:,2) = integrate_signal(vel(:,2),dt);
dis(:,3) = integrate_signal(vel(:,3),dt);

% Filter
% ------

dis(:,1) = filter(bh,ah,dis(:,1));
dis(:,2) = filter(bh,ah,dis(:,2));
dis(:,3) = filter(bh,ah,dis(:,3));

% dis(:,1) = ormsby(dis(:,1),dt,f1,f2,f3,f4);
% dis(:,2) = ormsby(dis(:,2),dt,f1,f2,f3,f4);
% dis(:,3) = ormsby(dis(:,3),dt,f1,f2,f3,f4);

% Lowpass filters
acc(:,1) = filter(bl,al,acc(:,1));
acc(:,2) = filter(bl,al,acc(:,2));
acc(:,3) = filter(bl,al,acc(:,3));

vel(:,1) = filter(bl,al,vel(:,1));
vel(:,2) = filter(bl,al,vel(:,2));
vel(:,3) = filter(bl,al,vel(:,3));

dis(:,1) = filter(bl,al,dis(:,1));
dis(:,2) = filter(bl,al,dis(:,2));
dis(:,3) = filter(bl,al,dis(:,3));

% Plot
% ----

t = 0:dt:dt*(samples-1);

if doplot == 1

    figure;
    subplot(3,3,1)
    plot(t,acc(:,1));
    subplot(3,3,2)
    plot(t,acc(:,2));
    subplot(3,3,3)
    plot(t,acc(:,3));

    subplot(3,3,4)
    plot(t,vel(:,1));
    subplot(3,3,5)
    plot(t,vel(:,2));
    subplot(3,3,6)
    plot(t,vel(:,3));

    subplot(3,3,7)
    plot(t,dis(:,1));
    subplot(3,3,8)
    plot(t,dis(:,2));
    subplot(3,3,9)
    plot(t,dis(:,3));
    
    [f,A(:,1)] = fourierbounded(acc(:,1),FMIN,FMAX+1,dt,samples);
    [f,A(:,2)] = fourierbounded(acc(:,2),FMIN,FMAX+1,dt,samples);
    [f,A(:,3)] = fourierbounded(acc(:,3),FMIN,FMAX+1,dt,samples);

    [f,V(:,1)] = fourierbounded(vel(:,1),FMIN,FMAX+1,dt,samples);
    [f,V(:,2)] = fourierbounded(vel(:,2),FMIN,FMAX+1,dt,samples);
    [f,V(:,3)] = fourierbounded(vel(:,3),FMIN,FMAX+1,dt,samples);

    [f,D(:,1)] = fourierbounded(dis(:,1),FMIN,FMAX+1,dt,samples);
    [f,D(:,2)] = fourierbounded(dis(:,2),FMIN,FMAX+1,dt,samples);
    [f,D(:,3)] = fourierbounded(dis(:,3),FMIN,FMAX+1,dt,samples);

    figure;
    subplot(3,3,1)
    plot(f,A(:,1));
    subplot(3,3,2)
    plot(f,A(:,2));
    subplot(3,3,3)
    plot(f,A(:,3));

    subplot(3,3,4)
    plot(f,V(:,1));
    subplot(3,3,5)
    plot(f,V(:,2));
    subplot(3,3,6)
    plot(f,V(:,3));

    subplot(3,3,7)
    plot(f,D(:,1));
    subplot(3,3,8)
    plot(f,D(:,2));
    subplot(3,3,9)
    plot(f,D(:,3));
end

% Close and return
% ----------------

fclose(fp);

flag = 1;

return;
