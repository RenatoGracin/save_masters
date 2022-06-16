function E=E(r1,r2,r3,Cx,Cy,Cz,theta,gamma,phi)

E_hat=diag([1/r1^2 1/r2^2 1/r3^2 -1]);

Dt=[1 0 0 -Cx ; 0 1 0 -Cy ; 0 0 1 -Cz ; 0 0 0 1];

Dr=[cos(gamma)*cos(phi)-cos(theta)*sin(gamma)*sin(phi)  sin(gamma)*cos(phi)+cos(theta)*cos(gamma)*sin(phi) sin(theta)*sin(phi) 0 ...
 ; -cos(gamma)*sin(phi)-cos(theta)*sin(gamma)*cos(phi) -sin(gamma)*sin(phi)+cos(theta)*cos(gamma)*cos(phi) sin(theta)*cos(phi) 0 ...
 ;                  sin(theta)*sin(gamma)                         -sin(theta)*cos(gamma)                         cos(theta)    0 ...
 ;                                0                                          0                                       0         1];

 E=Dt'*Dr'*E_hat*Dr*Dt;
end