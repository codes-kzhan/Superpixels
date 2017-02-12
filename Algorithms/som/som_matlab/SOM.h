#include"myrgb2lab.h"
using namespace std;

void SOM(unsigned char* R,unsigned char* G,unsigned char* B,int nRows,int nCols,int superpixelnum,unsigned short* label)
{
	//Setting Parameter
	int clusterNum=superpixelnum;
	int iterationNum=20;

	unsigned char *L, *a, *b, *x, *y;
	L=new unsigned char[nRows*nCols];
	a=new unsigned char[nRows*nCols];
	b=new unsigned char[nRows*nCols];
    x=new unsigned char[nRows*nCols];
    y=new unsigned char[nRows*nCols];
    
	myrgb2lab(R,G,B,L,a,b,nRows,nCols);    
    //Initialization
    
    //Trainning
    
    //Produce Superpixels
    
    //Clear Memory
}

void Initialize()
{

}

void training()
{

}

void doSuperpixels()
{

}

int minimum(double nodeArray[]) {
    
}

void updateWeights() {

}

void distance() {

}
