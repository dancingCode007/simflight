function TrajectoryToDataComparisonPlotter(u, est, tvlqr_out, lib, xtrajsim, t_start, t_end)


  % determine how many trajectories are in this run
  [~, start_idx] = min(abs(tvlqr_out.logtime - t_start));
  
  % find the last index that is included in the times we have
  [~, end_idx] = min(abs(tvlqr_out.logtime - t_end));
  end_idx_t = tvlqr_out.logtime(end_idx);
  while (end_idx_t > t_end)
    end_idx = end_idx - 1;
    end_inx_t = tvlqr_out.logtime(end_idx);
  end
  
  traj_start_t = tvlqr_out.logtime(start_idx:end_idx);
  traj_end_t = [ traj_start_t(2:end); t_end ];
  
  % list trajectories
  traj_nums = tvlqr_out.trajectory_number(start_idx:end_idx);
  
  title_str = 'Trajectory #:';
  
  for i = 1:length(traj_nums)
    
    this_traj_num = traj_nums(i);
    
    traj{i} = lib.GetTrajectoryByNumber(this_traj_num);
    
    if i > 1
      title_str = [title_str ' --> '];
    end
    
    title_str = [title_str traj{i}.name  ' (' num2str(this_traj_num) ')'];
    
  end
 
  
  disp(['t: ' num2str(t_start) ' -- ' num2str(t_end)]);
  disp(title_str);
  
  xlim_t_extra = 1.5;
  

  %%
  u = TrimU(t_start, t_end, u);
  est = TrimEst(t_start, t_end, est);


  %%
  dt = 1/140;
  
  for i = 1 : length(traj)
    
    if (traj{i}.xtraj.tspan(2) ~= Inf)
%       if i < length(traj)
%         traj_end_t(i) = traj_start_t{i+1};
%       else
%         traj_end_t(i) = traj{i}.xtraj.tspan(2);
%       end
%       
%     else
%       if i < length(traj)
%         traj_end_t(i) = traj_start_t{i+1};
%       else
%         traj_end_t(i) = u.logtime(end) - u.logtime(1);
%       end
    end

    traj_t{i} = 0:dt:traj_end_t(i)-traj_start_t(i);
    trajx{i} = traj{i}.xtraj.eval(traj_t{i});
    traju{i} = traj{i}.utraj.eval(traj_t{i});

    if ~isempty(xtrajsim)
      trajsim{i} = xtrajsim.eval(traj_t{i}+est.logtime(1));
    else
      trajsim{i} = zeros(12,1);
    end
  end

  %% plot roll
  
  figure_num = 1;
  coordinate_num = 4;
  label = 'Roll (deg)';

  figure(figure_num)
  clf

  plot(est.logtime, rad2deg(est.orientation.roll), '-r')
  hold all

  for i = 1 : length(traj)
    
    this_traj_t = traj_t{i};
    
    traj_coord = trajx{i}(coordinate_num,:);
    plot(this_traj_t+traj_start_t(i), rad2deg(traj_coord),'b-')

    %plot(t+traj_start{i}, rad2deg(trajsim(4,:)), '--k');
    
  end
  
  plot(traj_end_t, zeros(length(traj_end_t), 1), 'b*');

  first_traj_t = traj_t{1};
  last_traj_t = traj_t{length(traj)};
  %xlim([first_traj_t(1)+est.logtime(1) last_traj_t(end)+est.logtime(1) + xlim_t_extra]);

  grid on
  xlabel('Time (s)');
  ylabel(label);
  legend('Actual', 'Planned')
  title([ title_str ', ' label]);

 
  %% plot pitch

  figure_num = 2;
  coordinate_num = 5;
  label = 'Pitch (deg)';
  vals = rad2deg(est.orientation.pitch);
  
  figure(figure_num)
  clf

  plot(est.logtime, vals, '-r')
  hold all

  for i = 1 : length(traj)
    
    this_traj_t = traj_t{i};
    
    traj_coord = trajx{i}(coordinate_num,:);
    plot(this_traj_t+traj_start_t(i), rad2deg(traj_coord),'b-')

    %plot(t+traj_start{i}, rad2deg(trajsim(4,:)), '--k');
    
  end
  
  plot(traj_end_t, zeros(length(traj_end_t), 1), 'b*');

  first_traj_t = traj_t{1};
  last_traj_t = traj_t{length(traj)};
  %xlim([first_traj_t(1)+est.logtime(1) last_traj_t(end)+est.logtime(1) + xlim_t_extra]);

  grid on
  xlabel('Time (s)');
  ylabel(label);
  legend('Actual', 'Planned')
  title([ title_str ', ' label]);
  
  %% plot z

  figure_num = 3;
  coordinate_num = 3;
  label = 'Altitude (m)';
  vals = est.pos.z;
  
  figure(figure_num)
  clf

  plot(est.logtime, vals, '-r')
  hold all

  for i = 1 : length(traj)
    
    this_traj_t = traj_t{i};
    
    traj_coord = trajx{i}(coordinate_num,:);
    plot(this_traj_t+traj_start_t(i), rad2deg(traj_coord),'b-')

    %plot(t+traj_start{i}, rad2deg(trajsim(4,:)), '--k');
    
  end
  
  plot(traj_end_t, zeros(length(traj_end_t), 1), 'b*');

  first_traj_t = traj_t{1};
  last_traj_t = traj_t{length(traj)};
  %xlim([first_traj_t(1)+est.logtime(1) last_traj_t(end)+est.logtime(1) + xlim_t_extra]);

  grid on
  xlabel('Time (s)');
  ylabel(label);
  legend('Actual', 'Planned')
  title([ title_str ', ' label]);
return;
  %% plot u

  figure(4)
  clf
  plot(u.logtime, u.rad.elevonL);
  hold on
  plot(t+u.logtime(1), traju(1,:),'b--')



  plot(u.logtime, u.rad.elevonR, 'm-');
  plot(t+u.logtime(1), traju(2,:),'m--')
  %plot(u.logtime, u.throttle, 'k-');
  legend('elevonL', 'elevonL-plan', 'elevonR', 'elevonR-plan');
  grid on

  xlim([t(1)+est.logtime(1) t(end)+est.logtime(1)  + xlim_t_extra]);
  title([ title_str ', u']);


end