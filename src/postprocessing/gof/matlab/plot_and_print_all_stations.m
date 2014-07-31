
function plot_and_print_all_stations(stationsfile,N)

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
    station = fscanf(fp, '%s', 1);
    compare_signals(...
        '../data-hformat',...
        '../synthetics/4-200-100-BKT/',...
        station,i-1,1,hf);
    if i == 1
        print(hf, '-dpsc2', '../hola3', '-adobecset');
    else
        print(hf, '-dpsc2', '../hola3', '-append', '-adobecset');
    end
end

fclose(fp);