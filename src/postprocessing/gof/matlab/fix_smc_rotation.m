function [azimuth, acc] = fix_smc_rotation(dirs, azimuths, samples, signals)

acc = zeros(samples,3);
azimuth = zeros(1,2);
i = [0 0];

% making sure azimuths are positive

for i = 1:3
    if azimuths(i) < 0
        display('An azimuth is negative');
        return;
    end
end

% selecting indices and

if (dirs(1) == 3) ...
        & (azimuths(1) == 500) ...
        & (dirs(2) == 4) ...
        & (dirs(3) == 4)

    i = [2 3];
    acc(:,3) = signals(:,1);

elseif (dirs(2) == 3) ...
        & (azimuths(2) == 500) ...
        & (dirs(1) == 4) ...
        & (dirs(3) == 4)

    i = [1 3];
    acc(:,3) = signals(:,2);

elseif (dirs(3) == 3) ...
        & (azimuths(3) == 500) ...
        & (dirs(1) == 4) ...
        & (dirs(2) == 4)

    i = [1 2];
    acc(:,3) = signals(:,3);

else
    display('There is no vertical signal');
    return;
end

azimuthA = azimuths(i(1));
azimuthB = azimuths(i(2));
signalA  = signals(:,i(1));
signalB  = signals(:,i(2));

% case 1: 0-90 & 90-180

if (azimuthA > 0) & (azimuthA < 180) & ...
   (azimuthB > 0) & (azimuthB < 180)

    if (azimuthB < 90) & (azimuthA > 90)
        % switch A and B
        azimuthA = azimuths(i(2));
        azimuthB = azimuths(i(1));
        signalA  = signals(:,i(2));
        signalB  = signals(:,i(1));
    end

    if azimuthB-azimuthA ~= 90
        display('Rotation was NOT successful');
        return;
    end
        
    radangle = azimuthA * pi / 180;
    acc(:,1) = signalA.*(cos(radangle)) ...
             - signalB.*(sin(radangle));
    acc(:,2) = signalA.*(sin(radangle)) ...
             + signalB.*(cos(radangle));
    azimuth(1) = 0;
    azimuth(2) = 90;
    return;
end
        
% case 2: 90-180 & 180-270

if (azimuthA > 90) & (azimuthA < 270) & ...
   (azimuthB > 90) & (azimuthB < 270)

    if (azimuthB < 180) & (azimuthA > 180)
        % switch A and B
        azimuthA = azimuths(i(2));
        azimuthB = azimuths(i(1));
        signalA  = signals(:,i(2));
        signalB  = signals(:,i(1));
    end

    if azimuthB-azimuthA ~= 90
        display('Rotation was NOT successful');
        return;
    end
        
    radangle = (azimuthA-90) * pi / 180;
    acc(:,1) = - signalA.*(sin(radangle)) ...
               - signalB.*(cos(radangle));
    acc(:,2) = signalA.*(cos(radangle)) ...
             - signalB.*(sin(radangle));
    azimuth(1) = 0;
    azimuth(2) = 90;
    return;
end
        
% case 4: 270-360 & 0-90

if ( (azimuthA > 270) & (azimuthB < 90) ) | ...
   ( (azimuthB > 270) & (azimuthA < 90) )

    if (azimuthB > 270) & (azimuthA < 90)
        % switch A and B
        azimuthA = azimuths(i(2));
        azimuthB = azimuths(i(1));
        signalA  = signals(:,i(2));
        signalB  = signals(:,i(1));
    end

    if 360-azimuthA+azimuthB ~= 90
        display('Rotation was NOT successful');
        return;
    end
        
    radangle = azimuthB * pi / 180;
    acc(:,1) = signalA.*(sin(radangle)) ...
             + signalB.*(cos(radangle));
    acc(:,2) = signalB.*(sin(radangle)) ...
             - signalA.*(cos(radangle));
    azimuth(1) = 0;
    azimuth(2) = 90;
    return;
end


% Contiguous quadrants (1-2,2-3,3-4)
% ----------------------------------

% orthocheck = azimuths(i(2))-azimuths(i(1));
% theangle = azimuths(i(1));
% if i(1) < i(2) & orthocheck == 90
%     radangle = theangle*pi/180;
%     acc(:,1) = signals(:,i(1)).*(cos(radangle)) ...
%              - signals(:,i(2)).*(sin(radangle));
%     acc(:,2) = signals(:,i(1)).*(sin(radangle)) ...
%              + signals(:,i(2)).*(cos(radangle));
%     azimuth(1) = 0;
%     azimuth(2) = 90;
%     return;
% end

% orthocheck = azimuths(i(1))-azimuths(i(2));
% theangle = azimuths(i(2));
% if i(2) < i(1) & orthocheck == 90
%     radangle = theangle*pi/180;
%     acc(:,1) = signals(:,i(2)).*(cos(radangle)) ...
%              - signals(:,i(1)).*(sin(radangle));
%     acc(:,2) = signals(:,i(2)).*(sin(radangle)) ...
%              + signals(:,i(1)).*(cos(radangle));
%     azimuth(1) = 0;
%     azimuth(2) = 90;
%     return;
% end
% 
% % First and fourth octant cases
% % -----------------------------
% 
% orthocheck = 360-azimuths(i(1))+azimuths(i(2));
% theangle = azimuths(i(2));
% if i(1) < i(2) & orthocheck == 90 ...
%         & azimuths(i(2)) < 90 ...
%         & azimuths(i(1)) > 270
%     radangle = theangle*pi/180;
%     acc(:,1) = signals(:,i(1)).*(cos(radangle)) ...
%              + signals(:,i(2)).*(sin(radangle));
%     acc(:,2) = signals(:,i(1)).*(sin(radangle)) ...
%              - signals(:,i(2)).*(cos(radangle));
%     azimuth(1) = 0;
%     azimuth(2) = 90;
%     return;
% end
% 
% orthocheck = 360-azimuths(i(2))+azimuths(i(1));
% theangle = azimuths(i(1));
% if i(2) < i(1) & orthocheck == 90 ...
%         & azimuths(i(1)) < 90 ...
%         & azimuths(i(2)) > 270
%     radangle = theangle*pi/180;
%     acc(:,1) = signals(:,i(2)).*(cos(radangle)) ...
%              + signals(:,i(1)).*(sin(radangle));
%     acc(:,2) = signals(:,i(2)).*(sin(radangle)) ...
%              - signals(:,i(1)).*(cos(radangle));
%     azimuth(1) = 0;
%     azimuth(2) = 90;
%     return;
% end

display('Rotation was NOT successful');
return;
