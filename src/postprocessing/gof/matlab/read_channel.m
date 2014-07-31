
function [flag,dir,azimuth,samples,dt,signal] = read_channel(fp)

FACTOR = 981;

% Lines 1--6: Irrelevant
% ----------------------

for i = 1:6
    fgetl(fp);
end

% Line 7: Channel component
% -------------------------

fscanf(fp, '%s', 1);
channel = fscanf(fp, '%i', 1);
fscanf(fp, '%c', 1);
dir_string = fscanf(fp, '%s', 1);
fgetl(fp);

dir_string = strtrim(dir_string);
dir_string = lower(dir_string);
strlength = length(dir_string);

if (strlength == 2) & (dir_string == 'up') 
    factor = FACTOR;
    azimuth = 500;
    dir = 3;
elseif (strlength == 4) & (dir_string == 'down')
    factor = -FACTOR;
    azimuth = 500;
    dir = 3;
else
    azimuth = str2num(dir_string);
    dir = 0;
end

if azimuth == 360
    azimuth = 0;
end

if azimuth == 180
    azimuth = 0;
    factor = -FACTOR;
end

if azimuth == -270
    azimuth = 90;
end

if (azimuth == 270) | (azimuth == -90)
    azimuth = 90;
    factor = -FACTOR;
end

if dir == 0
    if (azimuth == 0)
        dir = 1;
    elseif (azimuth == 90)
        dir = 2;
    else
        dir = 4;
    end
    factor = FACTOR;
end

% Lines 8--10: Irrelevant
% -----------------------

for i = 1:3
    fgetl(fp);
end

% Line 11: Number of points, length, and rate
% -------------------------------------------

fscanf(fp, '%s', 4);
samples = fscanf(fp, '%i', 1);

fscanf(fp, '%s', 3);
lenght = fscanf(fp, '%f', 1);

fscanf(fp, '%s', 2);
rate = fscanf(fp, '%i', 1);
fgetl(fp);

% Lines 12--27: Irrelevant
% -----------------------

for i = 1:16
    fgetl(fp);
end

% Lines 28: Check
% ---------------

temp = fscanf(fp, '%i', 1);
if samples ~= temp
    display('Error in the number of samples');
    flag = -1;
    return;
end

fscanf(fp, '%s', 3);
temp = fscanf(fp, '%i', 1);
if rate ~= temp
    display('Error in the samples rate');
    flag = -1;
    return;
end

fgetl(fp);

% Set the Time DT
% ---------------

dt = 1/rate;

% Read signal
% -----------

signal = fscanf(fp, '%f', samples);
signal = signal*factor;

fgetl(fp);
fgetl(fp);

flag = 0;

return;