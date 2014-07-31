
numsta = 341;
numrun = 6;

vrunstr = {'run1', 'run2', 'run3', 'run4', 'run5', 'run6'};
stpdir = '/home/patrick/data/lahabra/15481673/';

% Convert observed into Hercules format
%for i=5:6
%    obsdir = sprintf('/home/patrick/data/lahabra/data-hformat_%s/', vrunstr{i});
%    synthdir = sprintf('/home/patrick/data/lahabra/outputfiles_%s/stations/', vrunstr{i});
%    
%    %run('herc_plot_station');
%    process_all_scec_stations(stpdir, obsdir, ...
%        '../stations/stations_observed.txt', numsta);
%end

% Run comparison
%for i=1:numrun
%    obsdir = sprintf('/home/patrick/data/lahabra/data-hformat_%s/', vrunstr{i});
%    synthdir = sprintf('/home/patrick/data/lahabra/outputfiles_%s/stations/', vrunstr{i});
%    comparefile = sprintf('./all-valid-signals-%s', vrunstr{i});
%
%    compare_all_stations('../stations/stations_compare.txt' , ...
%        obsdir, synthdir, comparefile, numsta);
%end

% Score stations
for i=1:6
    obsdir = sprintf('/home/patrick/data/lahabra/data-hformat_%s/', vrunstr{i});
    synthdir = sprintf('/home/patrick/data/lahabra/outputfiles_%s/stations/', vrunstr{i});
    comparefile = sprintf('./compare-%s', vrunstr{i});

    scorefile = sprintf('%s_scores.txt', vrunstr{i});
    myscorefile = sprintf('%s_myscores.txt', vrunstr{i});
    metricfile = sprintf('%s_metrics.txt', vrunstr{i});
    
    score_all_stations('../stations/stations_score.txt',scorefile, ...
        myscorefile, metricfile, obsdir, synthdir, comparefile, numsta);
end
