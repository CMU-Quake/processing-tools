
function compare_all_stations(stationsfile, obsdir, synthdir, outputfile, N)

fp = fopen(stationsfile,'r');


hf = figure('Position',[100 75 1000 700]);
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[.1 .1 .8 .8]);
% set(gcf,'PaperOrientation','portrait');
% set(gcf,'PaperPosition',[0 0 1 .6]);

for i = 1:N
    display(['Processing station ' int2str(i) ' of ' int2str(N)]);
    station_name = fscanf(fp, '%s', 1);
    station_number = fscanf(fp, '%d', 1);
    [simuvel, success] = compare_signals(obsdir, synthdir, station_name,station_number,1,hf);
        
    %compare_signals(...
    %    './data-hformat',...
    %    './synthetics_run5',...
    %    station_name,station_number,1,hf);

    if (success == 0)
        fprintf('Failed to compare station %s\n', station_name);
        continue;
    end
    
    if i == 1
        print(hf, '-dpsc2', outputfile);
    else
        print(hf, '-dpsc2', outputfile, '-append');
    end
end

fclose(fp);