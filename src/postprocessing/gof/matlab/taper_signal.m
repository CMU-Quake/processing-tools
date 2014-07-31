
function tapered_signal = taper_signal(signal,samples,dt)

TIME = 2; % seconds

taper_samples = 5/dt;
r = taper_samples/samples;

w = tukeywin(samples, r);

tapered_signal = signal .* w;

return;
