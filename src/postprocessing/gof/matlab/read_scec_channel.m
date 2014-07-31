
function [flag,tstamp,samples,dt,signal] = read_scec_channel(fp);

fscanf(fp, '%s', 4);
fscanf(fp, '%c',11);

temp_string = fscanf(fp, '%c',1);
if temp_string ~= ','
    display('Error before time stamp');
    flag = -1;
    return;
end

temp_string = fscanf(fp, '%s',1);
tstamp = strread(temp_string, '%f', 'delimiter', ':');

fscanf(fp, '%f', 1);

dt = fscanf(fp, '%f', 1);

signal = fscanf(fp, '%f', inf);

samples = max(size(signal));

flag = 1;

return;