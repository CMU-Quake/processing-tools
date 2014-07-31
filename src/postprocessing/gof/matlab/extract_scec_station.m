
function flag = extract_scec_station(dirin,dirout,station,doplot)

[t,dis,vel,acc,flag] = read_scec_station(dirin,station,doplot);

if flag ~= 1
    return;
end

network = station(1:2);
chars = length(station);
name = station(4:chars-4);

station = [network name];

filename = [dirout '/' station '.her'];
fprintf('Writing file %s\n', filename);
fp = fopen(filename,'w');

fprintf(fp,'%s\n',['% Time(s)    '...
    'N(cm)       E(cm)      Up(cm)     '...
    'N(cm/s)     E(cm/s)    Up(cm/s)   '...
    'N(cm/s/s)   E(cm/s/s)  Up(cm/s/s)']);

dt = t(2);
samples = length(dis(:,1));

for i=1:samples
    fprintf(fp,['%7.3f\t'... 
        ' %9.4f\t %9.4f\t %9.4f\t'...
        ' %9.4f\t %9.4f\t %9.4f\t'...
        ' %9.4f\t %9.4f\t %9.4f\n'],...
        t(i), dis(i,:), vel(i,:), acc(i,:));
end

fclose(fp);

flag = 1;

return;