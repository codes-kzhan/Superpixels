
/*
 * LLCEncodeHelper.cpp
 *
 * [histSum histMax histHard] = LLCEncodeHelper(dictWords,imWords,nearestNeighborResult,beta)
 *
 * where size(dictWords) = [m n], size(imWords) = [m l] 
 * and size(nearestNeighborResult) = [n l]
 *
 * Author: Yuning Chai 
 *
 * This is a MEX-file for MATLAB.
*/

#include "mex.h"
#include "lapack.h"
#include "blas.h"

void mult_help(const double* A, ptrdiff_t height, ptrdiff_t width, double* C){
    
    double tmp;
    for(ptrdiff_t i=0;i<width;i++){
        for(ptrdiff_t j=i;j<width;j++){
            tmp = 0;
            for(ptrdiff_t k=0;k<height;k++){
                tmp = tmp + A[i*height+k]*A[j*height+k];
            }
            C[i*width+j] = tmp;
            C[j*width+i] = tmp;
        }
    }

}


void encode(const double* dict_words, const double* im_words, const double* nn_ind, 
        ptrdiff_t dim, ptrdiff_t dict_size, ptrdiff_t im_size, ptrdiff_t nn_size, double beta, 
        double* encoding){
    
//     double one = 1.0;
//     double zero = 0.0;
//     char transpose = 'T';
//     char non_trans = 'N';
    char upper_triangle = 'U';
    ptrdiff_t INFO;
    ptrdiff_t int_one = 1;
    double sum;

    double* z = new double[dim*nn_size];
    double* C = new double[nn_size*nn_size];
    double* b = new double[nn_size];
    ptrdiff_t* IPIV = new ptrdiff_t[nn_size];

    for(ptrdiff_t i=0; i<im_size; i++){
        
//        hist_hard[(ptrdiff_t)nn_ind[i*nn_size]]++;
        
        ptrdiff_t tmp_ind;
        for(ptrdiff_t n=0;n<nn_size;n++){
            for(ptrdiff_t m=0;m<dim;m++){
                tmp_ind = nn_ind[i*nn_size+n]-1;
                z[n*dim+m] = dict_words[tmp_ind*dim+m]-im_words[i*dim+m];
            }
        }
        
        mult_help(z,dim,nn_size,C);
        
//         dgemm(&transpose,&non_trans,&nn_size,&nn_size,&dim,&one,z,&nn_size,z,&dim,&zero,C,&nn_size);
        
        sum = 0;
        for(ptrdiff_t m=0;m<nn_size;m++) sum += C[m*nn_size+m];
        sum = sum*beta;
        for(ptrdiff_t m=0;m<nn_size;m++) C[m*nn_size+m] += sum;
            
        for(ptrdiff_t m=0;m<nn_size;m++) b[m] = 1;
        
        dposv(&upper_triangle,&nn_size,&int_one,C,&nn_size,b,&nn_size,&INFO);
//         dgesv(&nn_size,&int_one,C,&nn_size,IPIV,b,&nn_size,&INFO);
                
        sum = 0;
        for(ptrdiff_t m=0;m<nn_size;m++) sum += b[m];
        for(ptrdiff_t m=0;m<nn_size;m++) b[m] /= sum;
        
        for(ptrdiff_t m=0;m<nn_size;m++){
//            tmp_ind = nn_ind[i*nn_size+m];
            encoding[i*nn_size+m] = b[m];
        }
    }
    
    delete [] z;
    delete [] C;
    delete [] b;
    delete [] IPIV;    
    
    return;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double* dict_words = mxGetPr(prhs[0]);
    double* im_words = mxGetPr(prhs[1]);
    double* nn_ind = mxGetPr(prhs[2]);
    ptrdiff_t dim = mxGetM(prhs[0]);
    ptrdiff_t dict_size = mxGetN(prhs[0]);
    ptrdiff_t im_size = mxGetN(prhs[1]);
    ptrdiff_t nn_size = mxGetM(prhs[2]);
    double beta = mxGetScalar(prhs[3]);    
    
    // matlab index starts with 1 instead 0
    //for(ptrdiff_t i=0;i<nn_size*im_size;i++) nn_ind[i]--;
    
    plhs[0] = mxCreateDoubleMatrix(nn_size,im_size,mxREAL);
    double* encoding = mxGetPr(plhs[0]);

    
    encode(dict_words, im_words, nn_ind, 
        dim, dict_size, im_size, nn_size, beta, 
        encoding);
    
}