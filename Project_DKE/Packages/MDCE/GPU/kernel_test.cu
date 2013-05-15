
__global__ void add1( double * pi, double c ) 
{
    *pi += c + 2.0;
}

__global__ void add2( double * v1, const double * v2 ) 
{
    int idx = threadIdx.x;
    v1[idx] += v2[idx];
}
