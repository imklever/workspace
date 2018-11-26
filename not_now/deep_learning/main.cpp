#include <iostream>
#include <iomanip>
#include <stdlib.h>

using namespace std;

int main()
{
    double     in[10];
    double     out[10];
    double  para[10][10];
    
    int c1,c2;
    int L1=10,L2=10;


//initial
    cout << "input:" << endl;
    for(int i=0; i<10; i++)
    {
        in[i] = rand()*0.00000000033;
        out[i] = 0;
        cout << setprecision(4) << in[i] << "\t";
    }
    cout << endl;

    cout << "cal:" << endl;
    for(int i=0; i<10; i++)
    {
        for(int j=0; j<10; j++)
        {
            para[i][j] = rand()*0.00000000033;
            cout << setprecision(4) << para[i][j] << "\t";
        }
        cout << endl;
    }

    for(int i=0; i<10; i++)
    {
        in[i] = rand()*0.00000000033;
        out[i] = 0;
    }

//cacul
    int count = 10;
    while(count--)
    {
        for(c2=0;c2<L2;c2++)
        {
            for(c1=0;c1<L1;c1++)
            {
                out[c2] += in[c1]*para[c2][c1];
            }
        }
        for(int i=0;i<10;i++)
        {
            in[i] = out[i];
        }
    }

    cout << "out:" << endl;
    for(int i=0;i<10;i++)
    {
        cout << out[i] << "\t";
    }

    cout << endl;
    return 0;
}
