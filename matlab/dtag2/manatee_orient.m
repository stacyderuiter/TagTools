function    s_rot = manatee_orient(s_raw);

%function to re-cast accel and mag axes for manatee data analysis

s_rot = s_raw;
s_rot(:,1) = s_raw(:,3);
s_rot(:,2) = s_raw(:,1);
s_rot(:,3) = s_raw(:,2);
s_rot(:,4) = -s_raw(:,3);
s_rot(:,5) = s_raw(:,1);
s_rot(:,6) = -s_raw(:,2);

return
 

