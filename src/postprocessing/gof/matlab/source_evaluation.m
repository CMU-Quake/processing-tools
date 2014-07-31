
function source_evaluation(key,NS)

% clear;

FMIN      = 0.15;
FMAX      = 4;
ORDERLOW  = 13;
ORDERHIGH = 3;
RP        = 0.5;


f1 = 0.025;
f2 = 4;

% NS = 12;

[pointsources,sources] = read_chenjiformat('../sourcemodels/extended-chenji/model_chino_tele');

t = 0:0.01:3-0.01;


% ------------------------------------------------------------------------

% sfp = fopen('../plain-data/close-rock-stations-5-25.txt','r');
% sfp = fopen('../plain-data/close-rock-stations-55-25.txt','r');
% sfp = fopen('../plain-data/close-rock-stations-6-6.txt','r');
% sfp = fopen('../plain-data/close-rock-stations-575-12.txt','r');

sfp = fopen(['../plain-data/close-rock-stations-' key '.txt'],'r');

for i = 1:NS
    
    display(['Processing station ' int2str(i) ' of ' int2str(NS)]);

    stationName   = fscanf(sfp, '%s', 1);
    stationNumber = fscanf(sfp, '%d', 1);
    stationX      = fscanf(sfp, '%f', 1);
    stationY      = fscanf(sfp, '%f', 1);

    dataRoot = '../data-hformat/';
    simuRoot = '../synthetics/4-200-100-BKT/';

    dataFile = [dataRoot, '/', stationName, '.her'];
    simuFile = [simuRoot, '/station.', num2str(stationNumber)];

    % Get aligned signals ready for comparisons
    % -----------------------------------------

    [N,DT,TIME,AS,VS,DS,AD,VD,DD] = get_signals_ready(dataFile,simuFile);
    
    % Compute Fourier transforms
    % --------------------------

    for j = 1:sources
        slipfunction = chenji_slipfunction(pointsources(j,:),DT,3,0);
%         cornerlow = FMAX / ( (1/DT)/2 );
%         [bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');
%         slipfunction(:,2) = filter(bl,al,slipfunction(:,2));
        [f,fs(:,j)] = fourierbounded(slipfunction(:,2),f1,f2,DT,8192);
    end
    
    for j = 1:3
        [FREQ,fVS(:,j)] = fourierbounded(VS(:,j),f1,f2,DT,8192);
        [FREQ,fVD(:,j)] = fourierbounded(VD(:,j),f1,f2,DT,8192);
    end

    smoother = 15;

    for j = 1:3
        fVS(:,j) = smooth_spectra(fVS(:,j),smoother);
        fVD(:,j) = smooth_spectra(fVD(:,j),smoother);
    end

    for j = 1:3
        for k = 1:sources
            TRF(:,k,j) = fVS(:,j)./fs(:,k);
            NEW(:,k,j) = fVD(:,j)./TRF(:,k,j);
        end
        THENEW(:,i,j) = max(NEW(:,:,j),[],2);
    end
        
end

fclose(sfp);

figure; 

for i = 1:3
    subplot(3,1,i)
    plot(FREQ,mean(THENEW(:,:,i),2))
    hold on
%     plot(FREQ,max(THENEW(:,:,i),[],2),'--')
%     plot(FREQ,min(THENEW(:,:,i),[],2),'--')
    plot(FREQ,max(fs,[],2),'r')
    plot(FREQ,fs,'-.k')
    set(gca,'TickDir','out');
    set(gca,'TickLength',[.01 0])
end
