#include <stdio.h>

#define NUM 10

int main()
{
        float x_left[NUM];
        float x_right[NUM];
        float v[NUM];
        
        float *x1=x_left;
        float *x2=x_right;

        float d1;
        float d2;
        float k;

        float f1;
        float f2;

        float a;
        float m;
        float t;

        k=1;
        m=0.5;
        t=0.1;

        int i;
        int j;

        for(i=0; i<NUM; i++)
        {
            x_left[i]=i+1;
            x_right[i]=i+1;
            v[i]=0;
            //printf("%f ",v[i]);
        }
        x_left[0]=1.5;
        x_right[0]=1.5;


        for(j=0; j<5; j++)
        {
            if(i%2)
            {
                x1=x_right;
                x2=x_left;
                }
            else
            {
                x1=x_left;
                x2=x_right;
                }
            for(i=1; i<NUM-1; i++)
            {
                d1  =   x1[i]-x1[i-1];
                d2  =   x1[i+1]-x1[i];
                //printf("%f ",x1[i]);
                //printf("%f ",x2[i]);
                f1  =   k/(d1*d1);
                f2  =   k/(d2*d2);
                a   =   (f2-f1)/m;
                v[i]+=  a*t/2;
                x2[i]=  x1[i]+v[i]*t;

                //printf("%f ",x1[i]);
                //printf("%f ",v[i]);
                printf("%f ",x2[i]);
                printf("\n");
                }
            printf("\n");
            }

        return 0;
}

