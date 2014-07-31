
function [ ...
    S1, myS1, S2, myS2, ...
    B1, B2, B3, ...B4, B5, ...
    myB1, myB2, myB3, ...myB4, myB5, ...
    iS2, iB1, iB2, iB3, ...iB4, iB5, ...
    TIME, DT, AS, VS, DS, AD, VD, DD, ...
    FREQ, FVS, FVD, PERIOD, RSS, RSD, ...HVS, HVD, ...
    ptS, ptD, CR1] ...
    = compute_metrics(stationName,stationNumber,dataRoot,simuRoot)

% Set files locations and names
% -----------------------------

dataFile = [dataRoot, '/', stationName, '.her'];
simuFile = [simuRoot, '/station.', num2str(stationNumber)];

% Get aligned signals ready for comparisons
% -----------------------------------------

[N, DT, TIME, AS, VS, DS, AD, VD, DD] = ...
    get_signals_ready_new(dataFile,simuFile);

MAXT = TIME(N);

% Get full signal coefficients
% ----------------------------

f1 = 0.15;
f2 = 1;

fa = f1-0.025;
fd = f2+0.025;

[S2, myS2, iS2, FREQ, FVS, FVD, PERIOD, RSS, RSD]..., HVS, HVD] ...
    = get_metrics(MAXT, N, DT, TIME, AS, VS, DS, AD, VD, DD, fa, fd);

ptS = p_time(iS2(5,1:3),VS,DT,N);
ptD = p_time(iS2(5,4:6),VD,DT,N);

for i = 1:3
    CR1(i) = s_function(ptS(i),ptD(i));
end

% .........................................................................

% Get narrowed-band signal coefficients
% -------------------------------------

% 0.125--0.25 Hz Band
% -----------------

f1 = 0.125;
f2 = 0.25;

[fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
    filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2);

[B1,myB1,iB1] = get_metrics(MAXT, N, DT, TIME, fAS, fVS, fDS, fAD, fVD, fDD, fa, fd);

% 0.25--0.5 Hz Band
% -----------------

f1 = 0.25;
f2 = 0.5;

[fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
    filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2);

[B2,myB2,iB2] = get_metrics(MAXT, N, DT, TIME, fAS, fVS, fDS, fAD, fVD, fDD, fa, fd);

% 0.5--1 Hz Band
% -----------------

f1 = 0.5;
f2 = 1;

[fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
    filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2);

[B3,myB3,iB3] = get_metrics(MAXT, N, DT, TIME, fAS, fVS, fDS, fAD, fVD, fDD, fa, fd);

% 1--2 Hz Band
% -----------------

% f1 = 1;
% f2 = 2;
% 
% [fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
%     filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2);
% 
% [B4,myB4,iB4] = get_metrics(MAXT, N, DT, TIME, fAS, fVS, fDS, fAD, fVD, fDD, fa, fd);

% 2--4 Hz Band
% -----------------

% f1 = 2;
% f2 = 4;
% 
% [fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
%     filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2);
% 
% [B5,myB5,iB5] = get_metrics(MAXT, N, DT, TIME, fAS, fVS, fDS, fAD, fVD, fDD, fa, fd);

% Combined S1 scores
% ------------------

% S1 = (B1+B2+B3+B4+B5+S2)./6;
S1 = (B1+B2+B3+S2)./4;

% My Combination
% --------------

% myS1 = (myB1+myB2+myB3+myB4+myB5+myS2)./6;
myS1 = (myB1+myB2+myB3+myS2)./4;

return;

% =========================================================================

function [fAS, fVS, fDS, fAD, fVD, fDD, fa, fd] = ...
    filter_signals(N, DT, AS, VS, DS, AD, VD, DD, f1, f2)

fa = f1-0.025;
fb = f1+0.025;
fc = f2-0.025;
fd = f2+0.025;

fAS = zeros(N,3);
fVS = zeros(N,3);
fDS = zeros(N,3);
fAD = zeros(N,3);
fVD = zeros(N,3);
fDD = zeros(N,3);

for i = 1:3
    fAS(:,i) = ormsby(AS(:,i), DT, fa, fb, fc, fd);
    fVS(:,i) = ormsby(VS(:,i), DT, fa, fb, fc, fd);
    fDS(:,i) = ormsby(DS(:,i), DT, fa, fb, fc, fd);
    fAD(:,i) = ormsby(AD(:,i), DT, fa, fb, fc, fd);
    fVD(:,i) = ormsby(VD(:,i), DT, fa, fb, fc, fd);
    fDD(:,i) = ormsby(DD(:,i), DT, fa, fb, fc, fd);
end

return;

% =========================================================================

function [C, myC, INFO, FREQ, fVS, fVD, PERIOD, rsS, rsD, HVS, HVD] ...
    = get_metrics(MAXT, N, DT, TIME, AS, VS, DS, AD, VD, DD, f1, f2)

% Compute peaks, extreme values, and their times
% ----------------------------------------------

% Extremes are same as peaks (or maxima) but preserve their signs

[tdS,tvS,taS,mdS,mvS,maS,xdS,xvS,xaS] = compute_peaks(DS,VS,AS,DT,N);
[tdD,tvD,taD,mdD,mvD,maD,xdD,xvD,xaD] = compute_peaks(DD,VD,AD,DT,N);

% Compute Arias Intensity
% -----------------------

arS = compute_arias(AS,DT,N);
arD = compute_arias(AD,DT,N);

for i = 1:3
    arxS(i)   = arS(N,i);
    arxD(i)   = arD(N,i);
    arnS(:,i) = arS(:,i)./arxS(i);
    arnD(:,i) = arD(:,i)./arxD(i);
    FIA(:,i)  = abs(arnS(:,i)-arnD(:,i));
end

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

% Compute response spectra
% ------------------------

[PERIOD,NP,rsS] = compute_response_spectra(AS,DT);
[PERIOD,NP,rsD] = compute_response_spectra(AD,DT);

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

smoother = 5;

for i = 1:3
    fVS(:,i) = smooth_spectra(fVS(:,i),smoother);
    fVD(:,i) = smooth_spectra(fVD(:,i),smoother);
    fAS(:,i) = smooth_spectra(fAS(:,i),smoother);
    fAD(:,i) = smooth_spectra(fAD(:,i),smoother);
end

% for i = 1:3
%     fVS(:,i) = smooth_spectra(fVS(:,i),fN);
%     fVD(:,i) = smooth_spectra(fVD(:,i),fN);
%     fAS(:,i) = smooth_spectra(fAS(:,i),fN);
%     fAD(:,i) = smooth_spectra(fAD(:,i),fN);
% end
% 
% for i = 1:3
%     fVS(:,i) = smooth(fVS(:,i),'loess');
%     fVD(:,i) = smooth(fVD(:,i),'loess');
%     fAS(:,i) = smooth(fAS(:,i),'loess');
%     fAD(:,i) = smooth(fAD(:,i),'loess');
% end

for f = 1:fN
    for i = 1:3
        FSS(f,i) = s_function(fAS(f,i),fAD(f,i));
    end
end

% Compute cross correlation
% -------------------------

for i = 1:3
    XCF(:,i) = xcorr(AS(:,i),AD(:,i),'coeff');
end

% Compute durations
% -----------------

[durS, t1S, t2S] = compute_duration(enS,VS,DT,N);
[durD, t1D, t2D] = compute_duration(enD,VD,DT,N);

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


% Compute Anderson Scores
% -----------------------

C = zeros(11,3);

for i = 1:3
    C( 1,i) = 10*(1-max(FIA(:,i)));
    C( 2,i) = 10*(1-max(FE(:,i)));
    C( 3,i) = s_function(arxS(i),arxD(i));
    C( 4,i) = s_function(enxS(i),enxD(i));
    C( 5,i) = s_function(maS(i),maD(i));
    C( 6,i) = s_function(mvS(i),mvD(i));
    C( 7,i) = s_function(mdS(i),mdD(i));
    C( 8,i) = mean(RSS(:,i));
    C( 9,i) = mean(FSS(:,i));
    C(10,i) = 10 * max([max(XCF(:,i)) 0]);
    C(11,i) = s_function(durS(i),durD(i));
%     C(12,i) = HS(i);
end

myC = zeros(9,3);

myC( 1,:) = (C(1,:)+C(2,:))./2;
myC( 2,:) = (C(3,:)+C(4,:))./2;
myC(3:9,:) = C(5:11,:);

INFO( 1,:) = [tdS tdD];
INFO( 2,:) = [tvS tvD];
INFO( 3,:) = [taS taD];
INFO( 4,:) = [mdS mdD];
INFO( 5,:) = [mvS mvD];
INFO( 6,:) = [maS maD];
INFO( 7,:) = [xdS xdD];
INFO( 8,:) = [xvS xvD];
INFO( 9,:) = [xaS xaD];
INFO(10,:) = [arxS arxD];
INFO(11,:) = [enxS enxD];
INFO(12,:) = [durS durD];
INFO(13,:) = [t1S t1D];
INFO(14,:) = [t2S t2D];

return;
