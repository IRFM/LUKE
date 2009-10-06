void fluctuation(mode,krho,m,n,Y,krho_s1,krho_s2,krho_s3,krho_s4,krho_s5,krho_s6, m_s1,m_s2,m_s3,m_s4,m_s5, n_s1,n_s2,n_s3,n_s4,n_s5,raymagnetic,rayprofiles,param,equilparam,Npar,ap,cnorm,ran2,res,reset)
int mode;
double *krho;
double *m;
double *n;
double Y[];
double krho_s1,krho_s2,krho_s3,krho_s4,krho_s5,krho_s6;
double m_s1,m_s2,m_s3,m_s4,m_s5;
double n_s1,n_s2,n_s3,n_s4,n_s5;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
rayparam_format param;
equilparam_format equilparam;
double Npar;
double ap,cnorm;
double clum=CLUM;
double ran2;
long int *reset;
double *res;
double pi = 3.141592653526;

static double ran2(idum)
long int *idum;
{

	long int j;
	long int k;
 	static long int idum2 = 123456789;
 	static long int iy = 0;
 	static long int iv[32];
 	double temp;
 
 	double eps = 1.2e-7,rnmx,am,ndiv;
 	long int im1 = 2147483563,im2 = 2147483399,imm1,ia1 = 40014,ia2 = 40692,iq1 = 53668,iq2 = 52774;
 	long int ir1 = 12211,ir2 = 3791,ntab = 32;
 
 	imm1 = im1 - 1L;
 	am = (double)1.0/(double)im1;
 	ndiv = (double)1.0+(double)imm1/(double)ntab;
 	rnmx = (double)1.0 - eps;
 
 	if (*idum <=0L) {
 		if(-(*idum) < 1L) *idum = 1L;
 		else *idum = -(*idum);
 		idum2 = (*idum);
 		for (j = ntab+7L;j>=0L;j--) {
 			k = (long int)(*idum)/iq1;
 			*idum = ia1*(*idum-k*iq1)-k*ir1;
 			if(*idum<0L) *idum += im1;
 			if (j < ntab) iv[j] = *idum;
 		}
 		iy = iv[0];
 	}
 	
 	k = (long int)(*idum)/iq1;
 	*idum = ia1*(*idum-k*iq1)-k*ir1;
 	if (*idum < 0L) *idum += im1;
 	k = (long int)(idum2/iq2);
 	idum2 = ia2*(idum2-k*iq2)-k*ir2;
 	if (idum2 < 0L) idum2 += im2;
 	j = (long)(iy/(long int)ndiv);
 	iy = iv[j]-idum2;
 	iv[j] = *idum;
 	if(iy < 1) iy += imm1;
 	if ((temp = am*(double)iy) > rnmx) return(rnmx);
 	else return(temp);
}
srand(time(NULL));
reset=rand();
res[0] = (double)2.0*pi*ran2(reset);   
ap = equilparam.ap[0];
cnorm = clum/ap/Y[6];

krho_s1=raymagnetic.Bsn[0]*(Npar/cnorm)*(raymagnetic.salpha[0]/raymagnetic.calpha[0]);
krho_s2=(raymagnetic.BPHIn[0]/raymagnetic.calpha[0])*(Y[4]/raymagnetic.rn[0]);
krho_s3=-raymagnetic.BPHIn[0]*Y[3]*raymagnetic.gradrhon[0]*(raymagnetic.salpha[0]/raymagnetic.calpha[0]);
krho_s4=-raymagnetic.Bsn[0]*Y[5]/raymagnetic.Rn[0];
krho_s5=raymagnetic.Bsn[0]*(Npar/cnorm)*(raymagnetic.salpha[0]/raymagnetic.calpha[0]);
krho_s6=-Y[3]*raymagnetic.gradrhon[0];

krho[0]=(krho_s1+((krho_s2+krho_s3+krho_s4)*sin(res[0]))-((krho_s5+krho_s6)*cos(res[0])))/raymagnetic.gradrhon[0];

m_s1=(raymagnetic.Bsn[0]/raymagnetic.calpha[0])*(Npar/cnorm);
m_s2=raymagnetic.BPHIn[0]*(Y[4]/raymagnetic.rn[0])*(raymagnetic.salpha[0]/raymagnetic.calpha[0]);
m_s3=-(raymagnetic.BPHIn[0]/raymagnetic.calpha[0])*Y[3]*raymagnetic.gradrhon[0];
m_s4=(raymagnetic.Bsn[0]/raymagnetic.calpha[0])*(Npar/cnorm);
m_s5=-Y[4]/raymagnetic.rn[0];

m_scat[0]=(m_s1+((m_s2+m_s3)*sin(res[0]))-((m_s4+m_s5)*cos(res[0])))*raymagnetic.rn[0];

n_s1=raymagnetic.BPHIn[0]*(Npar/cnorm);
n_s2=raymagnetic.Bsn[0]*Y[3]*raymagnetic.gradrhon[0];
n_s3=-raymagnetic.Bsn[0]*(Y[4]/raymagnetic.rn[0])*raymagnetic.salpha[0];
n_s4=raymagnetic.BPHIn[0]*(Npar/cnorm);
n_s5=-Y[5]/raymagnetic.Rn[0];

n_scat[0]=(n_s1+((n_s2+n_s3)*sin(res[0]))-((n_s4+n_s5)*cos(res[0])))*raymagnetic.Rn[0];
