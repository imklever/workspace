#include <stdio.h>

#define MAX 20
#define FLength 6

int main()
{
    int i,j,number;
    int flag;
    int fibonacci[6] = {1,2,3,5,8,13};
    char result[7];
    

    for(i=0; i<=MAX; i++)
    {
        flag=0;
        number=i;

        for(j=0; j<FLength; j++)
        {
            if(flag==0 && fibonacci[FLength-1-j] <= number)
            {
                number -= fibonacci[FLength-1-j];
                result[j]='1';
                flag=1;
            }
            else
            {
                result[j]='0';
                flag=0;
            }

        }
        result[6]='\0';
        printf("%d:\t%s\n", i, result);
    }

    return 0;
}
