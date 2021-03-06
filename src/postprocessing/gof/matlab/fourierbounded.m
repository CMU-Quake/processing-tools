
function [f,fs] = fourierbounded(s,fmin,fmax,dt,points);

fft_s(:,1) = fft(s(:,1),points);

afs_s = abs(fft_s)*dt;

freq = (1/dt)*(0:points-1)/points;
freq = freq';

deltaf = (1/dt)/points;

ini = fix(fmin/deltaf)+1;
fin = fix(fmax/deltaf);

fs = afs_s(ini:fin,:);
f  = freq(ini:fin,:);