
function [t,dis,vel,acc,flag] = read_scec_station(scecdir,stationname,doplot)

DT        = 0.025;
FMIN      = 0.15;
FMAX      = 1;
ORDERLOW  = 9;
ORDERHIGH = 3;
RP        = 0.5;
RAMP      = 0.05;
EQTIME    = [4; 9; 42.97];
% Point source BUFTIME
%BUFFER    = -0.875; %1.21; % seconds before the earthquake
% Extended source BUFTIME
BUFFER    = -0.984250; %1.21; % seconds before the earthquake
SIMTIME   = 100;

flag = 0;
t = 0; dis = 0; vel = 0; acc = 0;

% Generate the three filenames
% ----------------------------

event = '15481673';
chanN = ['N';'E';'Z'];
chan1 = ['2';'3';'1'];
chan4 = ['5';'6';'4'];
format  = 'ascii';

last = length(stationname);
last = stationname(last);
stationname = stationname(1:length(stationname)-1);

if last == 'N'
    chan = chanN;
elseif last == '1'
    chan = chan1;
elseif last == '4'
    chan = chan4;
else
    display(['There are channel problems with station ' stationname]);
    flag = -1;
    return;
end

filenames = ...
    [ scecdir, event,'.',stationname,chan(1),'.',format ; ...
      scecdir, event,'.',stationname,chan(2),'.',format ; ...
      scecdir, event,'.',stationname,chan(3),'.',format ];

fprintf('Opening files:\n');
disp(filenames);

fp1 = fopen(filenames(1,:),'r');
fp2 = fopen(filenames(2,:),'r');
fp3 = fopen(filenames(3,:),'r');

if (fp1 < 0) | (fp2 < 0) | (fp3 < 0)
    display(['Error opening files ' stationname]);
    flag = -2;
    return;
end

[flag1,triggertime1,samples1,dt1,signal1] = read_scec_channel(fp1);
[flag2,triggertime2,samples2,dt2,signal2] = read_scec_channel(fp2);
[flag3,triggertime3,samples3,dt3,signal3] = read_scec_channel(fp3);

% Set the number of samples
% -------------------------

samples  = min([samples1 samples2 samples3]);

% Set the delta t
% ---------------

if (dt1 ~= dt2) | (dt1 ~= dt3) | (dt2 ~= dt3)
    display('Different dts');
    flag = -3;
    return;
end

dt = dt1;

% Assign signals to the acc matrix
% --------------------------------

acc = zeros(samples,3);

acc(:,1) = signal1(1:samples,1);
acc(:,2) = signal2(1:samples,1);
acc(:,3) = signal3(1:samples,1);

% Filter before integrating
% -------------------------

cornerlow = FMAX / ( (1/dt)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

% cornerhigh = FMIN / ( (1/dt)/2 );
% [bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% acc(:,1) = filter(bh,ah,acc(:,1));
% acc(:,2) = filter(bh,ah,acc(:,2));
% acc(:,3) = filter(bh,ah,acc(:,3));

% Correct baseline
% ----------------

acc(:,1) = correct_baseline(acc(:,1));
acc(:,2) = correct_baseline(acc(:,2));
acc(:,3) = correct_baseline(acc(:,3));

% Adjust to Quake Time
% --------------------

[samples1,acc1] = adjust_to_quaketime(...
    SIMTIME,EQTIME,BUFFER,triggertime1,acc(:,1),samples,dt);
[samples2,acc2] = adjust_to_quaketime(...
    SIMTIME,EQTIME,BUFFER,triggertime2,acc(:,2),samples,dt);
[samples3,acc3] = adjust_to_quaketime(...
    SIMTIME,EQTIME,BUFFER,triggertime3,acc(:,3),samples,dt);

clear acc samples;

samples  = min([samples1 samples2 samples3]);

acc(1:samples,1) = acc1(1:samples,1);
acc(1:samples,2) = acc2(1:samples,1);
acc(1:samples,3) = acc3(1:samples,1);

% Taper signals
% -------------

acc(:,1) = taper_signal(acc(:,1), samples, dt);
acc(:,2) = taper_signal(acc(:,2), samples, dt);
acc(:,3) = taper_signal(acc(:,3), samples, dt);

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

    acc = temp;

    dt = DT;
    samples = unisamples;
end

% f1 = FMIN-RAMP;
% f2 = FMIN;
% 
% f3 = FMAX;
% f4 = FMAX+RAMP;
% 
% f3 = FMAX+10;
% f4 = FMAX+10+RAMP;
% 
% acc(:,1) = ormsby(acc(:,1),dt,f1,f2,f3,f4);
% acc(:,2) = ormsby(acc(:,2),dt,f1,f2,f3,f4);
% acc(:,3) = ormsby(acc(:,3),dt,f1,f2,f3,f4);

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

fclose(fp1);
fclose(fp2);
fclose(fp3);

flag = 1;

return;
