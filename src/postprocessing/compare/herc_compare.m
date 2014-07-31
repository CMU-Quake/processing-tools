%
% Hercules comparison script (HERCULES format)
%

% Include project defs
%run('herc_proj_1Hz');
run('herc_proj_lahabra_1Hz');

fprintf('COMPARING SEISMOGRAMS:\n');

for s=1:numStations;

  % Maximum difference encountered
  maxdiff = 0.0;
  maxdifft = 0;
  maxdifff = 0;

  fprintf('%06d: ', s-1);
  gpufile=sprintf('%s/stations/station.%d', gpudir, s-1);
  cpufile=sprintf('%s/stations/station.%d', cpudir, s-1);

  % Open the station files
  FID=fopen(gpufile,'rt');
  data1=textscan(FID,'%f%f%f%f%f%f%f%f%f%f','Headerlines',1,'CommentStyle','#');
  fclose(FID);
  FID=fopen(cpufile,'rt');
  data2=textscan(FID,'%f%f%f%f%f%f%f%f%f%f','Headerlines',1,'CommentStyle','#');
  fclose(FID);

  % Extract columns
  gt = data1{1};
  ct = data2{1};

  % Check file length
  gpusteps = size(gt,1);
  if (gpusteps ~= theSteps+1)
    fprintf('Only %d timesteps found in file (expected %d)\n', gpusteps, theSteps+1);
    quit;
  end

  % Compare fields
  for f=1:9
    gdata = data1{f+1};
    cdata = data2{f+1};
    for iTime=1:theSteps+1;
      diff = abs(gdata(iTime) - cdata(iTime));
      avg = (gdata(iTime) + cdata(iTime))/2;
      pdiff = diff / avg * 100.0;
      if (pdiff > maxdiff)
        maxdiff = pdiff;
        maxdifft = iTime;
        maxdifff = f;
      end
      if (diff > sepsilon)
	fprintf('Mismatch at t=%d,f=%d : %.12e, %.12e\n', iTime, f, gdata(iTime), cdata(iTime));
        quit;
      end
    end
  end

  if (maxdiff > 0.0)
    fprintf('%f%%, t=%06d, f=%d\n', maxdiff, maxdifft, maxdifff);
  else
    fprintf('OK\n');
 end
end

fprintf('\nCOMPARING DISPLACEMENTS:\n');

% Open the displacement files
gpufile=sprintf('%s/planes/planedisplacements.0', gpudir);
cpufile=sprintf('%s/planes/planedisplacements.0', cpudir);

fprintf('Opening GPU file: %s\n', gpufile);
fp1=fopen(gpufile);
fprintf('Opening CPU file: %s\n', cpufile);
fp2=fopen(cpufile);

% Read displacements for first timestep
dis1 = fread(fp1, downDip*alongStrike*3,'float64');
dis2 = fread(fp2, downDip*alongStrike*3,'float64');

X1 = dis1(1:3:downDip*alongStrike*3);
Y1 = dis1(2:3:downDip*alongStrike*3);
Z1 = dis1(3:3:downDip*alongStrike*3);
X2 = dis2(1:3:downDip*alongStrike*3);
Y2 = dis2(2:3:downDip*alongStrike*3);
Z2 = dis2(3:3:downDip*alongStrike*3);

disX11 = reshape(X1,downDip,alongStrike);
disY11 = reshape(Y1,downDip,alongStrike);
disZ11 = reshape(Z1,downDip,alongStrike);    
disX12 = reshape(X2,downDip,alongStrike);
disY12 = reshape(Y2,downDip,alongStrike);
disZ12 = reshape(Z2,downDip,alongStrike);    

% Maximum difference encountered
maxdiff = 0.0;

fprintf('\nExamining time steps:\n%06d ', 0);

for iTime=1:theSteps;

    if (mod(iTime,100)==0) 
      fprintf(' %f%%\n%06d ', maxdiff, iTime);
    elseif (mod(iTime,10)==0) 
      fprintf('.');
    end

    dis1 = fread(fp1, downDip*alongStrike*3,'float64');
    dis2 = fread(fp2, downDip*alongStrike*3,'float64');
    
    X1 = dis1(1:3:downDip*alongStrike*3);
    Y1 = dis1(2:3:downDip*alongStrike*3);
    Z1 = dis1(3:3:downDip*alongStrike*3);
    X2 = dis2(1:3:downDip*alongStrike*3);
    Y2 = dis2(2:3:downDip*alongStrike*3);
    Z2 = dis2(3:3:downDip*alongStrike*3);

    disX21 = reshape(X1,downDip,alongStrike);
    disY21 = reshape(Y1,downDip,alongStrike);
    disZ21 = reshape(Z1,downDip,alongStrike);    
    disX22 = reshape(X2,downDip,alongStrike);
    disY22 = reshape(Y2,downDip,alongStrike);
    disZ22 = reshape(Z2,downDip,alongStrike);    

    for y=1:downDip;
      for z=1:alongStrike;
        diffx = abs(disX21(y,z) - disX22(y,z));
        diffy = abs(disY21(y,z) - disY22(y,z));
        diffz = abs(disZ21(y,z) - disZ22(y,z));
        if (diffx > pepsilon)
	  fprintf('Mismatch at disX2 t=%d,x=%d,y=%d : %.12e, %.12e\n', iTime, y, z, disX21(y,z), disX22(y,z));
          quit;
        end
        if (diffy > pepsilon)
	  fprintf('Mismatch at disY2 t=%d,x=%d,y=%d : %.12e, %.12e\n', iTime, y, z, disY21(y,z), disY22(y,z));
          quit;
        end
        if (diffz > pepsilon)
	  fprintf('Mismatch at disZ2 t=%d,x=%d,y=%d : %.12e, %.12e\n', iTime, y, z, disZ21(y,z), disZ22(y,z));
          quit;
        end

	pdiffx = diffx / ((disX21(y,z) + disX22(y,z))/2) * 100.0;
	pdiffy = diffy / ((disY21(y,z) + disY22(y,z))/2) * 100.0;
	pdiffz = diffz / ((disZ21(y,z) + disZ22(y,z))/2) * 100.0;
        if (pdiffx > maxdiff)
          maxdiff = pdiffx;
        end
        if (pdiffy > maxdiff)
          maxdiff = pdiffy;
        end
        if (pdiffz > maxdiff)
          maxdiff = pdiffz;
        end
      end
    end

    disX11 = disX21;        
    disY11 = disY21;    
    disZ11 = disZ21;
    disX12 = disX22;        
    disY12 = disY22;    
    disZ12 = disZ22;

end

fprintf(' %f%%\n', maxdiff);

quit
