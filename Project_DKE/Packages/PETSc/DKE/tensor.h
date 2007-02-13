
typedef long double DOUBLE;
typedef int INT;
struct Tensor {
int ndims;
int * sizedim;
int  size;
DOUBLE * vals;
};

struct SparseMatrix{
int m; /*nb of rows*/
int n; /*nb of columns*/
int nnz; /*nb of non zeros elements*/
int *jc; /**/
int *ir; /* row indices of non zeros*/
DOUBLE *vals; /*actual values*/
};

struct IntTensor {
int ndims;
int * sizedim;
int  size;
INT * vals;
};
