function		rot_3dmodel(F,prh,speed)

%		rot_3dmodel(F,prh)
%
%

if nargin<3,
	t = 0.05 ;
else
	t = 1/speed ;
end
	
for k=1:size(prh,1),
    Q = euler_to_rotmat(prh(k,:))' ;
    tpts = F.P*Q ;
    set(F.p,'Vertices',[tpts(:,1) -tpts(:,2) tpts(:,3)]) ;
	 lx = F.LX*Q ;
	 set(F.L(1),'xdata',lx(:,1),'ydata',-lx(:,2),'zdata',lx(:,3));
	 set(F.A(1),'xdata',lx(2,1),'ydata',-lx(2,2),'zdata',lx(2,3));
	 ly = F.LX(:,[3 1 2])*Q ;
	 set(F.L(2),'xdata',ly(:,1),'ydata',-ly(:,2),'zdata',ly(:,3));
	 set(F.A(2),'xdata',ly(2,1),'ydata',-ly(2,2),'zdata',ly(2,3));
	 lz = F.LX(:,[2 3 1])*Q ;
	 set(F.L(3),'xdata',lz(:,1),'ydata',-lz(:,2),'zdata',lz(:,3));
	 set(F.A(3),'xdata',lz(2,1),'ydata',-lz(2,2),'zdata',lz(2,3));
	 if ~isempty(F.C),
		cx = F.CX*Q ;
		set(F.C(1),'xdata',cx(:,1),'ydata',-cx(:,2),'zdata',cx(:,3));
		cy = F.CX(:,[3 1 2])*Q ;
		set(F.C(2),'xdata',cy(:,1),'ydata',-cy(:,2),'zdata',cy(:,3));
		cz = F.CX(:,[2 3 1])*Q ;
		set(F.C(3),'xdata',cz(:,1),'ydata',-cz(:,2),'zdata',cz(:,3));
	 end
    drawnow ;
    pause(t);
end
