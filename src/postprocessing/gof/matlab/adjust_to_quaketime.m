
function [samples,acc] = ...
    adjust_to_quaketime(SIMTIME,EQTIME,BUFFER,triggertime,acc,samples,dt)

% Adjust to earthquake time
% -------------------------

% The buffer is to make sure we allow the slipfunction
% to rise smoothly from zero to one, assuming that the
% earthquake time was set at the 50% of the rise time.

time_diff    = EQTIME - [0; 0; BUFFER] - triggertime;
seconds_diff = time_diff.*[3600; 60; 1];
seconds_diff = sum(seconds_diff);
temp = fix(seconds_diff/dt);
seconds_diff = temp*dt;

newsamples = SIMTIME/dt;
sig = acc;
% acc = zeros(newsamples,3);

if seconds_diff > 0
    
    % Station started recording earlier than the earthquake time
    % minus the buffer time and the signal must be cut by the difference
    
    samples_to_cut = fix(seconds_diff/dt);
    remaining_samples = samples - samples_to_cut;
    
    if remaining_samples < newsamples
        % the signal is shorter that the simulation
        newsamples = remaining_samples;
        acc = zeros(newsamples,1);
        acc(1:remaining_samples,1) ...
            = sig(samples_to_cut+1:samples,1);
    else
        % the signal is longer than the simulation
        acc = zeros(newsamples,1);
        acc(1:newsamples,1) ...
            = sig(samples_to_cut+1:samples_to_cut+newsamples,1);
    end
    
else
    
    % Station started later than the earthquake time minus the buffer time
    % and the signal must be padded with zeros in front of it
    
    padding_samples = -fix(seconds_diff/dt);
    new_length = padding_samples + samples;
    
    if newsamples > new_length
        % the signal is shorter than the simulation
        newsamples = new_length;
        acc = zeros(newsamples,1);
        acc(padding_samples+1:new_length,1) ...
            = sig(:,1);
    else
        % the signal is now longer than the simulation
        acc = zeros(newsamples,1);
        end_sample = newsamples-(padding_samples + samples - newsamples);
        acc(padding_samples+1:newsamples,1) ...
            = sig(1:newsamples-padding_samples,1);
    end
end

% Update samples

samples = newsamples;
