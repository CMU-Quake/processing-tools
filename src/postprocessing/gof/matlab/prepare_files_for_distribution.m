
function prepare_files_for_distribution(stationslistfile,outdir,M)

sfp = fopen(['../plain-data/' stationslistfile],'r');

dataRoot = '../data-hformat/';
simuRoot = '../synthetics/4-200-100-BKT/';

for j = 1:M
    
    display(['Processing station ' int2str(j) ' of ' int2str(M)]);

    stationName   = fscanf(sfp, '%s', 1);
    stationNumber = fscanf(sfp, '%d', 1);
    stationX      = fscanf(sfp, '%f', 1);
    stationY      = fscanf(sfp, '%f', 1);
    
    dataFile = [dataRoot, '/', stationName, '.her'];
    simuFile = [simuRoot, '/station.', num2str(stationNumber)];

    [N, DT, TIME, AS, VS, DS, AD, VD, DD] = get_signals_ready(dataFile,simuFile);
    
    datfp = fopen([outdir '/' int2str(stationNumber) '-' stationName '.dat'],'w');
    simfp = fopen([outdir '/' int2str(stationNumber) '-' stationName '.sim'],'w');
    
    fprintf(datfp,'%s\n',['% Time(s)    '...
        'N(cm)       E(cm)      Up(cm)     '...
        'N(cm/s)     E(cm/s)    Up(cm/s)   '...
        'N(cm/s/s)   E(cm/s/s)  Up(cm/s/s)']);

    fprintf(simfp,'%s\n',['% Time(s)    '...
        'N(cm)       E(cm)      Up(cm)     '...
        'N(cm/s)     E(cm/s)    Up(cm/s)   '...
        'N(cm/s/s)   E(cm/s/s)  Up(cm/s/s)']);
    
    for i=1:N
        fprintf(datfp,['%7.2f\t'... 
            ' %9.4f\t %9.4f\t %9.4f\t'...
            ' %9.4f\t %9.4f\t %9.4f\t'...
            ' %9.4f\t %9.4f\t %9.4f\n'],...
            TIME(i), DD(i,:), VD(i,:), AD(i,:));

        fprintf(simfp,['%7.2f\t'... 
            ' %9.4f\t %9.4f\t %9.4f\t'...
            ' %9.4f\t %9.4f\t %9.4f\t'...
            ' %9.4f\t %9.4f\t %9.4f\n'],...
            TIME(i), DS(i,:), VS(i,:), AS(i,:));
    end
    
    fclose(datfp);
    fclose(simfp);
    
end



