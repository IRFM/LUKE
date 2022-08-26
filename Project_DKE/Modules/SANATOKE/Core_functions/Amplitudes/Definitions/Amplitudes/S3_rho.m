function S3 = S3_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dS3_0,d3S3_0] = amps{15:16};
[S3_a,dS3_a,d2S3_a,d3S3_a] = amps{39:42};

rho_star = equil.rho_star;

S3 = S2_like_rho(rho,rho_star,a,dS3_0,d3S3_0,S3_a,dS3_a,d2S3_a,d3S3_a);
end
