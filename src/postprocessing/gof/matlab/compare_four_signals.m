
function compare_four_signals(data_root,cvms_root,cvmh_root,cvmg_root,stationName,stationNumber) %,doPlot,hf)

ROTANGLE  = 39.9;
FMIN      = 0.15;
FMAX      = 4;
ORDERLOW  = 9;
ORDERHIGH = 3;
RP        = 0.5;

SIMUDT    = 0.02;

data_file = [data_root, '/', stationName, '.her'];
cvms_file = [cvms_root, '/station.', num2str(stationNumber)];
cvmh_file = [cvmh_root, '/station.', num2str(stationNumber)];
cvmg_file = [cvmg_root, '/station.', num2str(stationNumber)];

ft_fn_d = ['../data-processed/data--vft.', num2str(stationNumber)];
ft_fn_s = ['../data-processed/cvms--vft.', num2str(stationNumber)];
ft_fn_h = ['../data-processed/cvmhn-vft.', num2str(stationNumber)];
ft_fn_g = ['../data-processed/cvmhy-vft.', num2str(stationNumber)];

v_fn_d = ['../data-processed/data--vel.', num2str(stationNumber)];
v_fn_s = ['../data-processed/cvms--vel.', num2str(stationNumber)];
v_fn_h = ['../data-processed/cvmhn-vel.', num2str(stationNumber)];
v_fn_g = ['../data-processed/cvmhy-vel.', num2str(stationNumber)];

fpd = fopen(ft_fn_d,'w');
fps = fopen(ft_fn_s,'w');
fph = fopen(ft_fn_h,'w');
fpg = fopen(ft_fn_g,'w');

vpd = fopen(v_fn_d,'w');
vps = fopen(v_fn_s,'w');
vph = fopen(v_fn_h,'w');
vpg = fopen(v_fn_g,'w');

% Loading signals
% ---------------

[data_dt,data_t,data_a,data_v,data_d,data_n,data_tt] = load_hfile(data_file);
[cvms_dt,cvms_t,cvms_a,cvms_v,cvms_d,cvms_n,cvms_tt] = load_hfile(cvms_file);
[cvmh_dt,cvmh_t,cvmh_a,cvmh_v,cvmh_d,cvmh_n,cvmh_tt] = load_hfile(cvmh_file);
[cvmg_dt,cvmg_t,cvmg_a,cvmg_v,cvmg_d,cvmg_n,cvmg_tt] = load_hfile(cvmg_file);


% Correct synthetic units
% -----------------------

cvms_a = cvms_a*100;
cvms_v = cvms_v*100;
cvms_d = cvms_d*100;

cvmh_a = cvmh_a*100;
cvmh_v = cvmh_v*100;
cvmh_d = cvmh_d*100;

cvmg_a = cvmg_a*100;
cvmg_v = cvmg_v*100;
cvmg_d = cvmg_d*100;


% Rotate synthetics (counter clockwise)
% -------------------------------------

[cvms_a,cvms_v,cvms_d] = rotate_signal(ROTANGLE,cvms_a,cvms_v,cvms_d);
[cvmh_a,cvmh_v,cvmh_d] = rotate_signal(ROTANGLE,cvmh_a,cvmh_v,cvmh_d);
[cvmg_a,cvmg_v,cvmg_d] = rotate_signal(ROTANGLE,cvmg_a,cvmg_v,cvmg_d);


% Filtering synthetics according to processing of data
% ----------------------------------------------------

% data

cornerlow = FMAX / ( (1/data_dt)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

[data_a,data_v,data_d] = lowpass_filter(al,bl,data_a,data_v,data_d);

% synehtics

cornerlow = FMAX / ( (1/SIMUDT)/2 );
[bl,al] = cheby1(ORDERLOW,RP,cornerlow,'low');

cornerhigh = FMIN / ( (1/SIMUDT)/2 );
[bh,ah] = cheby1(ORDERHIGH,RP,cornerhigh,'high');

% Highpass

[cvms_a,cvms_v,cvms_d] = lowpass_filter(ah,bh,cvms_a,cvms_v,cvms_d);
[cvmh_a,cvmh_v,cvmh_d] = lowpass_filter(ah,bh,cvmh_a,cvmh_v,cvmh_d);
[cvmg_a,cvmg_v,cvmg_d] = lowpass_filter(ah,bh,cvmg_a,cvmg_v,cvmg_d);

% Lowpass

[cvms_a,cvms_v,cvms_d] = lowpass_filter(al,bl,cvms_a,cvms_v,cvms_d);
[cvmh_a,cvmh_v,cvmh_d] = lowpass_filter(al,bl,cvmh_a,cvmh_v,cvmh_d);
[cvmg_a,cvmg_v,cvmg_d] = lowpass_filter(al,bl,cvmg_a,cvmg_v,cvmg_d);


% Find common lenght
% ------------------

length(data_t);
length(cvms_t);

minT = min(data_tt,cvms_tt);

nData = fix(minT/data_dt+1);
nSimu = fix(minT/cvms_dt+1);

data_t = data_t(1:nData,:);
data_v = data_v(1:nData,:);

simu_t = cvms_t(1:nSimu,:);
cvms_v = cvms_v(1:nSimu,:);
cvmh_v = cvmh_v(1:nSimu,:);
cvmg_v = cvmg_v(1:nSimu,:);


% Compute Spectra
% ---------------

infFreq = 0.05;
supFreq = FMAX+0.3;

[fData,data_V(:,1)] = fourierbounded(data_v(:,1),infFreq,supFreq,data_dt,16384);
[fData,data_V(:,2)] = fourierbounded(data_v(:,2),infFreq,supFreq,data_dt,16384);
[fData,data_V(:,3)] = fourierbounded(data_v(:,3),infFreq,supFreq,data_dt,16384);

[fSimu,cvms_V(:,1)] = fourierbounded(cvms_v(:,1),infFreq,supFreq,cvms_dt,16384);
[fSimu,cvms_V(:,2)] = fourierbounded(cvms_v(:,2),infFreq,supFreq,cvms_dt,16384);
[fSimu,cvms_V(:,3)] = fourierbounded(cvms_v(:,3),infFreq,supFreq,cvms_dt,16384);

[fSimu,cvmh_V(:,1)] = fourierbounded(cvmh_v(:,1),infFreq,supFreq,cvmh_dt,16384);
[fSimu,cvmh_V(:,2)] = fourierbounded(cvmh_v(:,2),infFreq,supFreq,cvmh_dt,16384);
[fSimu,cvmh_V(:,3)] = fourierbounded(cvmh_v(:,3),infFreq,supFreq,cvmh_dt,16384);

[fSimu,cvmg_V(:,1)] = fourierbounded(cvmg_v(:,1),infFreq,supFreq,cvmg_dt,16384);
[fSimu,cvmg_V(:,2)] = fourierbounded(cvmg_v(:,2),infFreq,supFreq,cvmg_dt,16384);
[fSimu,cvmg_V(:,3)] = fourierbounded(cvmg_v(:,3),infFreq,supFreq,cvmg_dt,16384);

smoother = 10;

for i = 1:3
    data_V(:,i) = smooth_spectra(data_V(:,i),smoother);
    cvms_V(:,i) = smooth_spectra(cvms_V(:,i),smoother);
    cvmh_V(:,i) = smooth_spectra(cvmh_V(:,i),smoother);
    cvmg_V(:,i) = smooth_spectra(cvmg_V(:,i),smoother);
end

% Print Signals
% -------------

dv(:,1) = data_t;
dv(:,2:4) = data_v;
fprintf(vpd,'%f %f %f %f\n',dv');
fclose(vpd);

sv(:,1) = simu_t;
sv(:,2:4) = cvms_v;
fprintf(vps,'%f %f %f %f\n',sv');
fclose(vps);

hv(:,1) = simu_t;
hv(:,2:4) = cvmh_v;
fprintf(vph,'%f %f %f %f\n',hv');
fclose(vph);

gv(:,1) = simu_t;
gv(:,2:4) = cvmg_v;
fprintf(vpg,'%f %f %f %f\n',gv');
fclose(vpg);


% Print FFTs
% ----------

dfft(:,1) = fData;
dfft(:,2:4) = data_V;
fprintf(fpd,'%f %f %f %f\n',dfft');
fclose(fpd);

sfft(:,1) = fSimu;
sfft(:,2:4) = cvms_V;
fprintf(fps,'%f %f %f %f\n',sfft');
fclose(fps);

hfft(:,1) = fSimu;
hfft(:,2:4) = cvmh_V;
fprintf(fph,'%f %f %f %f\n',hfft');
fclose(fph);

gfft(:,1) = fSimu;
gfft(:,2:4) = cvmg_V;
fprintf(fpg,'%f %f %f %f\n',gfft');
fclose(fpg);




% Plotting Time Series (Velocity)
% -------------------------------

ylabels = ['NS';'EW';'UD'];

hf = figure('Position',[100 1100 1000 700]);
% set(gcf,'PaperUnits','normalized');
% set(gcf,'PaperPositionMode','manual');
% set(gcf,'PaperOrientation','landscape');
% set(gcf,'PaperPosition',[0 0.15 1 0.7]);

for i = 1:3

    % Time Series

    subplot(3,12,[(i-1)*12+1 (i-1)*12+7]);
    plot(data_t(:,1),data_v(:,i),'r');
    hold on;
    plot(simu_t(:,1),cvms_v(:,i),'b');
    plot(simu_t(:,1),cvmh_v(:,i),'g');
    plot(simu_t(:,1),cvmg_v(:,i),'c');
    hold off;

    if (i == 1)
        title(['Station ' stationName ' --- Velocity (cm/s)']);
    end
    ylabel(ylabels(i,:));
    if (i == 3)
        xlabel('Time (s)');
    end
    xlim([0 minT]);

    % Fourier Spectra

    subplot(3,12,[(i-1)*12+9 (i-1)*12+12]);
    plot(fData,data_V(:,i),'r');
    hold on;
    plot(fSimu,cvms_V(:,i),'b');
    plot(fSimu,cvmh_V(:,i),'g');
    plot(fSimu,cvmg_V(:,i),'c');
    hold off;
    if (i == 1)
        title(['Fourier Spectra (cm)']);
    end
    if (i == 3)
        xlabel('Frquency (Hz)');
    end
    xlim([0 supFreq]);
%    set(gca,'YScale','log');
end

print(hf, '-dpsc', [num2str(stationNumber) '_' stationName]);

return;
