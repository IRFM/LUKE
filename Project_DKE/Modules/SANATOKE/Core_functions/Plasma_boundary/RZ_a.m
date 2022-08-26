function RZ_a = RZ_a(theta,dirichlet)
% Computes R(rho=a,theta) and Z(rho=a,theta) given Dirichlet parameters

dirich = num2cell(dirichlet) ;
[R0_a,Z0_a,a,e_a,S2_a,A2_a,S3_a,A3_a] = dirich{:} ;

RZ_a(:,1) = R0_a + a.*(cos(theta) + (S3_a.*(1-cos(theta)) + A3_a.*sin(theta)) - (S2_a.*(1-cos(2.*theta)) - A2_a.*sin(2.*theta)) - (S3_a.*(1-cos(3.*theta)) - A3_a.*sin(3.*theta))) ;
RZ_a(:,2) = Z0_a + e_a.*a.*(sin(theta) + (A3_a.*(1-cos(theta)) - S3_a.*sin(theta)) - (A2_a.*(1-cos(2.*theta)) + S2_a.*sin(2.*theta)) - (A3_a.*(1-cos(3.*theta)) + S3_a.*sin(3.*theta))) ;
end

