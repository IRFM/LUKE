/*
 
   eh_dke_yp.C  MEX file for the Elwert-Haug bremsstrahlung cross-section 

    [seEH,ec,e] = eh_dke_yp(ec,e,t,Z)
    
    INPUT:

        - ec: kinetic energy of the incoming electron (keV) [1,m] 
          (default = 500)
        - e: photon energy (keV)  [1,n] 
        - t: angle between the direction of displacement of the incoming 
          electron and the photon emitted by bremsstrahlung (radian) [1,p]
          (default = 0)
        - Z: target ion charge (default = 1) [1,1]

    OUTPUT: 

        - seEH: Elwert-Haug bremstrahlung cross-section (cm^2) [n,m]
        - ec: kinetic energy of the incoming electron (mec2) [n,m] 
        - e: photon energy (mec2)  [n,m] 
        - t: angle between the direction of displacement of the incoming 
          electron and the photon emitted by bremsstrahlung (radian) [n,p] if m=1
          or [p,m] if n=1, or [n,m] if p=1.

    Warning: Cross-section units : cm^2 but energies are in relativistic units. To get 
             cross-sections in standard cm^2/keV units, seBH or seBHe must be divided 
             by 511 keV.


    COMPILATION DEC-STATION:
    
        - move to the directory of the source code xxx.c
        - execute the command /usr/local/matlab/bin/cmex xxx.c -lm


by Y.PEYSSON CEA-DRFC 15/05/1991 <yves.peysson@cea.fr>
for MatLab 4.1 (22/08/1994) 
*/

#include <math.h>
#include "mex.h"

/*input arguments*/

#define ec_IN   prhs[0]
#define e_IN    prhs[1]
#define t_IN    prhs[2]
#define Z_IN    prhs[3]     

/* Output Arguments */

#define seEH_OUT    plhs[0]
#define ec_OUT      plhs[1]
#define e_OUT       plhs[2]
#define t_OUT       plhs[3]
    
#define max(A, B)   ((A) > (B) ? (A) : (B))
#define min(A, B)   ((A) < (B) ? (A) : (B))
#define abs(A)      ((A) >= 0 ? (A) : -(A))

static
#ifdef __STDC__
    xgamma(
    double x,
    double y,
    double *re,
    double *im
    )
#else
    xgamma(x,y,re,im)
    double x,y,*re,*im;
#endif
{

    double w,re2,im2,fn,xs,m,at;
    double xq,yq,zq,z4,z6,h,h1,ln,a;
    double rekl,imkl,r,s,res,ims,re1,im1;
    
    w = 2.5066283;
    
    if (abs(x)-3.0 < 0) {   
        if (x < 0) {
            xs = x-3.0;
            m = 1;
        } else if (x >= 0) {
            xs = x+3.0;
            m = 2;
        }
    } else if (abs(x)-3.0 >= 0) {
        xs = x;
        m = 3;
    }
    
    xq = xs*xs;
    yq = y*y;
    zq = xq+yq;
    z4 = zq*zq;
    z6 = zq*z4;
    h = xq-yq;
    h1 = 1.0+xs/(12.0*zq);
    ln = .5*log(zq);
    at = atan2(y,xs);
    rekl = h1+h/(288.0*z4)-2.6813272e-3*xs*(xq-3.0*yq)/z6-2.294721e-4*(h*h-4.0*xq*yq)/(z4*z4);
    imkl = -y/(12.0*zq)*(h1-3.2175926e-2*(h+xq+xq)/z4-1.10146605e-2*h*xs/z6);
    r = w*exp(ln*(xs-.5)-xs-y*at);
    s = y*ln-y+(xs-.5)*at;
    res = cos(s);
    ims = sin(s);
    re1 = r*(rekl*res-imkl*ims);
    im1 = r*(rekl*ims+imkl*res);
        
    if (m < 2) {
        re2 = (xs+1.0)*(xq+2.0*xs-3.0*yq);
        im2 = y*(3.0*xq-yq+6.0*xs+2.0);
        re[0] = re1*re2-im1*im2;
        im[0] = re1*im2+re2*im1;
    } else if (m == 2) {
        re2 = xs*(xq-3.0*yq+11.0)-6.0*h-6.0;
        im2 = y*(3.0*xq-yq-12.0*xs+11.0);
        fn = pow(re2,2)+pow(im2,2);
        re[0] = (re1*re2+im1*im2)/fn;
        im[0] = (re2*im1-re1*im2)/fn;
    } else if (m > 2) {
        re[0] = re1;
        im[0] = im1;
    }
}



static
#ifdef __STDC__
    hgfn(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
    double x,
    double *re,
    double *im
    )
#else
    hgfn(a,b,c,d,e,f,x,re,im)
double a,b,c,d,e,f,x,*re,*im;
#endif
{
    double delta,h1,h2,h3,h4,h5,h6,h7;
    double h8,h9,h10,h11,h12,h13;
          
    delta = (double)1.0e-07;
    
    if (abs(x) < 1.0) {
        h1 = a;
        h2 = c;
        h3 = e;
        h4 = (double)1.0;
        h5 = -b*d;    
        h6 = f*f;
        h7 = a*c+h5;
        h8 = a*d+b*c;
        h9 = x/(e*e+h6);
        h10 = (h7*e+h8*f)*h9;
        re[0] = 1.0+h10;
        h11 = (h8*e-h7*f)*h9;
        im[0] = h11;
        h1 = h1+1.0;
        h2 = h2+1.0;
        h3 = h3+1.0;
        h4 = h4+1.0;
        h7 = h1*h2+h5;
        h8 = h1*d+h2*b;
        h9 = x/((h3*h3+h6)*h4);
        h12 = (h7*h3+h8*f)*h9;
        h13 = (h8*h3-h7*f)*h9;
        h7 = h10*h12-h11*h13;
        re[0] = re[0]+h7;
        h11 = h11*h12+h10*h13;
        im[0] = im[0]+h11;
        h10 = h7;
        
        while (abs(h10) > delta || abs(h11) > delta) {
            h1 = h1+1.0;
            h2 = h2+1.0;
            h3 = h3+1.0;
            h4 = h4+1.0;
            h7 = h1*h2+h5;
            h8 = h1*d+h2*b;
            h9 = x/((h3*h3+h6)*h4);
            h12 = (h7*h3+h8*f)*h9;
            h13 = (h8*h3-h7*f)*h9;
            h7 = h10*h12-h11*h13;
            re[0] = re[0]+h7;
            h11 = h11*h12+h10*h13;
            im[0] = im[0]+h11;
            h10 = h7;        
        }
    }      
}


static
#ifdef __STDC__
    hgf(
    double a,
    double b,
    double c,
    double d,
    double g,
    double x,
    double *re,
    double *im
    )
#else
    hgf(a,b,c,d,g,x,re,im)
double a,b,c,d,g,x,*re,*im;
#endif
{
    
    double delta,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11;
    
    delta = (double)1.0e-07;
    
    if(abs(x) < 1.0) {
        h1 = a;
        h2 = c;
        h3 = g;
        h4 = (double)1.0;
        h5 = -b*d;
        h6 = (a*c+h5)*x/g;
        re[0] = (double)1.0+h6;
        h7 = (a*d+b*c)*x/g;
        im[0] = h7;
        h1 = h1+(double)1.0;
        h2 = h2+(double)1.0;
        h3 = h3+(double)1.0;
        h4 = h4+(double)1.0;
        h8 = x/(h3*h4);
        h9 = h1*h2+h5;
        h10 = h1*d+h2*b;
        h11 = (h6*h9-h7*h10)*h8;
        re[0] = re[0]+h11;
        h7 = (h7*h9+h6*h10)*h8;
        im[0] = im[0]+h7;
        h6 = h11;
                
        while (abs(h6) > delta || abs(h7) > delta) {   
            h1 = h1+(double)1.0;
            h2 = h2+(double)1.0;
            h3 = h3+(double)1.0;
            h4 = h4+(double)1.0;
            h8 = x/(h3*h4);
            h9 = h1*h2+h5;
            h10 = h1*d+h2*b;
            h11 = (h6*h9-h7*h10)*h8;
            re[0] = re[0]+h11;
            h7 = (h7*h9+h6*h10)*h8;
            im[0] = im[0]+h7;
            h6 = h11;
 
        }  
    }
}



static
#ifdef __STDC__
    sigma(
    double *z,
    double *t1,
    double *pen,
    double *theta1,
    double *sec
    )
#else
    sigma(z,t1,pen,theta1,sec)
double *z,*t1,*pen,*theta1,*sec;
#endif
{
    double alpha,mcq,r0q,g1,g2,pi,xbarn;
    double arc,gnte,dte,gnp,dph,e1,t2,e2,beta2,a;
    double eps1,eps1q,p1q,p1,eps2,eps2q,p2q;
    double p2,p12,k,kq,mu,rho,kappa,a1,a2,a21;
    double regn,gnq,reg,faktor;
    double th1,si1,cs1,p1k,d1,eta1q,w2q;
    double t,the,sie,cse,p1p2,p,phi,cs2,pp,p2k;
    double eta2q,eta12,d2,q2,ex,x;
    double al,r1,csr1,sir1,ex1,r2,csr2,sir2;
    double hi1,hi2,hi3,hi4,rev,imv,hi5,hi6,rew,imw;
    double rea1,ima1,rea2,ima2,reb,imb,ee1,ee2,e3,o1;
    double f1,f2,f3,wq,wq1,wq2,reg1,reg2,reg21;
    double ref1,ref2,ref3,re,im,wqint;
    double var0,var1,var2,var3,a21m,a1m,a2m,xex1m;
    
    double zz,tt1,ppen,ttheta1;
    
    int nte,np,it,ip,jt,jp,kk = 0;
    
    double img1,img2,img21,imgn,img,imf1,imf2,imf3;
    double wqs,xn,wqskal;

    alpha = (double)7.29736e-03;
    mcq = (double)511.006;
    r0q = (double)0.079408;
    g1 = (double)0.422649731;
    g2 = (double)1.577350269;
    pi = (double)3.14159265352;
    xbarn = (double)1.0e-24;
    arc = pi/(double)180.0;
    nte = 100;
    gnte = (double)100.0;
    dte = pi/gnte;
    np = 20;
    gnp = (double)20;
    dph = pi/gnp;   
        
    
    e1 = t1[0];
    t2 = t1[0]-pen[0];
    e2 = t2;
    
    
    beta2 = (double)1.0-1.0/(pow((double)1.0+t1[0]/mcq,(double)2.0));
    
    a = alpha*z[0];

    eps1 = (double)1.0+e1/mcq;
    eps1q = pow(eps1,(double)2.0);
    p1q = eps1q-1.0;
    p1 = sqrt(p1q);
    eps2 = (double)1.0+e2/mcq;
    eps2q = pow(eps2,(double)2.0);
    p2q = eps2q-(double)1.0;
    p2 = sqrt(p2q);
    p12 = p1*p2;
    k = eps1-eps2;
    kq = k*k;
    mu = pow(p1+p2,(double)2.0)-kq;
    rho = (double)1.0/p1+(double)1.0/p2;
    kappa = eps1/p1+eps2/p2;
    a1 = a*eps1/p1;
    a2 = a*eps2/p2;
    a21 = a2-a1;

    var0 = 0.0;

    xgamma (var0,a1,&reg1,&img1);
    xgamma (var0,a2,&reg2,&img2);
    xgamma (var0,a21,&reg21,&img21); 
    

    regn = reg1*reg2+img1*img2;
    imgn = reg1*img2-img1*reg2;
    gnq = (double)1.0/(pow(regn,(double)2.0)+pow(imgn,(double)2.0));
    reg = (reg21*regn+img21*imgn)*gnq;
    img = (regn*img21-imgn*reg21)*gnq;
    faktor = (double)4.0*a1*a2/((exp((double)2.0*pi*a1)-(double)1.0)*((double)1.0-exp(-2.0*pi*a2)))*r0q*a*z[0]*p2*k/p1;

    th1 = theta1[0]*arc;
    si1 = sin(th1);
    cs1 = cos(th1);
    p1k = p1*k*cs1;
    d1 = (double)2.0*(eps1*k-p1k);
    eta1q = pow(p1*si1,(double)2.0);
    wq2 = (double)0.0;
    
    for (it = 2; it<=nte; it += 2) {
        t = it*(double)1.0;
        the = dte*(t-g1);   
        for (jt = 1; jt<=2; jt++) {     
            sie = sin(the);
            cse = cos(the);
            p1p2 = p12*cse;
            wq1 = (double)0.0;
            for (ip = 2; ip<=np; ip += 2) {         
                p=ip*(double)1.0;
                phi=dph*(p-g1);
                for (jp = 1; jp<=2; jp++) {     
                    cs2 = cs1*cse+si1*sie*cos(phi);
                    pp = p12*cs1*cs2;
                    p2k = p2*k*cs2;
                    eta2q = p2q*(1.0-pow(cs2,(double)2.0));
                    eta12 = p1p2-pp;
                    d2 = (double)2.0*(eps2*k-p2k);
                    q2 = d1+(double)2.0*(p2q-p1p2+p2k);
                    ex = mu*q2/(d1*d2);
                    x = (double)1.0-ex;    
                    
                    if ((x+(double)0.4) < 0.0) {
                        al = log(ex);
                        r1 = a1*al;
                        csr1 = cos(r1);
                        sir1 = sin(r1);
                        ex1 = (double)1.0/ex;
                        if((x+(double)1.5) < 0.0) {
                            r2 = a2*al;
                            csr2 = cos(r2);
                            sir2 = sin(r2);
                            
                            var0 = (double)0.0;
                            var1 = (double)1.0;
                            var2 = (double)1.0;
                            a21m = -a21;
                            a1m = -a1;
                            a2m = -a2;
                            
                            hgfn(var0,a1,var1,a2m,var2,a21m,ex1,&ref1,&imf1);
                            hgfn(var0,a2,var1,a1m,var2,a21,ex1,&ref2,&imf2);
                            
    
                            hi1 = ref1*csr1+imf1*sir1;
                            hi2 = ref2*csr2+imf2*sir2;
                            hi3 = ref1*sir1-imf1*csr1;
                            hi4 = ref2*sir2-imf2*csr2;
                            rev = (reg*hi3-img*hi1)/a1+(reg*hi4+img*hi2)/a2;
                            imv = (reg*hi1+img*hi3)/a1+(reg*hi2-img*hi4)/a2;
                                        
                            var0 = (double)1.0;
                            var1 = (double)1.0;
                            var2 = (double)1.0;
                            a21m = -a21;    
                            a2m = -a2;  
                            
                            hgfn(var0,a1,var1,a2m,var2,a21m,ex1,&ref3,&imf3);
                            
                            hi5 = reg*ref3-img*imf3;
                            hi6 = reg*imf3+img*ref3;
                            rew = (hi5*(csr1+csr2)+hi6*(sir1-sir2))/(a1*a2*ex);
                            imw = (hi6*(csr1-csr2)-hi5*(sir1+sir2))/(a1*a2*ex);
        
                            rea1 = (rev+a1*ex*imw)/(d1*q2);
                            ima1 = (imv-a1*ex*rew)/(d1*q2);
                            rea2 = (rev+a2*ex*imw)/(d2*q2);
                            ima2 = (imv-a2*ex*rew)/(d2*q2);
                            reb = -a*imw/(d1*d2);
                            imb = a*rew/(d1*d2);
                            ee1 = ((double)4.0*eps2q-q2)*eta1q+((double)2.0*kq/d2*(eta2q+(double)1.0)+eta1q-eta12)*d1;
                            ee2 = ((double)4.0*eps1q-q2)*eta2q+((double)2.0*kq/d1*(eta1q+(double)1.0)-eta2q+eta12)*d2;
                            e3 = ((double)4.0*eps1*eps2-q2)*eta12+(double)0.5*d1*(eta12-eta2q)+0.5*d2*(eta1q-eta12)+2.0*kq*(eta12+(double)1.0);
                            o1 = (double)0.5*mu*((double)1.0/p2-(double)1.0/p1)*pp;
                            f1 = k*(rho*(eta1q-eta12)-o1+(double)0.25*mu*d1/p1+kappa*p1*cs1*p1p2+(2.0/p1-kappa*p12/k)*p2k+k*(eps2*rho+kappa));
                            f2 = k*(rho*(eta2q-eta12)+o1-(double)0.25*mu*d2/p2+kappa*p2*cs2*p1p2-(2.0/p2+kappa*p12/k)*p1k-k*(eps1*rho+kappa));
                            f3 = mu*(kq-kq*cs1*cs2+(p1q-p2q)/(p1q*p2q)*(p1q-p2q+p1k+p2k))-2.0*kq*rho*rho;
                            wq = faktor*(ee1*(pow(rea1,(double)2.0)+pow(ima1,(double)2.0))+ee2*(pow(rea2,(double)2.0)+pow(ima2,(double)2.0))
                                    -(double)2.0*(e3*(rea1*rea2+ima1*ima2)+f1*(rea1*reb+ima1*imb)
                                    +f2*(rea2*reb+ima2*imb))+f3*(pow(reb,(double)2.0)+pow(imb,(double)2.0)));
                            wq1 = wq1+wq;   
                        
                        } 
                        
                        else {
                            
                            var0 = (double)0.0;
                            var1 = (double)1.0;
                            var2 = (double)1.0;
                            a2m = -a2;
                            xex1m = -x*ex1;
                            
                            hgf(var0,a1,var1,a2m,var2,xex1m,&re,&im);
                            
                            rev = re*csr1+im*sir1;
                            imv = im*csr1-re*sir1;
                            
                            var0 = (double)1.0;
                            var1 = (double)1.0;
                            var2 = (double)2.0;
                            a2m = -a2;
                            xex1m = -x*ex1;
                            
                            hgf(var0,a1,var1,a2m,var2,xex1m,&re,&im);
                            
                            rew = (re*csr1+im*sir1)*ex1;
                            imw = (im*csr1-re*sir1)*ex1;
                            rea1 = (rev+a1*ex*imw)/(d1*q2);
                            ima1 = (imv-a1*ex*rew)/(d1*q2);
                            rea2 = (rev+a2*ex*imw)/(d2*q2);
                            ima2 = (imv-a2*ex*rew)/(d2*q2);
                            reb = -a*imw/(d1*d2);
                            imb = a*rew/(d1*d2);
                            ee1 = ((double)4.0*eps2q-q2)*eta1q+(2.0*kq/d2*(eta2q+(double)1.0)+eta1q-eta12)*d1;
                            ee2 = ((double)4.0*eps1q-q2)*eta2q+(2.0*kq/d1*(eta1q+(double)1.0)-eta2q+eta12)*d2;
                            e3 = ((double)4.0*eps1*eps2-q2)*eta12+0.5*d1*(eta12-eta2q)+0.5*d2*(eta1q-eta12)+2.0*kq*(eta12+(double)1.0);
                            o1 = (double)0.5*mu*((double)1.0/p2-(double)1.0/p1)*pp;
                            f1 = k*(rho*(eta1q-eta12)-o1+(double)0.25*mu*d1/p1+kappa*p1*cs1*p1p2+((double)2.0/p1-kappa*p12/k)*p2k+k*(eps2*rho+kappa));
                            f2 = k*(rho*(eta2q-eta12)+o1-(double)0.25*mu*d2/p2+kappa*p2*cs2*p1p2-((double)2.0/p2+kappa*p12/k)*p1k-k*(eps1*rho+kappa));
                            f3 = mu*(kq-kq*cs1*cs2+(p1q-p2q)/(p1q*p2q)*(p1q-p2q+p1k+p2k))-(double)2.0*kq*rho*rho;
                            wq = faktor*(ee1*(pow(rea1,(double)2.0)+pow(ima1,(double)2.0))+ee2*(pow(rea2,(double)2.0)+pow(ima2,(double)2.0))
                                -(double)2.0*(e3*(rea1*rea2+ima1*ima2)+f1*(rea1*reb+ima1*imb)
                                +f2*(rea2*reb+ima2*imb))+f3*(pow(reb,(double)2.0)+pow(imb,(double)2.0)));
                            wq1 = wq1+wq;                           
                        }
                    }
                    else {
                    
                        var0 = (double)0.0;
                        var1 = (double)0.0;
                        var2 = (double)1.0;
                        
                        hgf(var0,a1,var1,a2,var2,x,&rev,&imv);
                        
                        var0 = (double)1.0;
                        var1 = (double)1.0;
                        var2 = (double)2.0;
                        
                        hgf(var0,a1,var1,a2,var2,x,&rew,&imw);
                        
                        rea1 = (rev+a1*ex*imw)/(d1*q2);
                        ima1 = (imv-a1*ex*rew)/(d1*q2);
                        rea2 = (rev+a2*ex*imw)/(d2*q2);
                        ima2 = (imv-a2*ex*rew)/(d2*q2);
                        reb = -a*imw/(d1*d2);
                        imb = a*rew/(d1*d2);
                        ee1 = ((double)4.0*eps2q-q2)*eta1q+(2.0*kq/d2*(eta2q+(double)1.0)+eta1q-eta12)*d1;
                        ee2 = ((double)4.0*eps1q-q2)*eta2q+(2.0*kq/d1*(eta1q+(double)1.0)-eta2q+eta12)*d2;
                        e3 = ((double)4.0*eps1*eps2-q2)*eta12+0.5*d1*(eta12-eta2q)+0.5*d2*(eta1q-eta12)+(double)2.0*kq*(eta12+(double)1.0);
                        o1 = (double)0.5*mu*((double)1.0/p2-(double)1.0/p1)*pp;
                        f1 = k*(rho*(eta1q-eta12)-o1+(double)0.25*mu*d1/p1+kappa*p1*cs1*p1p2+((double)2.0/p1-kappa*p12/k)*p2k+k*(eps2*rho+kappa));
                        f2 = k*(rho*(eta2q-eta12)+o1-(double)0.25*mu*d2/p2+kappa*p2*cs2*p1p2-((double)2.0/p2+kappa*p12/k)*p1k-k*(eps1*rho+kappa));
                        f3 = mu*(kq-kq*cs1*cs2+(p1q-p2q)/(p1q*p2q)*(p1q-p2q+p1k+p2k))-2.0*kq*rho*rho;
                        wq = faktor*(ee1*(pow(rea1,(double)2.0)+pow(ima1,(double)2.0))+ee2*(pow(rea2,(double)2.0)+pow(ima2,(double)2.0))
                            -(double)2.0*(e3*(rea1*rea2+ima1*ima2)+f1*(rea1*reb+ima1*imb)
                            +f2*(rea2*reb+ima2*imb))+f3*(pow(reb,(double)2.0)+pow(imb,(double)2.0)));
                        wq1 = wq1+wq;
                    }       
                    phi=dph*(p-g2);
                }
            }   
            wq2 = wq2+wq1*sie;
            the = dte*(t-g2); 
        }   
    }
    wqint = 2.0*wq2*dte*dph;    
    wqs = wqint/mcq;
    wqskal = wqs*beta2*pen[0]/(z[0]*z[0]);
    xn = xbarn*wqs*sqrt(beta2);
    sec[0] = xn*mcq/sqrt(beta2); 
}   





static
#ifdef __STDC__
    sigmabrem(
    double seEHout[],
    double ecout[],
    double eout[],
    double tout[],
    double ec[],
    double e[],
    double t[],
    double *Z,
    unsigned int m,
    unsigned int n,
    unsigned int mode
    )
#else
    sigmabrem(seEHout,ecout,eout,tout,ec,e,t,Z,m,n,mode)
double seEHout[],ecout[],eout[],tout[],ec[],e[],t[],*Z;
unsigned int m,n,mode;
#endif
{

    unsigned int k,i,j;
    double pi = 3.14159265352;
    double sec,ee,ephot,ang;
    
    if (mode == 1) {    /* t is a scalar */ 
        
        k = 0;
        for (i = 0; i<n; i++) {
            for (j = 0; j<m; j++) {
                k = i*m + j;
                ecout[k] = ec[i]/511.0;
                eout[k] = e[j]/511.0;
                tout[k] = t[0];
                ee = ec[i];
                ephot = e[j];
                ang = t[0]*180.0/pi;
                
                if (ecout[k] <= eout[k]) 
                    seEHout[k] = 0;
                else {
                    sigma(Z,&ee,&ephot,&ang,&sec); 
                    seEHout[k] = sec;
                }
            }
        }

    } else if (mode == 2) {  /* e is a scalar*/
    
        k = 0;
        for (i = 0; i<n; i++) {
            for (j = 0; j<m; j++) {
                k = i*m + j;
                ecout[k] = ec[i]/511.0;
                eout[k] = e[0]/511.0;
                tout[k] = t[j];
                ee = ec[i];
                ephot = e[0];
                ang = t[j]*180.0/pi;
                if (ecout[k] <= eout[k]) 
                    seEHout[k] = 0;
                else {
                    sigma(Z,&ee,&ephot,&ang,&sec); 
                    seEHout[k] = sec;
                }
            
            }
        }   
    
    } else if (mode == 3) {    /* ec is a scalar  */

        k = 0;
        for (i = 0; i<n; i++) {
            for (j = 0; j<m; j++) {
                k = i*m + j;
                ecout[k] = ec[0]/511.0;
                eout[k] = e[j]/511.0;
                tout[k] = t[i];
                ee = ec[0];
                ephot = e[j];
                ang = t[i]*180.0/pi;
                if (ecout[k] <= eout[k]) 
                    seEHout[k] = 0;
                else {
                    sigma(Z,&ee,&ephot,&ang,&sec); 
                    seEHout[k] = sec;
                }
            }
        }   

    }
}





#ifdef __STDC__
void mexFunction(
    int     nlhs,
    Matrix  *plhs[],
    int     nrhs,
    Matrix  *prhs[]
    )
#else
mexFunction(nlhs, plhs, nrhs, prhs)
int nlhs, nrhs;
Matrix *plhs[], *prhs[];
#endif
{
    double  *seEHout,*ecout,*eout,*tout;
    
    double  *ec,*e,*t,*Z;
    unsigned int m,n,mec,nec,me,ne,mt,nt;
    unsigned int mode = 0;

    /* Check for proper number of arguments */

    if (nrhs < 2) {
    
        mexErrMsgTxt("The function eh_dke_yp requires at least two input arguments.");
    
    } else if (nrhs == 2) {
    
        ec = mxGetPr(ec_IN);
        e = mxGetPr(e_IN);

        t = (double *)mxCalloc(1,sizeof(double));
        Z = (double *)mxCalloc(1,sizeof(double));

        *t = (double) 0.0;
        *Z = (double) 1.0;
        
        mec = mxGetM(ec_IN);
        nec = mxGetN(ec_IN);
        me = mxGetM(e_IN);
        ne = mxGetN(e_IN);
        mt = 1;
        nt = 1;
                        
    } else if (nrhs == 3) {
    
        ec = mxGetPr(ec_IN);
        e = mxGetPr(e_IN);
        t = mxGetPr(t_IN);
        
        Z = (double *)mxCalloc(1,sizeof(double));

        *Z = (double) 1.0;
        
        mec = mxGetM(ec_IN);
        nec = mxGetN(ec_IN);
        me = mxGetM(e_IN);
        ne = mxGetN(e_IN);
        mt = mxGetM(t_IN);
        nt = mxGetN(t_IN);
        
    } else if (nrhs == 4) { 
            
        ec = mxGetPr(ec_IN);
        e = mxGetPr(e_IN);
        t = mxGetPr(t_IN);
        Z = mxGetPr(Z_IN);
        
        mec = mxGetM(ec_IN);
        nec = mxGetN(ec_IN);
        me = mxGetM(e_IN);
        ne = mxGetN(e_IN);
        mt = mxGetM(t_IN);
        nt = mxGetN(t_IN);
                
    }   else if (nlhs > 3) {
        mexErrMsgTxt("The function eh_dke_yp requires up to three output arguments.");
    }


    /* Check the dimensions of ec and e.  ec and e can be m X 1 or 1 X m. */
    

    if (min(mec,nec) != 1 || min(me,ne) != 1 || min(mt,nt) != 1) {
        mexErrMsgTxt("The function eh_dke_yp requires that ec and e be vectors.");
    } 
    
    if (max(mec,nec) != 1 && min(me,ne) != 1 && min(mt,nt) != 1) {
        mexErrMsgTxt("The function eh_dkeyp requires only two vectors as input arguments.");
    } 

    if (max(mt,nt) == 1) {
        mode = 1;
        n = max(mec,nec);
        m = max(me,ne);
    }
    if  (max(me,ne) == 1) {
        mode = 2;
        n = max(mec,nec);
        m = max(mt,nt);     
    }
    if  (max(mec,nec) == 1) {
        mode = 3;   
        n = max(mt,nt);
        m = max(me,ne);
    }

    
    /* Create matrix for the return arguments */

    seEH_OUT = mxCreateFull(m, n, REAL);
    ec_OUT = mxCreateFull(m, n, REAL);
    e_OUT = mxCreateFull(m, n, REAL);
    t_OUT = mxCreateFull(m, n, REAL);

    /* Assign pointers to the various parameters */

    seEHout = mxGetPr(seEH_OUT);
    ecout = mxGetPr(ec_OUT);
    eout = mxGetPr(e_OUT);
    tout = mxGetPr(t_OUT);

    /* Do the actual computations in a subroutine */

    sigmabrem(seEHout,ecout,eout,tout,ec,e,t,Z,m,n,mode);
    
    /* Free memory */
    
    if (nrhs == 2) {    
        mxFree(t);
        mxFree(Z);          
    } else if (nrhs == 3) 
        mxFree(Z);

    return;
    
}






















