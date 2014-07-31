
function [ra,rv,rd] = rotate_signal(theta,a,v,d)

radAngle = theta * pi / 180;

ra(:,1) = a(:,1).*(cos(radAngle)) - a(:,2).*(sin(radAngle));
ra(:,2) = a(:,1).*(cos(radAngle)) + a(:,2).*(sin(radAngle));
ra(:,3) = a(:,3).*(-1);

rv(:,1) = v(:,1).*(cos(radAngle)) - v(:,2).*(sin(radAngle));
rv(:,2) = v(:,1).*(cos(radAngle)) + v(:,2).*(sin(radAngle));
rv(:,3) = v(:,3).*(-1);

rd(:,1) = d(:,1).*(cos(radAngle)) - d(:,2).*(sin(radAngle));
rd(:,2) = d(:,1).*(cos(radAngle)) + d(:,2).*(sin(radAngle));
rd(:,3) = d(:,3).*(-1);
