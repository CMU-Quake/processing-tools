
function metrics = do_all_metrics(stationsfile,N)

% hf = figure;
hf = 0;

fp = fopen(stationsfile,'r');

for i = 1:N
    display(['Processing station ' int2str(i) ' of ' int2str(N)]);
    station = fscanf(fp, '%s', 1);
    metrics(i,:) = get_signals_metrics(...
        '../data-hformat',...
        '../synthetics/4-200-100-BKT/',...
        station,i-1,0,hf);
end

fclose(fp);

fp = fopen('temp-metrics.txt','w');

myformat = repmat('\t%f',[1,36]);
myformat = [myformat '\n'];

fprintf(fp, myformat, metrics');

fclose(fp);

