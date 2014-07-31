
function flag = extract_smc_station(dirin,dirout,station,doplot)

[t,dis,vel,acc,flag] = read_smc_station([dirin '/' station '.RAW'],doplot);

if flag ~= 1
    return;
end

fp = fopen([dirout '/' station '.her'],'w');

fprintf(fp,'%s\n',['% Time(s)    '...
    'N(cm)       E(cm)      Up(cm)     '...
    'N(cm/s)     E(cm/s)    Up(cm/s)   '...
    'N(cm/s/s)   E(cm/s/s)  Up(cm/s/s)']);

dt = t(2);
samples = length(dis(:,1));

for i=1:samples
    fprintf(fp,['%7.2f\t'... 
        ' %9.4f\t %9.4f\t %9.4f\t'...
        ' %9.4f\t %9.4f\t %9.4f\t'...
        ' %9.4f\t %9.4f\t %9.4f\n'],...
        t(i), dis(i,:), vel(i,:), acc(i,:));
end

fclose(fp);

flag = 1;

return;