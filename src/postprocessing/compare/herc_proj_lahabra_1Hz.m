%
% Hercules project definitions (HERCULES format)
%

% Location of GPU/CPU simulation directories
gpudir='/lustre/atlas/scratch/spatrick/geo015/hercules/lahabra_gpu/outputfiles_gpu';
cpudir='/lustre/atlas/scratch/spatrick/geo015/hercules/lahabra_gpu/outputfiles_cpu';

% Tolerance for displacement values
pepsilon         = 1e-13;
sepsilon         = 1e-8;

% Simulation parameters from parameters.in
simTime         = 100.0;
simDT           = 0.005;
printRate       = 10;

deltaT          = simDT*printRate;
theSteps        = simTime/deltaT-1;

alongStrike  = 541;
downDip      = 721;

stepAlongStrike = 250;
stepDownDip     = 250;

numStations = 341;
