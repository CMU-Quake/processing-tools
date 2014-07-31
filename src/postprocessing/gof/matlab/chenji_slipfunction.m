
function slipfunction = chenji_slipfunction(pointsource,dt,totaltime,toplot)

FMIN = 0.01;
FMAX = 6;
POINTS = 16384;

fmin   = FMIN;
fmax   = FMAX;
points = POINTS;

t_start = pointsource(6);
t_left  = pointsource(7);
t_right = pointsource(8);
rise_t  = t_left + t_right;
t_end   = t_start + rise_t;

samples = totaltime/dt;
slipfunction = zeros(samples,2);

for i = 1:samples
    t = (i-1)*dt;
    if (t <= t_start) | (t >= t_end)
        slipfunction(i,2) = 0;
    else
        if t <= t_left+t_start
            slipfunction(i,2) = ...
                (1-cos(2*pi*(t-t_start)/(2*t_left)))/rise_t;
        else
            slipfunction(i,2) = ...
                (1+cos(2*pi*(t-t_left-t_start)/(2*t_right)))/rise_t;
        end
    end
end

slipfunction(:,1) = integrate_signal(slipfunction(:,2),dt);

slipfunction(:,1) = slipfunction(:,1)*pointsource(4);
slipfunction(:,2) = derivate_signal(slipfunction(:,1),dt);

if toplot == 1
    figure;
    t = 0:dt:totaltime-dt;
    subplot(2,2,1)
    plot(t,slipfunction(:,1));
    subplot(2,2,3)
    plot(t,slipfunction(:,2));
    
    [f,fs] = fourierbounded(slipfunction(:,2),fmin,fmax,dt,points);
    subplot(2,2,4)
    plot(f,fs);

end

return;
