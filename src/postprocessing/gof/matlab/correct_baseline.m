
function corrected = correct_baseline(signal)

SAMPLES = 1000;
avg = mean(signal(1:SAMPLES));
corrected = signal - avg;

return;