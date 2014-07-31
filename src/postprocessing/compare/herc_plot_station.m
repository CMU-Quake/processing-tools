%
% Hercules station plotting script (HERCULES format)
%

% Include project defs
%run('herc_proj_1Hz');
run('herc_proj_lahabra_1Hz');

% BBP OLI: http://bbpvault.usc.edu/bbp/tests/la_habra/run1/3213153.OLI_velocity_seis.png
% strongmotion.org: http://strongmotioncenter.org/vdc/scripts/event.plx?evt=1295
runstr = 'run1';
stanum = 28;
netid = 'CI';
staid = 'OLI';

% BBP BRE: http://bbpvault.usc.edu/bbp/tests/la_habra/run1/3213153.BRE_velocity_seis.png
%
%runstr = 'run1';
%stanum = 4;
%netid = 'CI';
%staid = 'BRE';

% Chino OLI for comparison
%
%runstr = 'chino';
%stanum = 14;
%netid = 'CI';
%staid = 'OLI';

stafile = sprintf('./lahabra/%s/station.%d', runstr, stanum);

% Open the station files
FID=fopen(stafile,'rt');
data=textscan(FID,'%f%f%f%f%f%f%f%f%f%f','Headerlines',1,'CommentStyle','#');
fclose(FID);

% Extract columns
st = data{1};
vx = data{5};
vy = data{6};
vz = data{7};

% Flip Z for hercules
vz = -vz;

% Find max values for plot scaling
mx = ceil(max(abs(vx))/0.01)*0.01;
my = ceil(max(abs(vy))/0.01)*0.01;
mz = ceil(max(abs(vz))/0.01)*0.01;

% Plot the graph
subplot(3,1,1);
plot(st, vx, 'b-', 'markersize', 20);
title('X component');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
ylim([-mx mx]);
subplot(3,1,2);
plot(st, vy, 'b-', 'markersize', 20);
title('Y component');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
ylim([-my my]);
subplot(3,1,3);
plot(st, vz, 'b-', 'markersize', 20);
title('Z component');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
ylim([-mz mz]);
%legend('log_{10}(\sigma_{est})', ...
%    'log_{10}(\sigma_M)', ...
%    'LS fit of log_{10}(\sigma_M)');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

titlestr = sprintf('Seismogram for %s-%s (%s)', netid, staid, runstr);
text(0.5, 1,titlestr,'HorizontalAlignment','center','VerticalAlignment', 'top')

plotfile = sprintf('./lahabra/fig/plot_%s_%s_%s', runstr, netid, staid);
print('-dpng', plotfile);
