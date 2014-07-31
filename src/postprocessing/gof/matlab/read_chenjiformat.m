
function [pointsources,n] = read_chenjiformat(file)

fp = fopen(file,'r');

fgetl(fp);

% Order is:
% lat lon depth slip rake t_start t_left t_right M0(dyn.cm) strike dip

pointsources = fscanf(fp,'%f %f %f %f %f %f %f %f %e %f %f',[11 inf]);
pointsources = pointsources';

% get size

n = size(pointsources);
n = n(1);

% switch lat-lon

temp = pointsources(:,1);

pointsources(:,1) = pointsources(:,2);
pointsources(:,2) = n(:,1);

% convert depth to m

pointsources(:,4) = pointsources(:,4)/100;

return;