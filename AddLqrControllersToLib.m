function lib = AddLqrControllersToLib(name, lib, xtraj, utraj, gains)

  p = lib.p;

  xtraj = xtraj.setOutputFrame(p.getStateFrame());
  utraj = utraj.setOutputFrame(p.getInputFrame());
 
  Q = gains.Q;
  Qf = gains.Qf;
  R_values = gains.R_values;
  K_pd = gains.K_pd;
  K_pd_yaw = gains.K_pd_yaw;
  K_pd_aggressive_yaw = gains.K_pd_aggressive_yaw;
  
  
  % first one is just open loop
  K_ol = 0.*K_pd;
  
  ktraj = ConstantTrajectory(-K_ol);
  affine_traj = ConstantTrajectory(zeros(3,1));

  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  
  trajname = [name '-open-loop'];
  
  comments = sprintf('%s\n\n%s', trajname, [prettymat('Parameters', cell2mat(p.parameters), 3)]);
  
  % add the open-loop trajectory twice since both of it's "gain" settings
  % are the same
  lib = lib.AddTrajectory(xtraj, utraj, lqrsys, trajname, comments);
  lib = lib.AddTrajectory(xtraj, utraj, lqrsys, trajname, comments);
  
  
  % now just use the K_pd's and build trajectories
  
  
  ktraj = ConstantTrajectory(-K_pd);
  affine_traj = ConstantTrajectory(zeros(3,1));

  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  
  trajname = [name '-PD'];
  
  comments = sprintf('%s\n\n%s', trajname, [prettymat('Parameters', cell2mat(p.parameters), 3)]);
  
  lib = lib.AddTrajectory(xtraj, utraj, lqrsys, trajname, comments);
  
  ktraj = ConstantTrajectory(-K_pd_yaw);
  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  
  trajname = [name '-PD-yaw'];
  
  comments = sprintf('%s\n\n%s', trajname, [prettymat('Parameters', cell2mat(p.parameters), 3)]);
  
  lib = lib.AddTrajectory(xtraj, utraj, lqrsys, trajname, comments);
  
%   ktraj = ConstantTrajectory(-K_pd_aggressive_yaw);
%   lqrsys = struct();
%   lqrsys.D = ktraj;
%   lqrsys.y0 = affine_traj;
%   lib = lib.AddTrajectory(xtraj, utraj, lqrsys, [name '-PD-aggressive-yaw'], comments);
  
  for i = 1:length(R_values)
    R = diag([R_values(i)*ones(1,3)]);

    disp(['Computing TVLQR controller (R = ' num2str(R_values(i)) ')...']);
    lqr_controller = tvlqr(p, xtraj, utraj, Q, R, Qf);

    comments = sprintf('%s\n\n%s', name, [prettymat('Parameters', cell2mat(p.parameters), 3) ...
      prettymat('Q', Q, 5) prettymat('R', R)]);
    lib = lib.AddTrajectory(xtraj, utraj, lqr_controller, [name '-R-' num2str(R_values(i))], comments);

  end
  
  
  disp('done');

end