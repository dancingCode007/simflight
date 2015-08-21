%% load data

clear

% TODO: detect these?
%parameters = {0.904, 0.000, -0.134, -0.049, 0 };

date = '2015-08-14';
name = 'field-test-realtime-planning';
log_number = '03';
stabilization_trajectory = 0;
hostname = 'odroid-gps2';

trajectory_library = 'traj-archive/aug14-2.mat';

use_simulation = false;



disp(['Loading ' trajectory_library '...']);
load(trajectory_library);



dir = [date '-' name '/' hostname '/'];
filename = ['lcmlog_' strrep(date, '-', '_') '_' log_number '.mat'];


dir_prefix = '/home/abarry/rlg/logs/';
dir = [ dir_prefix dir ];

addpath('/home/abarry/realtime/scripts/logs');

disp(['Loading ' filename '...']);

loadDeltawing


disp('done.');

%% remove trajectories on the ground

[t_starts_unfiltered, t_ends_unfiltered] = FindActiveTimes(u.logtime, u.is_autonomous, 0.5);

t_starts = [];
t_ends = [];

for i = 1 : length(t_starts_unfiltered)
  [~, idx] = min(abs(est.logtime - t_starts_unfiltered(i)));
  
  this_alt = est.pos.z(idx);
  
  if (this_alt > 7.5)
    t_starts = [t_starts t_starts_unfiltered(i)];
    t_ends = [t_ends t_ends_unfiltered(i)];
  else
    disp(['t = ' num2str(t_starts_unfiltered(i)) ' to ' num2str(t_ends_unfiltered(i)) ' filtered for being on the ground.']);
  end
end



%% simulate

if use_simulation

    for i = 1:length(t_starts)

      xtrajsim{i} = SimulateTrajectoryAgainstData(u, est, parameters, t_starts(i), t_ends(i));

    end
else
    xtrajsim = {};
end


%% plot

for i = 1:length(t_starts)
  if use_simulation
    TrajectoryToDataComparisonPlotter(u, est, tvlqr_out, lib, t_starts(i), t_ends(i), stabilization_trajectory);
  else
    TrajectoryToDataComparisonPlotter(u, est, tvlqr_out, lib, t_starts(i), t_ends(i), stabilization_trajectory);
  end
  
  pause
  
end