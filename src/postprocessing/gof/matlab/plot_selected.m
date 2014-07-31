
function plot_selected(stationName,stationNumber,tlim)

% Set files locations and names
% -----------------------------

dataRoot = '../data-hformat/';
simuRoot = '../synthetics/4-200-100-BKT/';

dataFile = [dataRoot, '/', stationName, '.her'];
simuFile = [simuRoot, '/station.', num2str(stationNumber)];

% Get aligned signals ready for comparisons
% -----------------------------------------

[N, DT, TIME, AS, VS, DS, AD, VD, DD] = ...
    get_signals_ready(dataFile,simuFile);

MAXT = TIME(N);

% Get full signal coefficients
% ----------------------------

f1 = 0.05;
f2 = 4;

% Compute peaks, extreme values, and their times
% ----------------------------------------------

% Extremes are same as peaks (or maxima) but preserve their signs

[tdS,tvS,taS,mdS,mvS,maS,xdS,xvS,xaS] = compute_peaks(DS,VS,AS,DT,N);
[tdD,tvD,taD,mdD,mvD,maD,xdD,xvD,xaD] = compute_peaks(DD,VD,AD,DT,N);
mv = max(mvS,mvD);

% Compute Hilbert transforms
% --------------------------

HVS = abs(hilbert(VS));
HVD = abs(hilbert(VD));

for i = 1:3
    HVS(:,i) = smooth(HVS(:,i),51);
    HVD(:,i) = smooth(HVD(:,i),51);
end

% for n = 1:N
%     for i = 1:3
%         HS(n,i) = s_function(HVS(n,i),HVD(n,i));
%     end
% end
% 
% HS = mean(HS,1)

% Compute peaks, extreme values, and their times
% ----------------------------------------------

ptS = p_time(mvS,VS,DT,N);
ptD = p_time(mvD,VD,DT,N);

% Compute Energy
% --------------

enS = compute_energy(VS,DT,N);
enD = compute_energy(VD,DT,N);

for i = 1:3
    enxS(i)   = enS(N,i);
    enxD(i)   = enD(N,i);
    ennS(:,i) = enS(:,i)./enxS(i);
    ennD(:,i) = enD(:,i)./enxD(i);
    FE(:,i)   = abs(ennS(:,i)-ennD(:,i));
end

maxE = max(enS(N,:),enD(N,:));

% Compute response spectra
% ------------------------

[PERIOD,NP,rsS] = compute_response_spectra_2(AS,DT);
[PERIOD,NP,rsD] = compute_response_spectra_2(AD,DT);

for p = 1:NP
    for i = 1:3
        RSS(p,i) = s_function(rsS(p,i),rsD(p,i));
    end
end

% Compute Fourier transforms
% --------------------------

for i = 1:3
    [FREQ,fVS(:,i)] = fourierbounded(VS(:,i),f1,f2,DT,8192);
    [FREQ,fVD(:,i)] = fourierbounded(VD(:,i),f1,f2,DT,8192);
    [FREQ,fAS(:,i)] = fourierbounded(AS(:,i),f1,f2,DT,8192);
    [FREQ,fAD(:,i)] = fourierbounded(AD(:,i),f1,f2,DT,8192);
end

fN = length(FREQ);

smoother = 10;

for i = 1:3
    fVS(:,i) = smooth_spectra(fVS(:,i),smoother);
    fVD(:,i) = smooth_spectra(fVD(:,i),smoother);
    fAS(:,i) = smooth_spectra(fAS(:,i),smoother);
    fAD(:,i) = smooth_spectra(fAD(:,i),smoother);
end

% Compute durations
% -----------------

[durS, t1S, t2S] = compute_duration(enS,VS,DT,N);
[durD, t1D, t2D] = compute_duration(enD,VD,DT,N);

% Plot
% ----

hf = figure('Position',[75 75 1300 700]);
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[0 0.15 1 0.7]);

C = 20;
R = 12;

for i = 1:3
    subplot(R,C,[(i-1)*R/3*C+1 (i-1)*R/3*C+C+8])
    plot(TIME,VD(:,i),'r');
    hold on;
    plot(TIME,VS(:,i),'b');
    % plot([ptD(1) ptD(1)], [-1.1*mv(1) 1.1*mv(1)],'r');
    % plot([ptS(1) ptS(1)], [-1.1*mv(1) 1.1*mv(1)],'b');
    xlim(tlim);
    ylim([-1.1*mv(i) 1.1*mv(i)]);
    set(gca,'XTickLabel','');
    set(gca,'TickDir','out');
    set(gca,'XTick',0:10:100);

    subplot(R,C,[(i-1)*R/3*C+C*2+1 (i-1)*R/3*C+C*2+8])
    plot(TIME,HVD(:,i),'r');
    hold on;
    plot(TIME,HVS(:,i),'b');
    % plot([ptD(1) ptD(1)], [0 mv(1)],'r');
    % plot([ptS(1) ptS(1)], [0 mv(1)],'b');
    xlim(tlim);
    hm = max(max(HVS(:,i)),max(HVD(:,i)));
    ylim([0 1.1*hm]);
    set(gca,'TickDir','out');
    set(gca,'XTick',0:10:100);
    set(gca,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '80' '90' '100'});

    subplot(R,C,[(i-1)*R/3*C+10 (i-1)*R/3*C+C*2+12])
    plot(TIME,enD(:,i),'r');
    hold on;
    plot(TIME,enS(:,i),'b');
%     plot([t1D(i) t1D(i)], [0 1],'r');
%     plot([t1S(i) t1S(i)], [0 1],'b');
%     plot([t2D(i) t2D(i)], [0 1],'r');
%     plot([t2S(i) t2S(i)], [0 1],'b');
    xlim(tlim);
    ylim([0 maxE(i)])
    set(gca,'TickDir','out');
    set(gca,'XTick',0:10:100);
    set(gca,'XTickLabel',{'0' '' '20' '' '40' '' '60' '' '80' '' '100'});

    subplot(R,C,[(i-1)*R/3*C+14 (i-1)*R/3*C+C*2+16])
    plot(FREQ,fVD(:,i),'r');
    hold on;
    plot(FREQ,fVS(:,i),'b');
    xlim([0 f2]);
    set(gca,'TickDir','out');
    set(gca,'XTick',0:1:4);

    subplot(R,C,[(i-1)*R/3*C+18 (i-1)*R/3*C+C*2+20])
    semilogx(PERIOD,rsD(:,i),'r');
    hold on;
    semilogx(PERIOD,rsS(:,i),'b');
    xlim([0 10]);
    set(gca,'TickDir','out');
    set(gca,'XTick',[.1:.1:1 2:1:10]);
    set(gca,'XTickLabel',{'0.1' '' '' '' '' '' '' '' '' '1' '' '' '' '' '' '' '' '' '10'});
end

print(hf, '-dpsc', ['../figures/' stationName '.ps']);

return;

% =========================================================================


% Compute Hilbert transforms
% --------------------------

% HVS = abs(hilbert(VS));
% HVD = abs(hilbert(VD));
% 
% for i = 1:3
%     HVS(:,i) = smooth(HVS(:,i),101);
%     HVD(:,i) = smooth(HVD(:,i),101);
% end
% 
% for n = 1:N
%     for i = 1:3
%         HS(n,i) = s_function(HVS(n,i),HVD(n,i));
%     end
% end
% 
% HS = mean(HS,1)

% figure;
% for i = 1:3
%     subplot(3,1,i)
%     plot(TIME,HVD(:,i),'r');
%     title(['Band ' num2str(f1) '---' num2str(f2) ' S: ' num2str(HS(i))]);
%     hold on;
%     plot(TIME,HVS(:,i),'b');
% end
